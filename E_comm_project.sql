-- import the data and insert into the temporary table
CREATE GLOBAL TEMPORARY TABLE TEMP_ECOMMERCE
   (	"INVOICENO" VARCHAR2(20 BYTE), 
	"STOCKCODE" VARCHAR2(20 BYTE), 
	"DESCRIPTION" VARCHAR2(255 BYTE), 
	"QUANTITY" NUMBER, 
	"INVOICEDATE" VARCHAR2(70 BYTE), 
	"UNITPRICE" NUMBER(10,4), 
	"CUSTOMERID" NUMBER, 
	"COUNTRY" VARCHAR2(50 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- Data Cleaning 
-- step 1: replace null value to unknown to avoid 
Update TEMP_ECOMMERCE
set DESCRIPTION ='Unknown'
where DESCRIPTION is null


-- step 2 : supprimer les doublons 
DELETE FROM TEMP_ECOMMERCE 
WHERE ROWID NOT IN (
select min(rowid) from TEMP_ECOMMERCE 
group by INVOICENO,STOCKCODE,CUSTOMERID
)

select INVOICENO,CUSTOMERID, count(*) 
from TEMP_ECOMMERCE 
group by INVOICENO,CUSTOMERID
having count(*) >1

-- step 3 : corriger les erreurs de format 
 -- no issue 
select distinct country from TEMP_ECOMMERCE

-- step 4 : verifier les valeurs aberrantes 
 -- quantite negative ou trop grande
/*

Raisons des Quantités Négatives :
Retours de Produits :

, les quantités négatives sont souvent utilisées pour représenter des retours. Lorsqu'un client renvoie un produit, une entrée avec une quantité négative peut être enregistrée pour ajuster les ventes.
Ajustements d'Inventaire :

Les entreprises effectuent parfois des ajustements pour corriger des erreurs d'inventaire. Cela peut inclure des pertes, des vol ou des erreurs dans les stocks, ce qui pourrait se traduire par des entrées négatives.
Transactions d'Annulation :

Si une commande est annulée après l'enregistrement de la vente, cela peut également être enregistré avec une quantité négative pour compenser la vente précédente.
Données Erronées :

Dans certains cas, les données peuvent contenir des erreurs de saisie, où un employé a accidentellement entré une quantité négative au lieu d'une valeur positive.
Promotions et Remises :

Des ajustements peuvent être faits pour refléter des promotions ou des remises mal appliquées, ce qui pourrait également entraîner des quantités négatives.
Impact des Quantités Négatives :
Les quantités négatives peuvent avoir un impact significatif sur l'analyse des données, notamment :

Analyse des Ventes : Elles peuvent fausser les résultats des analyses de vente et des prévisions.
Gestion des Stocks : Elles compliquent la gestion de l'inventaire et nécessitent des ajustements pour refléter la réalité des stocks.
Rapports Financiers : Des quantités négatives peuvent affecter les rapports financiers et la comptabilité, entraînant des erreurs de calcul des revenus.

*/

DELETE FROM TEMP_ECOMMERCE
WHERE quantity < 0;

DELETE FROM TEMP_ECOMMERCE
WHERE UNITPRICE < 0;

-- step 5 : Normalisation 
drop table dim_product
create table dim_product
( 
  PRODUCT_ID VARCHAR2(20 Byte) PRIMARY KEY,
  DESCRIPTION VARCHAR2(255 BYTE)
);

drop table dim_customer
create table dim_customer 
(
  CUSTOMER_ID NUMBER PRIMARY KEY, 
  COUNTRY VARCHAR2(50 BYTE)
);
drop table dim_order
create table dim_order 
(
  ORDER_ID VARCHAR2(20Byte) PRIMARY KEY,
  ORDERDATE DATE,
  ORDERTIME TIMESTAMP
);

drop table fact_sales
create table fact_sales 
(
  ORDER_ID VARCHAR2(20 BYTE),
  CUSTOMER_ID NUMBER,
  PRODUCT_ID VARCHAR2(20 BYTE),
  QUANTITY NUMBER,
  UNITPRICE NUMBER(10,4),
  PRIMARY KEY (ORDER_ID,CUSTOMER_ID,PRODUCT_ID),
  CONSTRAINT fk_NEW_ORDER_ID FOREIGN KEY (ORDER_ID)
    REFERENCES dim_order(ORDER_ID),
  CONSTRAINT fk_NEW_PRODUCT_ID FOREIGN KEY (PRODUCT_ID)
    REFERENCES dim_product (PRODUCT_ID),
  CONSTRAINT fk_NEW_CUSTOMER_ID FOREIGN KEY (CUSTOMER_ID)
    REFERENCES dim_customer (CUSTOMER_ID)
) ;

-- indexes sur les clées étrangères qui ne sont pas généré automatiquement contrairement au PK

CREATE INDEX idx_fk_NEW_ORDER_ID on fact_sales(ORDER_ID);
CREATE INDEX idx_fk_NEW_PRODUCT_ID ON fact_sales (PRODUCT_ID);
CREATE INDEX idx_fk_NEW_CUSTOMER_ID ON fact_sales (CUSTOMER_ID);

-- indexes sur les colonnes fréquemment recherchées 
CREATE INDEX idx_orders_date ON dim_order(ORDERDATE);
-- indexes BITMAP pour valeur répétitive ( je ne peux pas créer car j'utilise standard version) 
-- mais sinon j'aurai utilise index bitmap
select BANNER from V$Version;
Create  INDEX idx_customers_country on dim_customer(country); 


--- Inserer les donnees mtn 
--- Insertion des clients (Customers) 


-- error un meme client est dans deux pauys... 
-- on va prendre le fait que par rapport à la derniere date il habite ou 
Insert into dim_customer (customer_id,country)
SELECT distinct t.CustomerID, t.country
FROM TEMP_ECOMMERCE t
where t.CustomerID is not null and t.invoicedate in ( select max(invoicedate) from TEMP_ECOMMERCE z
where z.customerid=t.customerid)


-- error un meme produit a deux descriptions différents  
-- on va prendre le fait que par rapport à la derniere date la description concerné et description non null 
--Insertion des produits (Products) 
Insert into dim_product (product_id,description) 
SELECT distinct t.StockCode,t.description
FROM TEMP_ECOMMERCE t 
where t.StockCode is not null and t.invoicedate in ( select max(invoicedate) from TEMP_ECOMMERCE z
where z.StockCode=t.StockCode) and t.description <>'Unknown'

 
--Insertion des commanes (Orders) 
--  on va prendre le fait que par rapport à la derniere dat
Insert into dim_order (order_id,ORDERDATE,ORDERTIME) 
SELECT distinct t.InvoiceNo,to_date(SUBSTR(t.INVOICEDATE, 1, INSTR(t.INVOICEDATE, ' ') - 1),'YYYY-MM-DD') AS ORDERDATE , TO_TIMESTAMP(SUBSTR(t.INVOICEDATE, INSTR(t.INVOICEDATE, ' ') + 1),'HH24:MI:SS' )AS ORDERTIME
FROM TEMP_ECOMMERCE t
where InvoiceNo is not null and  t.invoicedate in ( select max(invoicedate) from TEMP_ECOMMERCE z
where z.InvoiceNo=t.InvoiceNo)


-- Insertion des Star Schema
Insert into fact_sales (order_id,product_id,customer_id,quantity,unitprice) 
SELECT 
  o.order_id,
  p.product_id,
  c.customer_id,
  t.quantity,
  t.unitprice
  FROM TEMP_ECOMMERCE t 
  JOIN dim_order o on t.INVOICENO = o.order_id
  JOIN dim_product p on t.stockcode=p.product_id
  JOIN dim_customer c on  t.customerid=c.customer_id
  WHERE t.invoiceno is not null ;
----------------------------------------------------


-------- verification etapes
SELECT COUNT(*) 
FROM fact_sales f
LEFT JOIN dim_order o ON f.order_id = o.order_id
LEFT JOIN dim_product p ON f.product_id = p.product_id
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE o.order_id IS NULL OR p.product_id IS NULL OR c.customer_id IS NULL;

select count(*) from dim_product
select count(*) from dim_customer
select count(*) from dim_order 

select order_id,product_id,customer_id 
from fact_sales
group by order_id,product_id,customer_id
having count(*)>1

select * from fact_sales


-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------commencons enfin notre travail ----------------------------------------------------------------

-- at what time do customer purchase the most on online ?
-- before let's to do some query to shoow skills of data analyst

----------------------------------------------------------------------------------------------------------------------------------------------
-------- theme basic sql 
-- select most sale top 5 products
select f.product_id,d.description, SUM(f.quantity) as total_quantity
from fact_sales f
left join dim_product d 
on f.product_id=d.product_id
group by f.product_id,d.description
order by total_quantity desc 
fetch first 5 rows only; 

--Lister les clients avec le plus grand nombre de commandes.
select customer_id,count(*) 
from fact_sales
group by customer_id
order by  count(*)desc
fetch first 3 rows only ;


--Afficher les commandes passées en 2011.
select az.orderdate,az.* from dim_order az
where az.orderdate between '01-JAN-2011' and '31-DEC-2011'

select * from dim_order
where extract(year from orderdate)='2011'

-------- theme advanced sql 


--Trouver les clients qui ont passé plus d’une commande par mois.
SELECT customer_id, EXTRACT(YEAR FROM o.orderdate) AS year, EXTRACT(MONTH FROM o.orderdate) AS month, COUNT(*) AS total_orders
FROM fact_sales f
JOIN dim_order o ON f.order_id = o.order_id
GROUP BY customer_id, EXTRACT(YEAR FROM o.orderdate), EXTRACT(MONTH FROM o.orderdate)
HAVING COUNT(*) > 1;

--Identifier les produits qui n’ont jamais été vendus.
SELECT p.product_id, p.description
FROM dim_product p
LEFT JOIN fact_sales f ON p.product_id = f.product_id
WHERE f.product_id IS NULL;

--Calculer le chiffre d’affaires mensuel pour chaque produit.
SELECT p.description, 
       EXTRACT(YEAR FROM o.orderdate) AS year, 
       EXTRACT(MONTH FROM o.orderdate) AS month, 
       SUM(f.quantity * f.unitprice) AS revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_order o ON f.order_id = o.order_id
GROUP BY p.description, EXTRACT(YEAR FROM o.orderdate), EXTRACT(MONTH FROM o.orderdate)
ORDER BY year, month;

-------- theme analytical functions
--Ranker les clients par montant total dépensé.
SELECT f.customer_id, SUM(f.quantity * f.unitprice) AS total_spent, 
       RANK() OVER (ORDER BY SUM(f.quantity * f.unitprice) DESC) AS rank
FROM fact_sales f 
GROUP BY f.customer_id;

--Déterminer pour chaque commande la différence de temps avec la commande précédente du même client.
SELECT f.customer_id, f.order_id, o.orderdate,
       LAG(o.orderdate) OVER (PARTITION BY f.customer_id ORDER BY o.orderdate) AS previous_order_date,
       orderdate - LAG(o.orderdate) OVER (PARTITION BY f.customer_id ORDER BY o.orderdate) AS days_between_orders
FROM fact_sales f
JOIN dim_order o ON f.order_id = o.order_id;

-------- theme agregation & pivoting 
--Afficher le total des ventes par mois et par produit en utilisant un pivot.
SELECT * FROM (
    SELECT p.description, EXTRACT(MONTH FROM o.orderdate) AS month, SUM(f.quantity * f.unitprice) AS revenue
    FROM fact_sales f
    JOIN dim_product p ON f.product_id = p.product_id
    JOIN dim_order o ON f.order_id = o.order_id
    GROUP BY p.description, EXTRACT(MONTH FROM o.orderdate)
) 
PIVOT (
    SUM(revenue) FOR month IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
);



-------- theme hierarchical queries
--Mettre à jour la table des produits avec de nouvelles données sur les prix ou ajouter de nouveaux produits si ils n’existent pas encore.

MERGE INTO dim_product p
USING new_product_data np
ON (p.product_id = np.product_id)
WHEN MATCHED THEN 
    UPDATE SET p.unitprice = np.unitprice
WHEN NOT MATCHED THEN
    INSERT (product_id, stockcode, description, unitprice) 
    VALUES (np.product_id, np.stockcode, np.description, np.unitprice);

-------- Indexes and Strategies
-- 12. Créer un index B-tree sur la colonne `OrderDate` de la table des commandes
CREATE INDEX idx_order_date ON dim_order(orderdate);


-- 14. Créer un index basé sur une fonction pour les recherches insensibles à la casse
CREATE INDEX idx_product_lower ON dim_product(LOWER(description));
-------- Query Optimization
-- 15. Utiliser `EXPLAIN PLAN` pour comparer une requête avec et sans index, et analyser l'impact sur le plan d'exécution
EXPLAIN PLAN FOR 
SELECT * FROM fact_sales WHERE product_id = 100;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- 16. Utiliser SQL Trace pour collecter des statistiques d'exécution d'une requête
ALTER SESSION SET SQL_TRACE = TRUE;
SELECT * FROM fact_sales WHERE product_id = 100;
ALTER SESSION SET SQL_TRACE = FALSE;

-- 17. Analyser les résultats de TKPROF pour optimiser une requête lente
tkprof trace_file.trc output_file.prf SORT=exeela

-------- Partitioning
-- 18. Créer une table partitionnée par plage (range) sur la colonne `OrderDate` pour organiser les commandes par année
CREATE TABLE fact_sales_partitioned (
    order_id NUMBER,
    product_id NUMBER,
    customer_id NUMBER,
    orderdate DATE
)
PARTITION BY RANGE (orderdate) (
    PARTITION p2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION p2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD'))
);
-- 19. Partitionner une table par liste (list) en fonction de la colonne `Region`
CREATE TABLE fact_sales_partitioned_list
PARTITION BY LIST (customer_id) (
    PARTITION europe VALUES (SELECT customer_id FROM dim_customer WHERE country IN ('France', 'Germany')),
    PARTITION usa VALUES (SELECT customer_id FROM dim_customer WHERE country IN ('USA', 'Canada'))
);
-- 20. Mettre en place une partition par hachage (hash) pour équilibrer les données
CREATE TABLE fact_sales_partitioned_hash
PARTITION BY HASH (customer_id) PARTITIONS 4;


----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------- answer final question

-- at what time do customer purchase the most on online ?
select count(*) from dim_order

select ordertime,count(*) 
from dim_order 
group by ordertime
order by ordertime 





