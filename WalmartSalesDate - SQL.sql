-- KHỞI TẠO DATABASE walmart / CREATE DATABASE WALMART
CREATE DATABASE IF NOT EXISTS Walmart;

USE Walmart;
-- khởi tạo và import table / CREATE TABLE AND IMPORT DATA

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- DATA CLEANING / LÀM SẠCH VÀ BỔ SUNG TRƯỜNG DỮ LIỆU CẦN THIẾT
-- THÊM TRƯỜNG "time_of_day" chứa giá trị (morning, afternoon, và evening) dựa vào trường TIME

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
SELECT
	CASE 
		WHEN TIME BETWEEN "00:00:00" AND "12;00:00" THEN 'Morning'
        WHEN TIME BETWEEN "12:00:01" AND "17:00:00" THEN 'Afternoon'
        ELSE 'Evening'
	END AS 'time_of_day'
FROM walmart.sales;

UPDATE sales
SET time_of_day
= ( 
	CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
        WHEN time BETWEEN "12:00:01" AND "17:00:00" THEN 'Afternoon'
        ELSE 'Evening'
	END
);

-- add day name column / thêm cột day_name (Mon, Tus, Wed, Thur, Fri, Sat, Sun)
ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);
UPDATE SALES
SET day_name = dayname(date);


-- ADD MONTH NAME COLUMN / THÊM TRƯỜNG month_name
ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE SALES
SET month_name = monthname(date);

--------------------------------
-- ANALYZING / TIẾN HÀNH PHÂN TÍCH
-- Generic Question --
-- 1: How many unique cities does the data have? TRUY VẤN THÀNH PHỐ DUY NHẤT?

select 
		distinct CITY
	FROM SALES;
    
-- 2: In which city is each branch? / TRUY VẤN CÁC CHI NHÁNH TƯƠNG ỨNG
select 
	distinct CITY , 
			branch
	FROM SALES;
  --------------------------------
  ------------------------------------
  -- Product ---
    
-- 1: How many unique product lines does the data have? / truy vấn các sản phẩm trong tệp dữ liệu?

SELECT
		DISTINCT product_line
FROM sales;
-- 2: What is the most common payment method? / Đâu là phương pháp thanh toán phổ biến nhất?
SELECT 
	payment,
    count(*)
from sales
group by payment
ORDER BY 2 desc LIMIT 1;

-- 3 What is the most selling product line? / Dòng sản phẩm nào bán chạy nhất?
SELECT 
	product_line,
    count(*)
 FROM sales
 group by 1
 ORDER BY 2 DESC LIMIT 1; 

-- 4: What is the total revenue by month?
SELECT
	month_name,
    sum(total) as total_revenue
FROM sales
GROUP BY 1
ORDER by 1;

-- 5: What month had the largest COGS? / tháng nào có COGS lớn nhất?alter
SELECT
	month(date) as months,
	year(date) as years,
    sum(cogs)
FROM sales
group by month(date), year(date)
ORDER BY 3 DESC LIMIT 1;

-- 6: What product line had the largest revenue? Dòng sản phẩm nào có doanh thu lớn nhất?
SELECT 
	product_line,
    sum(total) as total_revenue
	FROM sales
GROUP BY product_line
ORDER BY sum(total) DESC LIMIT 1;

-- 7: What is the city with the largest revenue? thành phố nào có doanh thu lớn nhất?
SELECT 
	city,
    sum(total) as total_revenue
	FROM sales
GROUP BY 1
ORDER BY sum(total) DESC LIMIT 1;

-- 8: What product line had the largest VAT? Dòng sản phẩm nào có VAT lớn nhất?
SELECT 
	product_line,
    sum(tax_pct) as tax_pct
	FROM sales
GROUP BY 1
ORDER BY sum(total) DESC LIMIT 1;


-- 9: Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
-- Lấy mỗi dòng sản phẩm và đánh giá. Nếu doanh thu > trung bình là tốt, và ngược lại'

Select 
	product_line,
    total,
    CASE
		WHEN total > ( select avg(total) from sales ) THEN 'GOOD'
	ELSE 'BAD'
    END as Review
FROM sales
ORDER by 2 DESC;

-- 10: Which branch sold more products than average product sold? Chi nhánh nào bán được nhiều sản phẩm hơn mức trung bình
SELECT 
	sum(quantity),
	branch
FROM sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- 11: What is the most common product line by gender? Dòng sản phẩm phổ biến nhất theo giới tính là gì?
SELECT
	gender,
    product_line,
    count(gender) as number_of_product
from sales
group by gender, product_line
order by count(product_line) desc;

-- 12: What is the average rating of each product line? Đánh giá trung bình của từng dòng sản phẩm là bao nhiêu?
SELECT 
	product_line,
    avg(rating) as avg_rating
from sales
group by product_line;
----------------------------------------------------------
----------------------------------------------------------
------ SALES ----------------

-- 1: Number of sales made in each time of the day per weekday / Số lượng bán hàng được thực hiện vào mỗi thời điểm trong ngày trong tuần
SELECT
	COUNT(invoice_id) as number_of_sales,
    year(date) as years,
    month(date) as months,
    week(date) as weeks,
    time_of_day
from sales
group by 2,3,4,5
order by 2,3,4,5;

-- 2: Which of the customer types brings the most revenue? Loại khách hàng nào mang lại doanh thu nhiều nhất?
 SELECT
	customer_type,
    sum(total) as revenue
from sales
group by customer_type
order by 2 desc;
    
 -- 3: Which city has the largest tax VAT (Value Added Tax)?  Thành phố nào có  thuế VAT (Thuế giá trị gia tăng) lớn nhất?
SELECT 
	city,
    sum(tax_pct) as VAT
from sales
group by city
order by VAT DESC;

----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- CUSTOMER --
-- 1: How many unique customer types does the data have? Dữ liệu có bao nhiêu loại khách hàng duy nhất?
SELECT
	customer_type
from sales
group by customer_type;
    
-- 2: How many unique payment methods does the data have? Dữ liệu có bao nhiêu phương thức thanh toán duy nhất?
SELECT
	payment
from sales
group by 1;

-- 3: What is the most common customer type?
SELECT
	customer_type,
    count(customer_type) as number_of_customer
from sales
group by 1
order by 2 Desc;

-- 4: What is the gender of most of the customers? Hầu hết khách hàng có giới tính gì?
SELECT 
    gender, COUNT(gender) AS gender
FROM
    sales
GROUP BY 1;

-- 5: What is the gender distribution per branch? / Phân bố giới tính theo từng ngành như thế nào?
select
	gender,
    branch,
    count(gender) as number_of_gender
from sales
group by 1,2
order by 2;


-- 6: When do customers buy the most? Khi nào khách hàng mua nhiều nhất?
select
	time_of_day,
    count(time_of_day) as number_of_bills
from sales
group by 1
order by 2 desc;


-- 7: When do customers buy the most per branch? Khi nào khách hàng mua nhiều nhất chia theo thương hiệu?
select
	time_of_day,
    branch,
    count(time_of_day) as number_of_bills
from sales
group by 1,2
order by 3 desc;

-- 8: Which day fo the week has the best avg ratings? Ngày nào trong tuần có xếp hạng trung bình tốt nhất?
select 
	time_of_day,
    round(avg(rating),2) as avg_rating
from sales
group by 1
order by 2 desc;





