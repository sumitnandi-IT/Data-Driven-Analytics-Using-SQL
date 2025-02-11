
WITH cte1 AS 
	 (
SELECT 
	 fsm.date,fsm.fiscal_year, fsm.product_code, fsm.customer_code,dc.market dp.product, dp.variant, fsm.sold_quantity, fgp.gross_price, 
	 ROUND(fsm.sold_quantity * fgp.gross_price,2) as gross_price_total, pre_invoice_discount_pct

FROM 
	 fact_sales_monthly fsm
JOIN
	 dim_product dp USING (product_code)
JOIN 
	 dim_customer dc USING (customer_code)
JOIN 
	 fact_gross_price fgp ON fsm.product_code = fgp.product_code AND fsm.fiscal_year = fgp.fiscal_year
JOIN
	 fact_pre_invoice_deductions fpid 
     ON fsm.customer_code = fpid.customer_code AND fsm.fiscal_year = fpid.fiscal_year
     )
     
 # Creating a view, so that our sql query donesn't become complex. we can simply create a virtual table using views and use it as a table.    
     
SELECT 
	 *, (gross_price_total - gross_price_total*pre_invoice_discount_pct) as net_invoice_sales 
FROM 
	 sales_preinv_discount;
     
     
# Merging post_invoice_deductions table and creating a view for post_invoice_discounts


SELECT 
	 spd.date, spd.fiscal_year, spd.product_code, spd.customer_code, spd.market,
     spd.product, spd.variant, spd.sold_quantity, spd.gross_price_total, spd.pre_invoice_discount_pct,
	 (gross_price_total - gross_price_total*pre_invoice_discount_pct) as net_invoice_sales, 
     (pid.discounts_pct+pid.other_deductions_pct) as post_invoice_discount_pct
FROM 
	 sales_preinv_discount spd
JOIN
	 fact_post_invoice_deductions pid
     ON spd.customer_code = pid.customer_code AND spd.date = pid.date AND spd.product_code = pid.product_code;
     
# calculating net sales then creating a view for net_sale
     
SELECT 
	 *,
     (net_invoice_sales - net_invoice_sales*post_invoice_discount_pct) as net_sales
FROM
	 sales_postinv_discount;
     


# 1. Top Markets by Net Sales(Store procedures included) :

SELECT
	 market, 
     round(sum(net_sales)/1000000,2) as net_sales_mln
FROM 
	 net_sales
WHERE
	 fiscal_year = 2021
GROUP BY
	 market
ORDER BY
	 net_sales_mln DESC
LIMIT 5;


# 2. Top Customers by Net Sales(Store procedures included) :

SELECT
	 customer,
     round(sum(net_sales)/1000000,2) as net_sales_mln
FROM
	 Net_sales ns
JOIN
	 dim_customer dc ON ns.customer_code = dc.customer_code
WHERE
	 ns.fiscal_year = 2021 AND ns.market = "India"
GROUP BY
	 customer
ORDER BY
	 net_sales_mln DESC
LIMIT 5;

# 3.  Top Products by Net Sales(Store procedures included) :

SELECT
	 product, 
     round(sum(net_sales)/1000000,2) as net_sales_mln
FROM 
	 net_sales
WHERE
	 fiscal_year = 2021
GROUP BY
	 product
ORDER BY
	 net_sales_mln DESC
LIMIT 5;