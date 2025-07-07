use mavenfuzzyfactory;
/*
-- I: PHÂN TÍCH THEO SESSION
-- 1: Traffic and Sesion Overview
Tổng số session, by source, campaign, content, device
Tổng số Users
New vs Returning Users
Avg session Duration
Avg Page per Sesison



-- 2: Conversion-Related Metrics
Conversion Rate per Session
Cart Abandonment Rate
Bid Optimization (nguồn nào tạo nhiều orders)

*/

-- 1: Traffic and Session Overview
-- Tổng session
SELECT COUNT(*) as No_Sessions
	FROM website_sessions;

-- Tổng session theo source, campaign, content, device
SELECT 
	utm_source,
    utm_campaign,
    utm_content,
    device_type,
		COUNT(*) as No_Sessions
	FROM website_sessions
    GROUP BY 1,2,3,4
    ORDER BY 5 desc;

-- Số lượng user so với số lượng session
SELECT 
	count( distinct user_id) as No_Users,
    count( distinct website_session_id) as No_sessions
FROM website_sessions;

SELECT 
	case when is_repeat_session = 0 then "new_user"
    else "returning_user"
    end as user_type,
        count(*) as No_Sessions
FROM website_sessions
GROUP BY  1
ORDER BY 2 desc;


-- Avg session Duration
WITH session_durations AS 
(
SELECT 
	website_session_id,
	TIMESTAMPDIFF(SECOND, min(created_at), max(created_at)) AS session_duration
FROM website_pageviews
GROUP BY website_session_id
)
SELECT
	SEC_TO_TIME(
				ROUND(AVG(session_duration))
                ) as Avg_session_duration
FROM session_durations;

-- Avg page per Sessions
SELECT
    count(*) / COUNT( DISTINCT website_session_id ) as Avg_page_per_sesisons
FROM website_pageviews;

-- 2: Conversion-Related Metrics
-- Conversion Rate per Session
select 
		count(A.website_session_id) as No_session,
        count(B.order_id) as No_Orders,
        count(B.order_id) / count(A.website_session_id) as Conversion_Rate
FROM website_sessions A 
left join orders B
on A.website_session_id = B.website_session_id;


-- Cart Abandonment Rate
-- tổng số session có trang cart (dù mua hay k) / tổng session có trang cart nhưng k mua

WITH session_with_cart AS 
(
  SELECT DISTINCT A.website_session_id
  FROM website_sessions A
  LEFT JOIN website_pageviews B
    ON A.website_session_id = B.website_session_id
  WHERE B.pageview_url LIKE '%/cart%'
), -- lấy webiste_session_id có truy cập vào trang cart (dù mua hàng hay không)

abandoned_session AS 
(
  SELECT C.website_session_id
  FROM session_with_cart C
  LEFT JOIN orders D
    ON C.website_session_id = D.website_session_id
  WHERE D.website_session_id IS NULL
) -- website_session_id có truy cập trang cart nhưng k có order (k mua hàng)

SELECT 
  COUNT(ab.website_session_id) * 100.0 / COUNT(sc.website_session_id) AS cart_abandonment_rate_percent
FROM session_with_cart sc
LEFT JOIN abandoned_session ab
  ON sc.website_session_id = ab.website_session_id;
   

-- Bid optimization
SELECT
	utm_source,
	count(A.website_session_id) as No_Sessions,
    count(B.website_session_id) as NO_Orders,
    count(B.website_session_id) / count(A.website_session_id) AS Conversion_Rate
FROM website_sessions A
LEFT JOIN orders B
	on A.website_session_id = B.website_session_id
GROUP BY A.utm_source;



/*
II: PHÂN TÍCH THEO WEBSITE_PAGEVIEWS
1: tổng số lượt xem  trang
2: unique pageviews lượt xem không trùng lặp theo session
3: Session with each Page

5: Avg.time on page: thời gian trung bình ở mỗi trang
6: Bounce Rate
7: Exit rate: tỷ lệ phiên kết thúc tại trang
8: First Page in session
9: Last Page in session
10: Page Depth

*/

-- Tổng số lượt xem trang
SELECT
	COUNT(*)
    FROM website_pageviews;
    
 
 -- Tổng số UNIQUE PAGEVIEWS
 SELECT
	COUNT( DISTINCT website_session_id, pageview_url)
  FROM website_pageviews;
 
-- Session with each page
SELECT 
  pageview_url,
  COUNT(DISTINCT website_session_id) AS sessions_with_pageview
FROM website_pageviews
GROUP BY pageview_url
ORDER BY sessions_with_pageview DESC;

-- Thời gian trung bình ở mỗi trang
-- Bước 1: lấy ra pageview_url và next_pageview_url
-- WITH page_times AS
WITH page_time AS
(
SELECT 
	website_session_id,
    pageview_url,
    created_at,
    LEAD(created_at)
    OVER( 
		PARTITION BY website_session_id
        ORDER BY created_at
        ) AS next_page_time
	FROM website_pageviews
)
SELECT -- Tính trung bình và group by theo pageview_url
	pageview_url,
    sec_to_time(
				ROUND(
						AVG(timestampdiff(second, created_at, next_page_time))
                    )
				) as AVG_TIME_PAGE
FROM page_time
WHERE next_page_time is NOT NULL
GROUP BY pageview_url;
    



