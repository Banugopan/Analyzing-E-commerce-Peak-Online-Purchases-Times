# E-commerce Customer Behavior Analysis

### Technologies Used
- **Database**: Oracle 19c
- **SQL**: For data manipulation and analysis
- **Data Cleaning & Preparation**: Sql, Python, Pandas
- **Data Visualization**: Python, Matplotlib, Seaborn, Google Colab

## 1. Project Overview

### 1.1 Objective & Motivation
The goal of this project is to identify customer purchasing patterns and key drivers behind their decisions. By analyzing customer data, businesses can enhance product placements, optimize marketing strategies, and improve overall shopping experiences. The project also aims to create an interactive data visualization that presents actionable insights to decision-makers.

### 1.2 Methodology
The project follows these steps:
- **Data Collection**: The dataset was sourced from Kaggle, containing customer transaction details.
- **Data Modeling**: A star schema was employed to model the database.
- **Data Cleaning & Preparation**: Null values, duplicates, and outliers were handled, and the data was normalized.
- **SQL Queries**: SQL was used to extract insights from the dataset.
- **Data Visualization**: Python and Google Colab were used for data visualization.

### 1.3 Dataset
The dataset used in this project is sourced from Kaggle, specifically from an e-commerce platform in the UK. It includes customer transaction data with features such as transaction dates, amounts, product categories, and customer demographics. This data is authentic, provided by a real online store and shared for academic purposes.

## 2. Data Preparation & Modeling

### 2.1 Database Modeling
A **star schema** was used for modeling the data, with a central fact table containing transactional data and dimension tables detailing attributes such as customers, products, and time. This schema allows for efficient data analysis and query performance.

### 2.2 Data Collection & Import
The data was imported into an Oracle 19c database directly from an Excel file. It was formatted and cleaned before being inserted into the database tables.
![ERD](https://github.com/user-attachments/assets/20699c62-1abc-46db-a7e9-0723d1206aac)

### 2.3 Data Cleaning & Preparation
The following steps were taken to clean and prepare the data:
- **Handling Null Values**: Missing values were replaced with placeholders.
- **Removing Duplicates**: Duplicate records were removed using composite keys.
- **Format Validation**: Data was validated for consistency.
- **Identifying Outliers**: Outliers such as negative quantities were removed.
- **Data Normalization**: The data was normalized following a star schema to reduce redundancy and improve data integrity.
- **Indexing & Optimization**: Indexes were created for frequently queried columns to optimize query performance.

## 3. SQL Queries & Customer Behavior Analysis

### 3.1 SQL Queries for Data Extraction
- **Basic SQL Queries**: Extracted top-selling products, most active customers, and filtered data for orders in 2011.
- **Advanced SQL Queries**: Included customer order frequency analysis, unsold product detection, and monthly revenue calculations.
- **Analytical Functions**: Used window functions like `RANK()` for customer ranking and `LAG()` for order interval analysis.
- **Aggregations & Pivoting**: Created pivot tables for monthly sales summaries.
- **Data Maintenance**: Used the `MERGE` statement for upserting product information.
- **Indexing Strategies**: B-tree and function-based indexing were implemented to optimize queries.
- **Partitioning**: Data was partitioned by year and region to improve performance.

## 4. Data Visualization & Insights

### 4.1 Behavioral Trends & Patterns
Key customer behavioral trends observed:
- **Peak Purchase Hours**: Orders were mostly placed **between 10 AM - 3 PM**.
- **Top Purchase Days**: **Saturdays** had the highest sales.
- **Product Trends**: **The top 5 products** accounted for **over 30% of total revenue**.

### 4.2 Insights & Analysis
Using Python libraries like Pandas, Matplotlib, and Seaborn, we derived actionable insights:
- **Marketing Focus**: Target promotions during evening hours and weekends.
- **Top-Selling Products**: Focus marketing campaigns on high-demand products.
- **Stock & Offer Optimization**: Adjust inventory based on customer behavior patterns.
</br>
</br>
<div style="display: flex; justify-content: space-around;">
<img src="https://github.com/user-attachments/assets/a907b97a-17ef-4042-982c-e739d46c2942" alt="Graphique 1" width="30%">
<img src="https://github.com/user-attachments/assets/f5e556d5-2986-4632-accd-d454bcfd160d" alt="Graphique 2" width="30%">
<img src="https://github.com/user-attachments/assets/e4a6a9f6-41e5-4d06-a705-a7bcb5aae12c" alt="Graphique 3" width="30%">
</div>

## 5. Conclusions & Recommendations

### 5.1 Project Challenges
Challenges included handling inconsistent data, optimizing complex SQL queries, and integrating multiple data sources.

### 5.2 Recommendations for Future Research
- **Targeted Marketing**: Leverage insights to improve sales during evenings and Thursdays at 12 PM.
- **Web Scraping**: Future work could include scraping public data for additional insights and predictive analytics.



---

For detailed code and scripts, refer to the GitHub repository.
