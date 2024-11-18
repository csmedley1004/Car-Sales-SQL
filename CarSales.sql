Skills used: Temp Tables, Windows Functions, Aggregate Functions, Data Cleansing


#EDA on count of sales per state 

select state, count(*)
from carsales.car_prices
group by state;


#EDA Identifies a list of unrecognizable states all with a count of one, very closely resembling VIN values

select * 
from carsales.car_prices
where length(state)>2;


#After looking more closely at these rows it appears many of the data for Volkswagen Jettas has imported incorectly and looking more closely at the csv identifies missing selling dates
#Uniquely all data of this type can be identified by the value "Navitgation" under column body and thus a temporary table will be created to allow manipulation of only valid data. 

Create temporary table CarPricesValid As
select * 
from car_prices
where body != "Navitgation"


#Uncovering which makes and models are most popular 

select make, model, count(*) as sales 
from CarPricesValid
group by make,model
order by 3 desc


#Further incomplete data has appeared where make and model appear as empty string 
#Dropping and adjusting our temporary table accordingly 

drop table CarPricesValid; 

Create temporary table CarPricesValid As
select * 
from car_prices
where body != "Navitgation"
and make != '';


#Average selling price per car (make + model)

select make,model, avg(sellingprice)
from CarPricesValid
group by make,model 
order by 2


#Analyzing sale data over time periods 
#Converting sale date column into more usable columns 
select saledate,
mid(saledate,12,4) As SaleYear,
mid(saledate,5,3) As SaleMonth,
Case mid(saledate,5,3)
	When 'Jan' then 1
    When 'Feb' then 2 
    When 'Mar' then 3
    When 'Apr' then 4
    When 'May' then 5 
    When 'Jun' then 6
    When 'Jul' then 7
    When 'Aug' then 8
    When 'Sep' then 9
    When 'Oct' then 10
    When 'Nov' then 11
    When 'Dec' then 12 
End as sale_month
from CarPricesValid


#Updating temp table with new colums 

drop table CarPricesValid;

Create temporary table CarPricesValid As
select 
'year' manufactured_year,
make, 
model,
trim,
body,
transmission,
vin,
state,
'condition' as car_condition,
odometer,
color,
interior,
seller,
mmr,
sellingprice,
saledate,
mid(saledate,12,4) As SaleYear,
mid(saledate,5,3) As SaleMonth,
Cast(Case mid(saledate,5,3)
	When 'Jan' then 1
    When 'Feb' then 2 
    When 'Mar' then 3
    When 'Apr' then 4
    When 'May' then 5 
    When 'Jun' then 6
    When 'Jul' then 7
    When 'Aug' then 8
    When 'Sep' then 9
    When 'Oct' then 10
    When 'Nov' then 11
    When 'Dec' then 12
    else null 
End as unsigned) as sale_month
from car_prices
where body != "Navitgation"
and make != ''
and saledate != '';

#Caluclating average sale price per year and month 

select SaleYear, sale_month, avg(sellingprice) as AvgSellPrice
from CarPricesValid 
group by 1,2 
order by 1,2 


#Calculating months with highest sales volume

select sale_month, count(*)
from CarPricesValid
Group by 1
Order by 2 desc

#Previous query identifies a number of sales with null sale months due to empty string in sale date
#Temporary table is dropped and reintroduced to not include such data 


#Top 5 selling models for each body type
SELECT 
    make, model, body, vol_sales, body_rank 
FROM (
    SELECT 
        make,
        model,
        body,
        COUNT(*) AS vol_sales,
        RANK() OVER (PARTITION BY body ORDER BY COUNT(*) DESC) AS body_rank
    FROM CarPricesValid
    GROUP BY make, model, body
) AS ranked_data
WHERE body_rank <= 5
ORDER BY body ASC, vol_sales DESC;


#Brand analysis 
SELECT make, 
       COUNT(DISTINCT model) AS num_models,
       COUNT(*) AS num_sales,
       MIN(sellingprice) AS min_price,
       MAX(sellingprice) AS max_price
FROM CarPricesValid
GROUP BY make;





