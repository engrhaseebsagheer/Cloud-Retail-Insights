CREATE TABLE stg_sales (
    RowID INT,
    OrderID NVARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode NVARCHAR(50),
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(100),
    Segment NVARCHAR(50),
    Country NVARCHAR(50),
    City NVARCHAR(50),
    State NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Region NVARCHAR(50),
    ProductID NVARCHAR(50),
    Category NVARCHAR(50),
    SubCategory NVARCHAR(50),
    ProductName NVARCHAR(255),
    Sales FLOAT,
    Quantity INT,
    Discount FLOAT,
    Profit FLOAT
);
CREATE TABLE dim_customer (
    CustomerID NVARCHAR(50) PRIMARY KEY,
    CustomerName NVARCHAR(100),
    Segment NVARCHAR(50)
);

CREATE TABLE dim_product (
    ProductID NVARCHAR(50) PRIMARY KEY,
    Category NVARCHAR(50),
    SubCategory NVARCHAR(50),
    ProductName NVARCHAR(255)
);

CREATE TABLE dim_region (
    Region NVARCHAR(50) PRIMARY KEY
);
CREATE TABLE fact_sales (
    SalesID INT IDENTITY PRIMARY KEY,
    OrderID NVARCHAR(50),
    CustomerID NVARCHAR(50),
    ProductID NVARCHAR(50),
    Region NVARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    Sales FLOAT,
    Quantity INT,
    Discount FLOAT,
    Profit FLOAT
);

