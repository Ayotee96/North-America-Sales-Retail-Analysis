SELECT * FROM Sales_Retail;

--To Create a DimCustomer table from the Sales Retail Table
SELECT * INTO DimCustomer
FROM 
	( SELECT Customer_ID, Customer_Name FROM 
	Sales_Retail) AS DimC;


WITH CTE_DimC AS
		(SELECT Customer_ID,Customer_Name
		, ROW_NUMBER() OVER (PARTITION BY Customer_ID,Customer_Name ORDER BY Customer_ID ASC) AS RowNum
		FROM DimCustomer)
DELETE FROM CTE_DimC
WHERE RowNum > 1;--To remove duplicates from DimCustomer table



--To create a DimLocation Table from Sales Retail Table
SELECT * INTO DimLocation 
FROM
		(SELECT Postal_Code, Country,City,State, Region
		FROM Sales_Retail) AS DimL;



WITH CTE_DimL AS
		(SELECT Postal_Code,
				Country,
				City,
				State
				, Region
				,ROW_NUMBER() OVER (PARTITION BY Postal_Code, Country,City,State, Region ORDER BY Postal_Code ASC) AS RowNum
		FROM DimLocation)
DELETE FROM CTE_DimL
WHERE RowNum > 1;--To remove duplicate from DimLocation table



--To Create	the table for DImProduct from Sale Retail
SELECT * INTO DimProduct
FROM	( SELECT Product_ID, Category, Sub_Category,Product_Name
			FROM Sales_Retail) AS DimP;



WITH CTE_DimP AS
		(SELECT Product_ID,
		Category,
		Sub_Category,
		Product_Name
		,ROW_NUMBER() OVER (PARTITION BY Product_ID, Category, Sub_Category,Product_Name ORDER BY Product_ID ASC) AS RowNum
		FROM DimProduct)
DELETE FROM CTE_DimP
WHERE RowNum > 1;--To remove duplicate from DimProduct



--To Create Our Sales Fact Table
SELECT * INTO OrdersFactTable
FROM		( SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID,Segment, Postal_Code,
				Retail_Sales_People, Product_ID,Returned, Sales,Quantity,Discount,Profit FROM Sales_Retail)
				AS OrderFact;



WITH CTE_OrderFact AS
			(SELECT Order_ID,
			Order_Date, 
			Ship_Date,
			Ship_Mode,
			Customer_ID,
			Segment, 
			Postal_Code,
				Retail_Sales_People, 
				Product_ID,
				Returned,
				Sales,Quantity,
				Discount,
				Profit , 
				ROW_NUMBER () OVER (PARTITION BY  
				Order_ID,
				Order_Date,
				Ship_Date, 
				Ship_Mode,
				Customer_ID,
				Segment,
				Postal_Code,
				Retail_Sales_People,
				Product_ID,
				Returned
				, Sales,Quantity,
				Discount,
				Profit ORDER BY Order_ID ASC) AS RowNum
				FROM OrdersFactTable)
DELETE FROM CTE_OrderFact
WHERE RowNum >1;--To remove duplicate from OrdersFactTable




--To add a surrogate key Called ProductKey To serve as a unique identifier for DimProduct table
ALTER TABLE DimProduct
ADD ProductKey INT IDENTITY (1,1) PRIMARY KEY;


--To add the ProductKey to the OrdersFactTable
ALTER TABLE OrdersFactTable
ADD ProductKey INT;


UPDATE OrdersFactTable
SET ProductKey = DimProduct.ProductKey
FROM OrdersFactTable
JOIN DimProduct 
ON OrdersFactTable.Product_ID = DimProduct.Product_ID;



--To drop Product_ID in the OrdersFactTable and DimProduct
ALTER TABLE OrdersFactTable
DROP COLUMN Product_ID;

ALTER TABLE DImProduct
DROP COLUMN Product_ID;



--To add a unique identifier to the OrdersFactTable
ALTER TABLE OrdersFactTable
ADD  Row_ID INT IDENTITY(1,1) PRIMARY KEY;



--Exploratory Analysis
--What was the average delivery day for different 
Product Subcategory?



SELECT dp.Sub_Category, AVG(DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date)) AS Delivery_Days
FROM OrdersFactTable AS oft
LEFT JOIN DimProduct AS dp
ON oft.ProductKey = dp.ProductKey
GROUP BY dp.Sub_Category;

/*On average, product delivery takes 32 days for the Chairs and Bookcases subcategories,
 34 days for the Furnishings subcategory, and 36 days for the Tables subcategory*/



--What is the average delivery days for each Segment?

SELECT Segment, AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS Delivery_Days
FROM OrdersFactTable 
GROUP BY Segment
ORDER BY Delivery_Days ASC ;

/* On average, product delivery takes 31 days for the Home office segement, 34 days for
the Consumer Segment and 35 days for the corporate segement*/



--What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?

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





SELECT TOP 5(dp.Product_Name),(DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date)) AS Delivery_Days
FROM OrdersFactTable AS oft
LEFT JOIN DimProduct AS dp
ON oft.ProductKey = dp.ProductKey
ORDER BY Delivery_Days DESC;

 /* Top 5 slowest delivered products are:
 Bush Mission Pointe Library
Hon Multipurpose Stacking Arm Chairs
Global Ergonomic Managers Chair
Tensor Brushed Steel Torchiere Floor Lamp
Howard Miller 11-1/2" Diameter Brentwood Wall Clock */




--Which product Subcategory generate most profit?

SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS total_profit
FROM OrdersFactTable AS oft
LEFT JOIN DimProduct AS dp
ON oft.ProductKey = dp.ProductKey
WHERE oft.Profit > 0
GROUP BY dp.Sub_Category
ORDER BY 2 DESC;

/* The Chairs Subcategory generated the highest Profit with a total of $36,471.1  
While the least comes from Tables Subcategory with a total of $8,358.33 */





--Which segment generates the most profit?

SELECT Segment, ROUND(SUM(Profit),2) AS total_profit
FROM OrdersFactTable AS oft
WHERE oft.Profit > 0
GROUP BY Segment
ORDER BY 2 DESC;

/* The Consumer Segement generated the highest Profit with a total of $35,427.03 
While the least comes from Home office with a total of $13,657.04 */





--Which Top 5 customers made the most profit?


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





--What is the total number of products by Subcategory?

SELECT Sub_Category, COUNT(Product_Name) AS product_count
FROM DimProduct
GROUP BY Sub_Category
ORDER BY product_count ASC;

/* The total number of product for each subcategory are 34,48,87,186
for Tables, Bookcases, Chairs and Furnishing respectively */