-- 6: BOUNCE RATE
-- đếm số pageview_url theo từng session_id
WITH session_page_counts AS
(
SELECT 
	website_session_id,
    count(website_pageview_id) as No_Pageviews
FROM website_pageviews
GROUP BY website_session_id
)
SELECT
	COUNT(
			CASE WHEN No_Pageviews = 1 THEN 1 END
		)
        / 
        COUNT(*) as BOUNCE_RATE
FROM session_page_counts;

-- EXIT PAGE
-- lấy session có >= 2 pageview_url
-- Nhóm pageview theo từng session_id và sắp xếp theo từ lớn > nhỏ (row_number)
-- lấy ra các pageview_url đầu tiên
-- đếm chúng

WITH ranked_pagview AS 
(
SELECT 
	website_session_id,
    pageview_url,
    row_number() 
		OVER (
		Partition by website_session_id
		order by created_at desc
        ) as rn
    FROM website_pageviews
) 
SELECT
	pageview_url,
    count(*) as exit_count
FROM ranked_pagview
WHERE rn = 1
group by pageview_url
order by 2 desc;


-- First page in session
WITH ranked_pagevew AS
(
SELECT
	pageview_url,
    row_number() OVER (
    partition by website_session_id
    order by created_at
    ) as rn
FROM website_pageviews
)
SELECT 
	pageview_url,
    count(*) as No_Sessions
FROM ranked_pagevew
where rn = 1
GROUP BY pageview_url
ORDER BY 2 DESC;


/* Metrics về Order
1: Về số lượng Đơn hàng
Number of Orders
Phân phối số lượng đơn hàng
Orders per Customer
Repeat Order Rate
New vs Returning Order Ratio

2: Metrics về Items
Number of Orders Single-Item
Number of Orders Multi-Items 
Cross Sales
AIPO

3: Về giá trị đơn hàng
AOV
Median Order value
High-value Orders
Low-value Order

4: Trạng thái đơn hàng
Return Rate

*/

-- 1 về số lượng đơn hàng
SELECT
	count(*) as Number_Of_Orders
    FROM orders;
    
-- thống kê số đơn hàng theo source
SELECT
	count(A.order_id) as Number_of_Orders,
    B.utm_source
FROM orders A
LEFT JOIN website_sessions B
ON A.website_session_id = B.website_session_id
GROUP BY B.utm_source;

-- Thống kê số đơn hàng theo new vs repeat session
SELECT
	count(A.order_id) as Number_of_Orders,
    B.is_repeat_session
FROM orders A
LEFT JOIN website_sessions B
ON A.website_session_id = B.website_session_id
GROUP BY B.is_repeat_session;

-- 2: Metrics về Items
-- Thống kê theo số Item trong đơn hàng
SELECT
	count(order_id),
    items_purchased
FROM orders
GROUP BY items_purchased;

-- tại orders có 1 item
SELECT
	count(A.order_id) as Number_of_Orders_single_items,    
    C.product_name
FROM orders A
LEFT JOIN order_items B
on A.order_id = B.order_id
LEFT JOIN products C 
on B.product_id = C.product_id
WHERE items_purchased = 1
group by C.product_name;

-- Thống kê đơn hàng có trên 2 sản phẩm và có sản phẩm đầu tiên là
-- (thống kê đơn hàng có >= 2 item)
-- ( thống kê đơn có is_primary_item = 1) là item đầu tiên
SELECT
	count(A.order_id) as No_Orders,
    C.product_name
FROM orders A 
LEFT JOIN order_items B
ON A.order_id = B.order_id
LEFT JOIN products C
on B.product_id = C.product_id
WHERE A.items_purchased >= 2 and B.is_primary_item = 1
GROUP BY C.product_name;


-- Thống kê đơn hàng cross sale của "The Orginal Mr.Fuzzy"

WITH Cross_Sales_Fuzzy AS
(
SELECT
	A.order_id
FROM orders A 
LEFT JOIN order_items B
ON A.order_id = B.order_id
LEFT JOIN products C
on B.product_id = C.product_id
WHERE A.items_purchased >= 2 and B.is_primary_item = 1 and C.product_name = "The Original Mr. Fuzzy"
)

SELECT
	count( DISTINCT t.order_id) as No_orders,
    Count( CASE WHEN B.product_id = 2 then B.product_id ELSE NULL END ) AS Love_Bear,
    Count( CASE WHEN B.product_id = 3 then B.product_id ELSE NULL END ) AS Sugar_Panda,
    Count( CASE WHEN B.product_id = 4 then B.product_id ELSE NULL END ) AS Mini_bear
FROM Cross_Sales_Fuzzy t
LEFT JOIN order_items B
on t.order_id = B.order_id;

-- 3 Giá trị đơn ahngf
-- AOV

SELECT
	sum(price_usd)  / COUNT(DISTINCT order_id) AS AOV
FROM order_items;

-- 4: Trạng thái đơn hàng
-- Order Return Rate
SELECT
	count(B.order_id) /
    count(A.order_id) as Order_Return_Rate
FROM orders A
LEFT JOIN order_item_refunds B
on A.order_id = B.order_id;

-- Order Item Return Rate

SELECT
	count(B.order_item_id) /
    count(A.order_item_id) as Return_Rate
FROM order_items A
Left JOIN order_item_refunds B
on A.order_item_id = B.order_item_id


    







    



    





    


