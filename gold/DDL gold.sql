/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_date
-- =============================================================================
IF OBJECT_ID('gold.dim_date','U') IS NOT NULL
	DROP VIEW gold.dim_date;
GO

CREATE VIEW  gold.dim_date as 
	SELECT history_date AS calendar 
	FROM silver.calendar
	WHERE YEAR(history_date) < '2017'
GO

-- =============================================================================
-- Create Dimension: gold.dim_territories
-- =============================================================================
IF OBJECT_ID('gold.dim_territories','U') IS NOT NULL
	DROP VIEW gold.dim_territories
GO

CREATE VIEW gold.dim_territories as
	SELECT 
		sales_territory_key as territory_key,
		CASE sales_territory_key
			WHEN 1 THEN 'John Miller'
			WHEN 2 THEN 'Sarah Johnson'
			WHEN 3 THEN 'Michael Davis'
			WHEN 4 THEN 'Emily Rodriguez'
			WHEN 5 THEN 'James Wilson'
			WHEN 6 THEN 'David Thompson'
			WHEN 7 THEN 'Pierre Dubois'
			WHEN 8 THEN 'Hans Schmidt'
			WHEN 9 THEN 'Emma Taylor'
			WHEN 10 THEN 'Oliver Brown'
		END AS territory_name,
		region,
		country,
		continent
	FROM silver.sales_territories
GO

-- =============================================================================
-- Create Dimension: gold.fact_returns
-- =============================================================================
IF OBJECT_ID('gold.fact_returns','U') IS NOT NULL
	DROP VIEW gold.fact_returns
GO

CREATE VIEW gold.fact_returns as
	SELECT  
		r.*,
		ROUND((p.product_price * r.return_quantity),2) as total_value
	from silver.returns as r
	left join silver.products as p
		on r.product_key = p.product_key
	WHERE YEAR(r.return_date) < '2017'
GO

-- =============================================================================
-- Create Dimension: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales','U') IS NOT NULL
	DROP VIEW gold.fact_sales
GO

CREATE VIEW gold.fact_sales as
	select 
		t.order_date,
		t.order_number,
		t.customer_key,
		t.territory_key,
		t.product_key,
		t.order_quantity,
		ROUND(p.product_price,2) as product_price,
		ROUND((p.product_price * t.order_quantity),2) as sales_revenue,
		ROUND(p.product_cost,2) as product_cost,
		ROUND((p.product_cost * t.order_quantity),2) as sales_cost,
		ROUND(((p.product_price * t.order_quantity) - (p.product_cost * t.order_quantity)),2) as profit
	from(
		select * from silver.sales2015
		union all
		select * from silver.sales2016
	) t
	left join silver.products as p
		on t.product_key=p.product_key
	order by order_date;
