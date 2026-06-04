CREATE DATABASE ProductOrdersTable;

USE ProductOrdersTable; 


CREATE TABLE ProductOrders (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    SalesAmount DECIMAL(12,2),
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO ProductOrders VALUES
(1,'2026-01-05',1001,101,'Laptop','Electronics',2,60000,120000),
(1,'2026-01-05',1001,102,'Mobile','Electronics',1,25000,25000),
(2,'2026-01-10',1002,103,'Printer','Electronics',3,12000,36000),
(3,'2026-01-15',1003,104,'Desk','Furniture',2,8000,16000),
(3,'2026-01-15',1003,105,'Chair','Furniture',4,3000,12000),
(4,'2026-02-05',1004,101,'Laptop','Electronics',1,60000,60000),
(4,'2026-02-05',1004,103,'Printer','Electronics',2,12000,24000),
(5,'2026-02-10',1005,102,'Mobile','Electronics',3,25000,75000),
(5,'2026-02-10',1005,104,'Desk','Furniture',1,8000,8000),
(6,'2026-03-01',1006,105,'Chair','Furniture',5,3000,15000),
(7,'2026-03-05',1007,101,'Laptop','Electronics',2,60000,120000),
(8,'2026-03-12',1008,102,'Mobile','Electronics',4,25000,100000);

-- 1. ROW_NUMBER() by SalesAmount descending
SELECT ProductID, ProductName, SalesAmount,
       ROW_NUMBER() OVER (ORDER BY SalesAmount DESC) AS RowNum
FROM ProductOrders;

-- 2. RANK() by total sales
SELECT ProductID, ProductName, SUM(SalesAmount) AS TotalSales,
       RANK() OVER (ORDER BY SUM(SalesAmount) DESC) AS SalesRank
FROM ProductOrders
GROUP BY ProductID, ProductName;

-- 3. DENSE_RANK() by quantity sold
SELECT ProductID, ProductName, SUM(Quantity) AS TotalQty,
       DENSE_RANK() OVER (ORDER BY SUM(Quantity) DESC) AS QtyRank
FROM ProductOrders
GROUP BY ProductID, ProductName;

-- 4. Top 3 selling products
SELECT ProductID, ProductName, SUM(SalesAmount) AS TotalSales
FROM ProductOrders
GROUP BY ProductID, ProductName
ORDER BY TotalSales DESC
LIMIT 3;

-- 5. Previous SalesAmount using LAG()
SELECT OrderID, ProductID, SalesAmount,
       LAG(SalesAmount) OVER (ORDER BY OrderDate) AS PrevSales
FROM ProductOrders;

-- 6. Next SalesAmount using LEAD()
SELECT OrderID, ProductID, SalesAmount,
       LEAD(SalesAmount) OVER (ORDER BY OrderDate) AS NextSales
FROM ProductOrders;

-- 7. Running total by OrderDate
SELECT OrderDate, SUM(SalesAmount) AS DailySales,
       SUM(SUM(SalesAmount)) OVER (ORDER BY OrderDate) AS RunningTotal
FROM ProductOrders
GROUP BY OrderDate;

-- 8. Cumulative sales per product
SELECT ProductID, ProductName, OrderDate, SalesAmount,
       SUM(SalesAmount) OVER (PARTITION BY ProductID ORDER BY OrderDate) AS CumulativeSales
FROM ProductOrders;

-- 9. Highest sales in each category (FIRST_VALUE)
SELECT Category, ProductName, SalesAmount,
       FIRST_VALUE(ProductName) OVER (PARTITION BY Category ORDER BY SalesAmount DESC) AS TopProduct
FROM ProductOrders;

-- 10. Lowest sales in each category (LAST_VALUE)
SELECT Category, ProductName, SalesAmount,
       LAST_VALUE(ProductName) OVER (PARTITION BY Category ORDER BY SalesAmount DESC
                                     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LowestProduct
FROM ProductOrders;

-- 11. Difference between current and previous sales
SELECT OrderID, ProductID, SalesAmount,
       SalesAmount - LAG(SalesAmount) OVER (ORDER BY OrderDate) AS DiffPrev
FROM ProductOrders;

-- 12. 3-order moving average
SELECT OrderID, ProductID, SalesAmount,
       AVG(SalesAmount) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
FROM ProductOrders;

-- 13. Percentage contribution of each product
SELECT ProductID, ProductName, SUM(SalesAmount) AS ProductSales,
       SUM(SalesAmount) * 100.0 / SUM(SUM(SalesAmount)) OVER () AS PercentContribution
FROM ProductOrders
GROUP BY ProductID, ProductName;

-- 14. Products exceeding category average
SELECT ProductID, ProductName, Category, SalesAmount
FROM ProductOrders p
WHERE SalesAmount > (SELECT AVG(SalesAmount) FROM ProductOrders WHERE Category = p.Category);

-- 15. Quartiles using NTILE(4)
SELECT ProductID, ProductName, SalesAmount,
       NTILE(4) OVER (ORDER BY SalesAmount DESC) AS Quartile
FROM ProductOrders;

-- 16. Second highest selling product
SELECT ProductID, ProductName, SUM(SalesAmount) AS TotalSales
FROM ProductOrders
GROUP BY ProductID, ProductName
ORDER BY TotalSales DESC
LIMIT 1 OFFSET 1;


-- 17. Compare each product with category leader
SELECT Category, ProductName, SalesAmount,
       MAX(SalesAmount) OVER (PARTITION BY Category) AS CategoryLeader,
       SalesAmount - MAX(SalesAmount) OVER (PARTITION BY Category) AS DiffLeader
FROM ProductOrders;

-- 18. Month-over-month sales growth
SELECT DATEPART(MONTH, OrderDate) AS Month, SUM(SalesAmount) AS MonthlySales,
       SUM(SalesAmount) - LAG(SUM(SalesAmount)) OVER (ORDER BY DATEPART(MONTH, OrderDate)) AS Growth
FROM ProductOrders
GROUP BY DATEPART(MONTH, OrderDate);

-- 19. Products with consecutive sales increases
SELECT ProductID, ProductName, OrderDate, SalesAmount,
       CASE WHEN SalesAmount > LAG(SalesAmount) OVER (PARTITION BY ProductID ORDER BY OrderDate)
            THEN 'Increase' ELSE 'No Increase' END AS Trend
FROM ProductOrders;

-- 20. Sales leaderboard using DENSE_RANK()
SELECT ProductID, ProductName, SUM(SalesAmount) AS TotalSales,
       DENSE_RANK() OVER (ORDER BY SUM(SalesAmount) DESC) AS LeaderboardRank
FROM ProductOrders
GROUP BY ProductID, ProductName;

