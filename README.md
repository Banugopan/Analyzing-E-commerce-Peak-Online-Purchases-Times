# 📊 Analysis of Online Purchase Times

## Project Objective
This project analyzes online purchase times to identify peak shopping periods and optimize business strategies.

## 🔍 Data Used
The dataset comes from **Kaggle Ecommerce Data from Carrie** and includes:
- **dim_order**: Information about orders (order ID, date, time).
- **dim_product**: Product details (product ID, description).
- **dim_customer**: Customer information (customer ID, country).
- **fact_sales**: Sales details (quantity, unit price, etc.).

The data is stored in **Oracle 19c** and follows a **star schema model** for efficient organization and analysis.

## 📜 Context
Typically, e-commerce datasets are proprietary and consequently hard to find among publicly available data. However, the UCI Machine Learning Repository has made this dataset containing actual transactions from 2010 and 2011. The dataset is maintained on their site, where it can be found by the title **"Online Retail"**.

## 🔧 Analysis Steps
1. **Data Extraction**: Import raw data from the database.
2. **Cleaning and Preparation**: Process data for analysis.
3. **Temporal Analysis**: Identify peak hours for online purchases.
4. **Visualization**: Create charts to represent purchase times.

## 📈 Results
The analysis indicates that most purchases occur between **[XX:XX]** and **[YY:YY]**. These insights can help improve marketing strategies and inventory management.
