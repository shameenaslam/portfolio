
/* 
Data cleaning  and exploration of different tables using --view,select distinct, update, alter , delete 
change column, set etc)
*/

SELECT 
    markets_name
FROM
    markets;

# delete unwanted market_place with no transaction records in transactions table

DELETE FROM markets 
WHERE
    markets_code IN ('Mark999' , 'Mark097');

# converting us dollars into rupees in transaction table

SELECT DISTINCT
    (currency)
FROM
    transactions;
# two currencies found in transaction table  ie INR and USD

SELECT 
    *
FROM
    transactions
WHERE
    currency = 'usd'
    ;
# converting USD into INR

UPDATE transactions 
SET 
    sales_amount = sales_amount * 79
WHERE
    currency = 'USD';

#checking for calculation error in transaction table

alter table transactions
change column sales_amount  sales_amount  decimal(10,2) DEFAULT NULL ;

alter table transactions
change column profit_margin  profit_margin  decimal(10,2) DEFAULT NULL ;

alter table transactions
change column cost_price  cost_price  decimal(10,2) DEFAULT NULL ;


DELETE FROM transactions 
WHERE
    (sales_amount - cost_price) <> profit_margin;
    
/*
Data exploration and analysis using --join,aliases,temp table, min, max, aggregate,unioun, limit, group by, order by etc--
for visaulization 
*/

USE SALES;

# top 5 product by sales

SELECT 
    product_code,
    SUM(sales_amount) AS sales,
    SUM(profit_margin) AS profit
FROM
    transactions
GROUP BY product_code
ORDER BY sales DESC;

# market growth year wise by sales amount

SELECT 
    m.markets_name,
    SUM(t.sales_amount) AS sales,
    YEAR(order_date) AS YEAR
FROM
    transactions t
        JOIN
    markets m ON t.market_code = m.markets_code
GROUP BY markets_name , YEAR;


# top 5 market  by sales amount

SELECT 
    m.markets_name, SUM(t.sales_amount) AS sales
FROM
    transactions t
        JOIN
    markets m ON t.market_code = m.markets_code
GROUP BY markets_name
ORDER BY sales DESC
LIMIT 5;

# top 5 market  by profit 

SELECT 
    m.markets_name, SUM(t.profit_margin) AS sales
FROM
    transactions t
        JOIN
    markets m ON t.market_code = m.markets_code
GROUP BY markets_name
ORDER BY sales DESC
LIMIT 5;

# OWN BRAND VS DISTRIBUTION SALES COMPARISON

SELECT 
    p.product_type,
    SUM(t.sales_amount),
    YEAR(t.order_date) AS YEAR
FROM
    transactions t
        JOIN
    products p ON t.product_code = p.product_code
GROUP BY product_type , year;



# CUSTOMER TYPE COMPARISON

SELECT 
    c.customers_type, SUM(t.sales_amount)
FROM
    transactions t
        JOIN
    products p ON t.product_code = p.product_code
GROUP BY product_type , year;

#TOP SELLING PRODUCTS

SELECT 
    product_code,
    SUM(sales_amount) AS sales,
    YEAR(order_date) AS YEAR
FROM
    transactions
GROUP BY product_code , YEAR
ORDER BY sales DESC
LIMIT 20;

# monthy sales year wise

select 
d.month_name as month , d.year as YEAR, sum(t.sales_amount) as sales, t.market_code
from 
transactions t
join 
date d on t.order_date = d.date
group by  month, YEAR , t.market_code
order by date ;


select min(order_date)
from transactions;

SELECT 
    SUM(t.sales_amount) AS sales, c.customer_name
FROM
    transactions t
        JOIN
    customers c ON t.customer_code = c.customer_code
GROUP BY c.customer_name
ORDER BY sales DESC
LIMIT 15;

select count(distinct(customer_name))
from customers;

SELECT 
    m.zone AS zone, SUM(t.sales_amount) AS sales
FROM
    transactions t
        JOIN
    markets m ON t.market_code = m.markets_code
GROUP BY zone
ORDER BY sales DESC;

# WHICH CUSTOMERS BOUGHT TOP SELLING PRODUCTS WITH RESPECTIVE MARKETS

CREATE TEMPORARY TABLE new_finance
SELECT 
    product_code,
    SUM(sales_amount) AS sales,
    SUM(profit_margin) AS profit,
    c.customer_name,
    m.markets_name
FROM
    transactions t
        JOIN
    customers c ON t.customer_code = c.customer_code
        JOIN
    markets m ON t.market_code = m.markets_code
GROUP BY product_code , customer_name , markets_code;

#FINDING WHICH PRODUCTS CAN BE GIVEN DICOUNT TO INCREASE SALES

DROP TEMPORARY TABLE  disc_product;
CREATE TEMPORARY TABLE  disc_product
SELECT 
    product_code, SUM(sales_amount) as  sales, SUM(profit_margin) as profit
FROM
    transactions
GROUP BY product_code
ORDER BY profit_margin DESC;

#find profit/sales ratio of top profitable products

ALTER TABLE disc_product
ADD ps_ratio DECIMAL(10,2) DEFAULT NULL;

update disc_product
set ps_ratio = (profit/sales)*100;

SELECT 
    *
FROM
    disc_product
ORDER BY profit DESC;