GO

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers','U') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW  gold.dim_customers as 
	WITH customers as 
	(
		SELECT c.[customer_key]
			  ,CONCAT(c.[first_name],' ',c.[last_name]) as customer_name
			  ,CASE c.[marital_status] 
					WHEN 'M' THEN 'Married'
					WHEN 'S' THEN 'Single'
					ELSE 'n/a'
			   END as marital_status
			  ,CASE c.[gender]
					WHEN 'F' THEN 'Female'
					WHEN 'M' THEN 'Male'
					ELSE 'n/a'
				END AS gender
			  ,DATEDIFF(year,c.birthdate,'2017-01-01') as customer_age
			  ,c.[annual_income]
			  ,c.[total_children]
			  ,c.[education_level]
			  ,c.[occupation]
			  ,c.[home_owner]
			  ,DATEDIFF(DAY,max(s.order_date),'2017-01-01') as last_order
			  ,COUNT(distinct s.order_number) as total_orders
			  ,ROUND((SUM(s.order_quantity * p.product_price)),2) as Total_spend
			  FROM [SalesService].silver.[customers] as c
		left join 
		 (select * from silver.sales2015
			union all
			select * from silver.sales2016
		 ) as s
			ON  c.customer_key = s.customer_key
		left join silver.products as p
			on s.product_key = p.product_key
		GROUP BY 
			c.[customer_key],
			c.[first_name],
			c.[last_name],
			c.[marital_status],
			c.[gender],
			c.[birthdate],
			c.[annual_income],
			c.[total_children],
			c.[education_level],
			c.[occupation],
			c.[home_owner]
		--order by DATEDIFF(year,c.birthdate,'2016-12-31')
	) 
	, RFM as
	(
	SELECT 
		customer_key,
		customer_name,
		marital_status,
		gender,
		CASE 
			WHEN customer_age <= 36 THEN '<=36'
			WHEN customer_age between 36 and 50 THEN '36 - 50'
			WHEN customer_age between 51 and 60 THEN '51 - 60'
			WHEN customer_age between 61 and 70 THEN '61 - 70'
			WHEN customer_age between 71 and 80 THEN '71 – 80'
			WHEN customer_age between 81 and 90 THEN '81 – 90'
			WHEN customer_age between 91 and 100 THEN '91 – 100'
			ELSE '+100'
		END AS customer_age_group,
		CASE
			WHEN annual_income <= 50000 THEN 'low_income (<=50K)'
			WHEN annual_income between 50001 and 100000 THEN 'Medium_income (50 - 100K)'
			ELSE 'high_income (>=100K)'
		END AS annual_income_segment,
		CASE
			WHEN total_children = 0 THEN 'No Children'
			WHEN total_children BETWEEN 1 AND 2 THEN 'Small Family'
			WHEN total_children BETWEEN 3 AND 4 THEN 'Medium Family'
			ELSE 'Large Family'
		END AS Family_Size,
		CASE
			WHEN last_order <= 30  THEN 5
			WHEN last_order <= 60  THEN 4
			WHEN last_order <= 120 THEN 3
			WHEN last_order <= 240 THEN 2
			ELSE 1
		END AS Recency ,
		CASE
			WHEN total_orders >= 12 THEN 5
			WHEN total_orders >= 8  THEN 4
			WHEN total_orders >= 5  THEN 3
			WHEN total_orders >= 3  THEN 2
			ELSE 1
		END AS Frequency ,
		CASE
			WHEN Total_spend >= 8000 THEN 5
			WHEN Total_spend >= 4000 THEN 4
			WHEN Total_spend >= 2000 THEN 3
			WHEN Total_spend >= 500  THEN 2
			ELSE 1
		END AS Monetary,
		education_level,
		occupation,
		home_owner
	FROM customers
	where total_orders is not null
	)

	SELECT 
		customer_key,customer_name,
		marital_status,gender,
		customer_age_group,
		annual_income_segment,
		Family_Size,
		Recency,Frequency,Monetary,
		education_level,
		occupation,home_owner,
		CASE
			-- Champions: الأفضل في كل شيء
			WHEN Recency BETWEEN 4 AND 5 AND Frequency BETWEEN 4 AND 5 AND Monetary BETWEEN 4 AND 5 THEN 'Champions'    
			-- Cannot Lose Them: صرفوا كتير واختفوا (أولوية قصوى)
			WHEN Recency BETWEEN 1 AND 2 AND Frequency BETWEEN 4 AND 5 AND Monetary BETWEEN 4 AND 5 THEN 'Cannot Lose Them'
			-- At Risk: كانوا كويسين وبعدوا
			WHEN Recency BETWEEN 1 AND 2 AND Frequency BETWEEN 3 AND 5 AND Monetary BETWEEN 3 AND 5 THEN 'At Risk'    
			-- Loyal: متكررين، متوسط الصرف
			WHEN Recency BETWEEN 3 AND 5 AND Frequency BETWEEN 3 AND 5 AND Monetary BETWEEN 2 AND 4 THEN 'Loyal Customers'    
			-- Hibernating: صرفوا غالي ومشوا (أي R، F منخفض، M عالي)
			WHEN Frequency BETWEEN 1 AND 2 AND Monetary BETWEEN 4 AND 5 THEN 'Hibernating'    
			-- New: جُدد (R عالي، F=1، M أي قيمة)
			WHEN Recency BETWEEN 4 AND 5 AND Frequency = 1 THEN 'New'    
			-- Promising: محتملين (R متوسط-عالي، F منخفض، M متوسط)
			WHEN Recency BETWEEN 3 AND 5 AND Frequency BETWEEN 1 AND 2 AND Monetary BETWEEN 2 AND 3 THEN 'Promising'    
			-- Lost: ميتين
			WHEN Recency = 1 AND Frequency = 1 AND Monetary = 1 THEN 'Lost'
			-- Need Attention: الباقي المتوسط		
			WHEN Recency BETWEEN 2 AND 3 AND Frequency BETWEEN 2 AND 3 AND Monetary BETWEEN 2 AND 3 
			THEN 'Need Attention'  
			ELSE 'Other'
		END AS RFM_Segmentation ,
		CASE
			-- A: القمة (strict)
			WHEN annual_income_segment = 'high_income (>=100K)' 
				 AND education_level IN ('Graduate Degree', 'bachelors')
				 AND occupation IN ('Professional', 'Management')
				 AND home_owner = 'yes'
				 AND family_size IN ('No Children', 'Small Family')
				THEN 'A'
    
			-- B: متوسط-عالي
			WHEN annual_income_segment = 'Medium_income (50 - 100K)'
				 AND education_level IN ('Graduate Degree', 'bachelors')
				 AND occupation IN ('Professional', 'Management')
				THEN 'B'
    
			-- C: الكتلة
			WHEN annual_income_segment = 'Medium_income (50 - 100K)'
				 AND education_level IN ('High School', 'Partial College', 'Partial High School')
				 AND occupation IN ('Skilled Manual', 'manual', 'Clerical')
				THEN 'C'
    
			-- D: محدود مستقر
			WHEN annual_income_segment = 'low_income (<=50K)'
				 AND home_owner = 'yes'
				THEN 'D'
    
			-- E: ضغط مالي عالي
			WHEN annual_income_segment = 'low_income (<=50K)'
				THEN 'E'
    
			-- === FALLBACKS للـ NULL ===
    
			-- High income بأي حال → B (غير A)
			WHEN annual_income_segment = 'high_income (>=100K)'
				THEN 'B'
    
			-- Medium income + أي تعليم → C
			WHEN annual_income_segment = 'Medium_income (50 - 100K)'
				THEN 'C'
    
			-- أي حاجة تانية → E (أقل فئة)
			ELSE 'E'
    
		END AS customer_class
	FROM RFM
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products','U') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW  gold.dim_products as 

	with products as 
	(
		SELECT c.category_key,c.category_name,
			s.subcategory_key,s.subcategory_name,
			p.product_key,p.product_sku,p.product_name,p.model_name,
			p.product_description,p.product_color,p.product_style,
			p.product_size,p.product_cost,p.product_price
		FROM silver.category as c
		JOIN silver.subcategory as s
			ON c.category_key=s.category_key
		JOIN silver.products as p
			ON s.subcategory_key=p.subcategory_key
	) 
	, pareto as
	(
		SELECT p.category_key,p.category_name,
				p.subcategory_key,p.subcategory_name,
				p.product_key,p.product_sku,p.product_name,p.model_name,
				p.product_description,p.product_color,p.product_style,
				p.product_size,p.product_cost,p.product_price ,
				ROUND(SUM(s.sales_revenue),2) as product_sales,ROUND(SUM(s.profit),2) as product_profit
		FROM products as p
		LEFT JOIN gold.fact_sales as s
			ON p.product_key = s.product_key
		GROUP BY p.category_key,p.category_name,
				p.subcategory_key,p.subcategory_name,
				p.product_key,p.product_sku,p.product_name,p.model_name,
				p.product_description,p.product_color,p.product_style,
				p.product_size,p.product_cost,p.product_price
		--ORDER BY category_key,subcategory_key,product_key
	)
	, pareto_analysis as
	(
		SELECT category_key,category_name,subcategory_key,subcategory_name,
			product_key,product_sku,product_name,model_name,product_description,
			product_color,product_style,product_size,product_cost,product_price,
			product_sales,product_profit,
			ROUND(product_sales / SUM(product_sales) OVER() *100 , 2) as Sales_pct,
			ROUND(product_profit / SUM(product_profit) OVER() *100 , 2) as Profit_pct,
			ROUND(PERCENT_RANK() OVER(order by product_sales) , 2) as Sales_rank,
			ROUND(PERCENT_RANK() OVER(order by product_profit) , 2) as profit_rank
		FROM pareto
	)
	,final_analysis as
	(
		SELECT category_key,category_name,subcategory_key,subcategory_name,
				product_key,product_sku,product_name,model_name,product_description,
				product_color,product_style,product_size,product_cost,product_price,
				product_sales,product_profit,Sales_pct,Profit_pct,Sales_rank,profit_rank,
				CASE 
					WHEN Sales_rank >= 0.8 THEN 'High'
					WHEN Sales_rank between 0.2 and 0.8 THEN 'Medium'
					WHEN Sales_rank <= 0 THEN 'No sales'
					WHEN Sales_rank <= 0.2 THEN 'Low'
					ELSE 'No sales'
				END AS sales_pareto,
				CASE 
					WHEN profit_rank >= 0.8 THEN 'High'
					WHEN profit_rank between 0.2 and 0.8 THEN 'Medium'
					WHEN profit_rank <= 0 THEN 'No profit'
					WHEN profit_rank <= 0.2 THEN 'Low'
					ELSE 'No profit'
				END AS profit_pareto
		FROM pareto_analysis
	)

	SELECT category_key,category_name,subcategory_key,subcategory_name,
			product_key,product_sku,product_name,model_name,product_description,
			product_color,product_style,product_size,product_cost,product_price,
			product_sales,product_profit,Sales_pct,Profit_pct,Sales_rank,profit_rank,
			sales_pareto,profit_pareto,
			CASE
				-- High Sales
				WHEN sales_pareto = 'High' AND profit_pareto = 'High' THEN 'Core Product'
				WHEN sales_pareto = 'High' AND profit_pareto = 'Medium' THEN 'Volume Driver'
				WHEN sales_pareto = 'High' AND profit_pareto = 'Low' THEN 'Discount Trap'
    
				-- Medium Sales
				WHEN sales_pareto = 'Medium' AND profit_pareto = 'High' THEN 'Rising Star'
				WHEN sales_pareto = 'Medium' AND profit_pareto = 'Medium' THEN 'Standard'
				WHEN sales_pareto = 'Medium' AND profit_pareto = 'Low' THEN 'Weak Performer'
    
				-- Low Sales
				WHEN sales_pareto = 'Low' AND profit_pareto = 'High' THEN 'Hidden Gem'
				WHEN sales_pareto = 'Low' AND profit_pareto = 'Medium' THEN 'Hidden Potential'
				WHEN sales_pareto = 'Low' AND profit_pareto = 'Low' THEN 'Dead Product'
    
				ELSE 'Unknown'
			END AS product_segment
	FROM final_analysis

GO