CREATE DATABASE EmployeeDB;

USE employeeDB;

CREATE TABLE Employees(
  EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10,2),
    ManagerID INT,
    HireDate DATE
);
INSERT INTO Employees (EmployeeID, EmployeeName, Department, Salary, ManagerID, HireDate) VALUES
(101, 'John', 'Sales', 50000, 201, '2021-01-10'),
(102, 'Mary', 'Sales', 65000, 201, '2020-03-15'),
(103, 'David', 'HR', 55000, 202, '2022-05-20'),
(104, 'Sophia', 'HR', 70000, 202, '2019-07-18'),
(105, 'James', 'IT', 80000, 203, '2018-11-01'),
(106, 'Emma', 'IT', 75000, 203, '2021-09-25'),
(107, 'Michael', 'Finance', 90000, 204, '2017-06-12'),
(108, 'Olivia', 'Finance', 60000, 204, '2023-02-01');


-- Employees earning more than the average salary
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);

--  Employees earning the highest salary
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary = (SELECT MAX(Salary) FROM Employees);

-- Employees earning the second highest salary
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary = (
    SELECT MAX(Salary)
    FROM Employees
    WHERE Salary < (SELECT MAX(Salary) FROM Employees)
);

-- Employees whose salary is less than the maximum salary
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary < (SELECT MAX(Salary) FROM Employees);


-- Departments having employees with salary greater than 70,000
SELECT DISTINCT Department
FROM Employees
WHERE Salary > 70000;

--  Employees whose salary is above their department average
SELECT EmployeeName, Department, Salary
FROM Employees e
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employees
    WHERE Department = e.Department
);

--  Employees who earn more than all employees in HR
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary > ALL (SELECT Salary FROM Employees WHERE Department = 'HR');

--  Employees whose salary matches any salary in Sales
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary IN (SELECT Salary FROM Employees WHERE Department = 'Sales');

--  Employees hired after the employee with the lowest salary
SELECT EmployeeName, HireDate
FROM Employees
WHERE HireDate > (
    SELECT HireDate
    FROM Employees
    WHERE Salary = (SELECT MIN(Salary) FROM Employees)
);

--  Department with the highest average salary
SELECT Department
FROM Employees
GROUP BY Department
HAVING AVG(Salary) = (
    SELECT MAX(DeptAvg)
    FROM (SELECT AVG(Salary) AS DeptAvg FROM Employees GROUP BY Department) AS Sub
);

--  Employees who earn the minimum salary in their department
SELECT EmployeeName, Department, Salary
FROM Employees e
WHERE Salary = (
    SELECT MIN(Salary)
    FROM Employees
    WHERE Department = e.Department
);

--  Managers who manage employees earning more than 75,000
SELECT DISTINCT ManagerID
FROM Employees
WHERE Salary > 75000;

--  Employees whose salary is greater than their manager's salary
SELECT e.EmployeeName, e.Salary, e.ManagerID
FROM Employees e
WHERE e.Salary > (
    SELECT m.Salary
    FROM Employees m
    WHERE m.EmployeeID = e.ManagerID
);

-- 15. Top 3 highest paid employees using a subquery
SELECT EmployeeName, Salary
FROM Employees
WHERE Salary IN (
    SELECT DISTINCT Salary
    FROM Employees
    ORDER BY Salary DESC
    LIMIT 3
);