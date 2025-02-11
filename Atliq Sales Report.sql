# find customer codes for Croma india

SELECT * FROM dim_customer WHERE customer like "%croma%" AND market="india";



# Get all the sales transaction data from fact_sales_monthly table for that customer in the fiscal_year 2021
	
SELECT 
	 * FROM fact_sales_monthly 
WHERE 
     customer_code=90002002 AND YEAR(DATE_ADD(date, INTERVAL 4 MONTH)) = 2021 
ORDER BY 
	  date ASC;
	
    

# filtering the fact_sales_monthly table by croma and fiscal_year later creating get_fiscal_quater function

SELECT 
	 * 
FROM 
	 fact_sales_monthly 
WHERE 
	 customer_code=90002002 AND get_fiscal_year(date)=2021  AND get_fiscal_quater(date) = "Q3"
ORDER BY 
	 date ASC;



# Monthly Product Transactions( Printing product name, variant and merging gross price and showing total gross price)

SELECT 
	 s.date, s.product_code, p.product, p.variant, s.sold_quantity, g.gross_price,
	 ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total
FROM 
	 fact_sales_monthly s
JOIN 
	 dim_product p ON s.product_code=p.product_code
JOIN 
	 fact_gross_price g ON g.fiscal_year=get_fiscal_year(s.date) AND g.product_code=s.product_code
WHERE 
     customer_code=90002002 AND get_fiscal_year(s.date)=2021;
     
     
     
# Generating monthly gross sales report for Croma India for all the years
	
    
SELECT 
	 s.date, 
     SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
FROM 
	 fact_sales_monthly s
JOIN 
	 fact_gross_price g ON g.fiscal_year = get_fiscal_year(s.date) AND g.product_code = s.product_code
WHERE 
	 customer_code=90002002
GROUP BY 
	 date;
     
     
# Created stored procedure for the above
# Created a marget badge store procedure.