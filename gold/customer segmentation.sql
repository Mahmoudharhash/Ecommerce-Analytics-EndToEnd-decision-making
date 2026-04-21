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
    END AS Family_Segment,
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
