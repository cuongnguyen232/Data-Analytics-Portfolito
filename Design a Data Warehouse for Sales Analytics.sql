-- tạo database / create databse
CREATE DATABASE DW_COLE;
USE DW_COLE;


-- tạo bảng employee / create table employee
CREATE TABLE Employee (
	EmployeeId	int identity(1,1) PRIMARY KEY,
	Last_Name	nvarchar(50) NOT NULL,
	First_name	nvarchar(50) NOT NULL,
	Sex	nvarchar(1) NOT NULL,
	DoB	date NOT NULL ,
	JobTitle	nvarchar(10) NOT NULL,
	Salary	decimal( 18,2) NOT NULL,
	HireDate	date NOT NULL,
	DepartmentID	INT NOT NULL,
	ManagerId	int,
	ModifiedDate	datetime NOT NULL
	);

-- tạo bảng department / create table department
CREATE TABLE Department (
	DepartmentID	int identity(1,1) PRIMARY KEY,
	Department	nvarchar(50) NOT NULL,
	ModifiedDate	datetime NOT NULL 
	);

-- tạo liên kết bảng employee với department / create a relationship between table "employee" and "department"
ALTER TABLE Employee
ADD CONSTRAINT FK_Department FOREIGN KEY  (DepartmentID)  REFERENCES  Department  (DepartmentID);

-- tạo bảng product / create table product
CREATE TABLE Products (
	ProductID INT identity(1,1) PRIMARY KEY NOT NULL,
	Product_Name	nvarchar(50) NOT NULL,
	Cost	decimal(18,2) NOT NULL,
	UnitPrice	decimal(18,2) NOT NULL,
	ProductCategoryID	int NULL,
	ModifiedDate	datetime NOT NULL
	);

-- tạo bảng ProductCategory / create table ProductCategory
CREATE TABLE ProductCategory (
	ProductCategoryID	INT identity(1,1) PRIMARY KEY NOT NULL,
	ProductID	int,
	Name	nvarchar(50),
	ModifiedDate	datetime
	);

-- TẠO LIÊN KẾT "PRODUCT" VÀ "PRODUCTCATEGORY" / create a relationship between table "product" and "productcategory"
ALTER TABLE Products
ADD CONSTRAINT FK_productCategory   FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategory (ProductCategoryID) ;

-- tạo bảng "status" / create table "status"

CREATE TABLE STATUS (
	StatusID	INT identity(1,1) PRIMARY KEY NOT NULL,
	DescriptionS	nvarchar(30) NOT NULL ,
	ModifiedDate	datetime NOT NULL,
	);

-- TẠO BẢNG CUSTOMER  / create table "customer"

CREATE TABLE Customer (
	CustomerId	INT identity(1,1) PRIMARY KEY NOT NULL,
	Last_Name	nvarchar(50)	null, 
	First_Name	nvarchar(50)	null, 
	DoB	date	null, 
	Sex	nvarchar(1)	null,
	Email	nvarchar(100)	null,
	Phone_Number	int	null,
	ModifiedDate	datetime	not null
	);


-- tạo bảng store / create table "Store"
CREATE TABLE Store (
	StoreId	INT identity(1,1) PRIMARY KEY NOT NULL,
	StoreName	nvarchar(50)	not null,
	RegionID	int	null,
	ModifiedDate	datetime	not null 
	);

-- tạo bảng region / create table "region"
CREATE TABLE Region (
	RegionId	INT identity(1,1) PRIMARY KEY NOT NULL,
	Region_Name	nvarchar(50) not null,
	ModifiedDate	datetime not null
	);

-- tạo liên kết store và region  / create a relationship between table "store" and table "region"

ALTER TABLE Store
ADD CONSTRAINT FK_Region	FOREIGN KEY (RegionID)   REFERENCES Region (RegionId);


-- tạo bảng promotion   / create table "Promotion"
CREATE TABLE Promotion (
	PromotionId	INT identity(1,1) PRIMARY KEY NOT NULL,
	Promotion_Name	nvarchar(50)   not null,
	DiscountAmount	decimal(18,2)   not null ,
	DiscountPercent	decimal(2,2) not null ,
	MaxQuantity	int null,
	PromotionType	nvarchar(50)  not null,
	Start_time	date  not null,
	End_time	date  not null,
	ModifiedDate	datetime not null
	);


-- tạo bảng fact / create FACT Table
-- tạo bảng salesorderheader  / create table salesorderheader

CREATE TABLE SalesOrderHeader (
	SalesOrderID	INT identity(1,1) PRIMARY KEY NOT NULL,
	CustomerID	int null,
	OrderDate	date NOT NULL ,
	StatusID	int NOT NULL ,
	StoreID	int NOT NULL,
	EmployeeID	int NOT NULL,
	Subtotal	decimal(18,2) NOT NULL,
	PromotionID	int NOT NULL,
	DiscountAmount	decimal(18,2)  NOT NULL,
	DiscountPercent	decimal(2,2) NOT NULL,
	FinalTotal	decimal(2,2) NOT NULL,
	ModifiedDate	datetime NOT NULL
	);



-- tạo bảng salesorderdetal  / create table salesorderdetail
CREATE TABLE SalesOrderDetail   (
	SalesOrderDetailID	INT identity(1,1) PRIMARY KEY NOT NULL,
	SalesOrderID	int NOT NULL,
	ProductID	int NOT NULL,
	UnitPrice	decimal(18,2) NOT NULL,
	Quantity	int NOT NULL,
	PromotionID	int NOT NULL,
	discountAmount	decimal(18,2) NOT NULL,
	discountPercent	decimal(2,2) NOT NULL,
	LineTotal	decimal(18,2) NOT NULL,
	ModifiedDate	datetime NOT NULL
	);

-- tạo ràng buộc bảng salesorderheader / create constraints
ALTER TABLE SalesOrderHeader
ADD CONSTRAINT FK_Customer_sales   FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
	CONSTRAINT FK_STATUS_sales   FOREIGN KEY (StatusID)   REFERENCES Status (StatusID),
	CONSTRAINT FK_Store_sales	 FOREIGN KEY  (StoreID) REFERENCES Store (StoreID),
	CONSTRAINT FK_Employee_sales	 FOREIGN KEY  (EmployeeID) REFERENCES Employee (EmployeeID),
	CONSTRAINT FK_Promotion_sales FOREIGN KEY (PromotionID)   REFERENCES Promotion (PromotionID);

-- tạo ràng buộc salesorderdetail

ALTER TABLE SalesOrderDetail
ADD CONSTRAINT  FK_SalesHeader FOREIGN KEY (SalesOrderID) REFERENCES SalesOrderHeader(SalesOrderID),
	CONSTRAINT FK_PROMO_SALESDETAL FOREIGN KEY (PromotionID)  REFERENCES Promotion (PromotionID),
	CONSTRAINT FK_PRODUCT_SALESDETAL FOREIGN KEY (ProductID)   REFERENCES Products   (ProductID);
