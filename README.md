# North-America-Sales-Retail-Analysis

## Project Overview
North America Retail operates across multiple locations, offering diverse products and a seamless shopping experience. As a data analyst, My objective is to examine sales data to identify trends in profitability, performance, and customer behavior, helping improve business efficiency and growth

## Data Source
The Dataset Used is a Retail Supply Chain Sales Analysis.csv

## Tool Used
- SQL

## Data Cleaning and Preparation
1. Importing and inapection of Data
2. Splitting Data into Facts and Dimension tables, then create an  Entity Relationship Diagram (ERD)

## Objectives
1. What was the Average delivery days for different product subcategory?
2. What was the Average delivery days for each segment ?
3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
4. Which product Subcategory generate most profit?
5. Which segment generates the most profit?
6. Which Top 5 customers made the most profit?
7. What is the total number of products by Subcategory

## Data Analysis
### 1. What was the Average delivery days for different product subcategory?
```sql
SELECT dp.Sub_Category, AVG(DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date)) AS Delivery_Days
FROM OrdersFactTable AS oft
LEFT JOIN DimProduct AS dp
ON oft.ProductKey = dp.ProductKey
GROUP BY dp.Sub_Category;

/*On average, product delivery takes 32 days for the Chairs and Bookcases subcategories,
 34 days for the Furnishings subcategory, and 36 days for the Tables subcategory*/
```

### 2. What was the Average delivery days for each segment?
```sql
SELECT Segment, AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS Delivery_Days
FROM OrdersFactTable 
GROUP BY Segment
ORDER BY Delivery_Days ASC ;

/* On average, product delivery takes 31 days for the Home office segement, 34 days for
the Consumer Segment and 35 days for the corporate segement*/
```

### 3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
```sql
SELECT TOP 5 (dp.Product_Name),(DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date)) AS Delivery_Days
FROM OrdersFactTable AS oft
LEFT JOIN DimProduct AS dp
ON oft.ProductKey = dp.ProductKey
ORDER BY Delivery_Days ASC;

/*The Top 5 fastest delivered products are:  
Sauder Camden County Barrister Bookcase, Planked Cherry Finish
Sauder Inglewood Library Bookcases
O'Sullivan 2-Shelf Heavy-Duty Bookcases
O'Sullivan Plantations 2-Door Library in Landvery Oak
O'Sullivan Plantations 2-Door Library in Landvery Oak */
```

### 4. Which product Subcategory generate most profit?
```sql
SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS total_profit
FROM OrdersFactTable AS oft
LEFT JOIN DimProduct AS dp
ON oft.ProductKey = dp.ProductKey
WHERE oft.Profit > 0
GROUP BY dp.Sub_Category
ORDER BY 2 DESC;

/* The Chairs Subcategory generated the highest Profit with a total of $36,471.1  
While the least comes from Tables Subcategory with a total of $8,358.33 */
```

### 5. Which segment generates the most profit?
```sql
SELECT Segment, ROUND(SUM(Profit),2) AS total_profit
FROM OrdersFactTable AS oft
WHERE oft.Profit > 0
GROUP BY Segment
ORDER BY 2 DESC;

/* The Consumer Segement generated the highest Profit with a total of $35,427.03 
While the least comes from Home office with a total of $13,657.04 */
```
### 6. Which Top 5 customers made the most profit?
```sql
SELECT TOP 5(Customer_Name), ROUND(SUM(oft.Profit),2) AS total_profit
FROM OrdersFactTable AS oft
LEFT JOIN DimCustomer AS dc
ON oft.Customer_ID =dc.Customer_ID
WHERE oft.Profit > 0
GROUP BY Customer_Name
ORDER BY 2 DESC;

/*The Top 5 customers with most profits are:
Laura Armstrong
Joe Elijah
Seth Vernon
Quincy Jones
Maria Etezadi */
```
   
### 7. What is the total number of products by Subcategory
```sql
SELECT Sub_Category, COUNT(Product_Name) AS product_count
FROM DimProduct
GROUP BY Sub_Category
ORDER BY product_count ASC;

/* The total number of product for each subcategory are 34,48,87,186
for Tables, Bookcases, Chairs and Furnishing respectively */
```

## Insights
- **Delivery Efficiency**:  Chairs & Bookcases (32 days) are delivered faster than Tables (36 days). The Home Office segment has the quickest delivery (31 days).

- **Profitability:**  Chairs generate the most profit ($36,471.1), while Tables contribute the least ($8,358.33). The Consumer segment is the most profitable.

- **Customer Impact:**  A few key customers drive high profits, with Laura Armstrong and Joe Elijah leading the list.

- **Product Distribution:**  Furnishings have the highest product variety, while Tables have the least.

## Recommendations
-  **Optimize Delivery:** Improve logistics for Tables and Corporate segment deliveries to reduce delays.

-  **Boost Profitability:** Expand marketing and promotions for Chairs, while reassessing pricing and sourcing for Tables.

-  **Customer Retention:** Offer loyalty rewards and personalized discounts to high-profit customers to encourage repeat purchases.

-  **Product Strategy:** Increase product variety in the Tables subcategory to drive sales and competitiveness
