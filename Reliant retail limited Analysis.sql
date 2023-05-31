/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  
both first name and last name are in upper case, customer_email,  customer_creation_year
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
[Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date, 
no permanent change in the table is required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation. 
A new column name can be used as an alias for your manipulation in case if you are going to
use a CASE statement.) 
*/
## Answer 1.
SELECT customer_id,
CONCAT(IF(customer_gender = "M","Mr","Ms"), ' ', UPPER(customer_fname), ' ', UPPER(customer_lname)) as Full_name, 
customer_email,
YEAR(customer_creation_date) as Creation_Year,
CASE
    WHEN YEAR(customer_creation_date) < 2005  THEN 'category A'
    WHEN YEAR(customer_creation_date)>= 2005 AND YEAR(customer_creation_date)< 2011 THEN 'category B'
    ELSE 'category C'
    END As 'Category'
FROM ONLINE_CUSTOMER;
---------------------------------------------------------------------------------------------------------------------
/* Q2. Write a query to display the following information for the products which have 
not been sold: product_id, product_desc, product_quantity_avail, product_price,
inventory values (product_quantity_avail * product_price), 
New_Price after applying discount as per below criteria. 
Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use 
 a CASE statement.)
*/
## Answer 2.
SELECT p.product_id, product_desc, product_quantity_avail, product_price, 
p.product_quantity_avail *p.product_price AS inventory_value,
CASE WHEN p.product_price > 200000 THEN (p.product_price - (p.product_price*0.20))
	 WHEN p.product_price > 100000 AND p.product_price <= 200000 THEN (p.product_price - (p.product_price*0.15))
     WHEN p.product_price <= 100000 THEN (p.product_price - (p.product_price*0.10)) 
    END As 'New_Price'
FROM product p
WHERE p.product_id NOT IN (SELECT o.product_id FROM order_items o)
ORDER BY inventory_value DESC;
--------------------------------------------------------------------------------------------------------------------------
/*Q3. Write a query to display Product_class_code, Product_class_desc,
 Count of Product type in each product class, 
 Inventory Value (p.product_quantity_avail*p.product_price). 
 Information should be displayed for only those product_class_code 
 which have more than 1,00,000 Inventory Value.
 Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/
## Answer 3.
SELECT p.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC, COUNT(pc.PRODUCT_CLASS_CODE) AS PRODUCT_COUNT,
SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM product AS p LEFT JOIN PRODUCT_CLASS AS pc ON  p.PRODUCT_CLASS_CODE =  pc.PRODUCT_CLASS_CODE
GROUP BY p.PRODUCT_CLASS_CODE HAVING INVENTORY_VALUE > 100000
ORDER BY INVENTORY_VALUE DESC;
----------------------------------------------------------------------------------------------------------------------------
/* Q4. Write a query to display customer_id, full name, customer_email, 
customer_phone and country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
## Answer 4.
SELECT h.CUSTOMER_ID, CONCAT(UPPER(o.CUSTOMER_FNAME),' ',UPPER(o.CUSTOMER_LNAME)) AS CUSTOMER_FULL_NAME , 
o.CUSTOMER_EMAIL, o.CUSTOMER_PHONE,a.COUNTRY
FROM order_header AS h
LEFT JOIN online_customer AS o ON h.CUSTOMER_ID = o.CUSTOMER_ID
LEFT JOIN address AS a ON o.ADDRESS_ID = a.ADDRESS_ID
WHERE h.customer_id IN  (SELECT customer_id FROM order_header WHERE order_status='Cancelled')
GROUP BY h.CUSTOMER_ID HAVING COUNT(DISTINCT h.ORDER_STATUS) = 1;
-----------------------------------------------------------------------------------------------------------------------------
/* Q5. Write a query to display Shipper name, City to which it is catering, 
num of customer catered by the shipper in the city , 
number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. 
The main intent is to find the number of customers and the consignments catered by DHL in each city.
 */
## Answer 5. 
SELECT s.shipper_name, a.city, COUNT(DISTINCT o.customer_id) AS No_of_Customers, COUNT(a.address_id) AS Consignment_Delivered
FROM online_customer o INNER JOIN address a ON o.address_id = a.address_id
INNER JOIN order_header h ON h.customer_id = o.customer_id
INNER JOIN shipper s ON s.shipper_id = h.shipper_id
WHERE s.shipper_name = 'DHL'
GROUP BY a.city;
------------------------------------------------------------------------------------------------------------------------------
/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold 
and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 
b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status
(Low stock, In stock, and Enough stock) that meets both the conditions i.e. on products as well as on quantity
The meaning of the rest of the categories, means products apart from electronics,computers,mobiles and watches
*/
## Answer 6.
SELECT a.*,
CASE WHEN a.product_class_desc = 'Electronics' OR a.product_class_desc = 'Computer' THEN
     CASE WHEN a.Quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
	 WHEN a.product_quantity_avail < a.Quantity_sold*0.10 THEN 'Low inventory, need to add inventory'
	 WHEN a.Quantity_sold*0.10 >= a.product_quantity_avail < a.Quantity_sold*0.50 THEN 'Medium inventory, need to add some inventory'
     WHEN a.product_quantity_avail >= a.Quantity_sold*0.50 THEN 'Sufficient inventory' END
WHEN a.product_class_desc = 'Mobiles' OR a.product_class_desc = 'Watches' THEN	
	CASE WHEN a.Quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
    WHEN a.product_quantity_avail < a.Quantity_sold*0.20 THEN 'Low inventory, need to add inventory'
    WHEN a.Quantity_sold*0.20 >= a.product_quantity_avail < a.Quantity_sold*0.60 THEN 'Medium inventory, need to add some inventory'
    WHEN a.product_quantity_avail >= a.Quantity_sold*0.60 THEN 'Sufficient inventory' END
ELSE 
	CASE WHEN a.Quantity_sold = 0 THEN 'No Sales in past, give discount to reduce inventory'
	WHEN a.product_quantity_avail < a.Quantity_sold*0.30 THEN 'Low inventory, need to add inventory'
    WHEN a.Quantity_sold*0.30 >= a.product_quantity_avail < a.Quantity_sold*0.70 THEN 'Medium inventory, need to add some inventory'
    WHEN a.product_quantity_avail >= a.Quantity_sold*0.70 THEN 'Sufficient inventory' END
	END AS Inventory_Status
FROM
(SELECT p.product_id, p.product_desc, p.product_quantity_avail, c.product_class_desc,
SUM(IFNULL(i.PRODUCT_QUANTITY,0)) AS Quantity_Sold, p.product_quantity_avail AS Quantity_Available 
FROM product p LEFT JOIN order_items i ON p.product_id = i.product_id
INNER JOIN  product_class c ON p.product_class_code = c.product_class_code
GROUP BY p.product_id) AS a
ORDER BY a.product_id;
------------------------------------------------------------------------------------------------------------------------------
/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having
total volume less than the volume of carton id 10
 */
## Answer 7.
SELECT i.order_id, SUM(i.product_quantity* p.len*p.width*p.height) AS Product_Vol
FROM order_items i LEFT JOIN product p ON p.product_id = i.product_id
GROUP BY order_id 
HAVING Product_Vol < (SELECT (len*width*height) AS Vol_of_Carton10 FROM carton WHERE carton_id=10)
ORDER BY Product_Vol DESC
LIMIT 1;
-------------------------------------------------------------------------------------------------------------------------------
/*Q8. Write a query to display customer id, customer full name, total quantity and 
total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/
## Answer 8.
SELECT o.customer_id, CONCAT(o.customer_fname,' ',o.customer_lname) AS Customer_Full_Name, 
SUM(i.product_quantity) AS Total_Quantity, SUM(i.product_quantity*p.product_price) AS Total_Price
FROM order_header h JOIN online_customer o ON o.customer_id = h.customer_id
JOIN order_items i ON h.order_id = i.order_id
JOIN product p ON i.product_id = p.product_id
WHERE h.order_status = 'Shipped' AND h.payment_mode = 'Cash' AND o.customer_lname LIKE 'G%'
GROUP BY o.customer_id,Customer_Full_Name;
-------------------------------------------------------------------------------------------------------------------------------
/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together
 with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 6 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products ,
 product_id’s which are sold with 201 product_id (201 should not be there in output) 
 and are shipped except Bangalore and New Delhi
 */
## Answer 9.
SELECT c.product_id AS Product_ID, p.product_desc, SUM(c.product_quantity) AS Total_Quantity
FROM (SELECT b.*,a.product_id AS actual_product_id, b.product_id AS bought_together
FROM order_items a INNER JOIN order_items b
ON a.order_id = b.order_id AND  a.product_id != b.product_id
WHERE a.product_id = 201) AS c
INNER JOIN product p ON p.product_id = c.product_id
INNER JOIN order_header h ON h.order_id = c.order_id
INNER JOIN online_customer o ON o.customer_id = h.customer_id
INNER JOIN address ad ON ad.address_id = o.address_id
WHERE city NOT IN ('Bangalore','New Delhi')
GROUP BY c.product_id
ORDER BY Total_Quantity DESC;
-------------------------------------------------------------------------------------------------------------------------------
/* Q10. Write a query to display the order_id, customer_id and customer fullname, total quantity of products 
shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]
 */
## Answer 10.
SELECT h.order_id, h.customer_id, CONCAT(o.customer_fname,' ',o.customer_lname) as Customer_Full_Name, SUM(i.product_quantity) AS Total_Quantity
FROM order_header h JOIN online_customer o ON h.customer_id = o.customer_id
JOIN order_items i ON h.order_id = i.order_id
JOIN address a on o.address_id = a.address_id
WHERE (i.order_id % 2) = 0 AND h.order_status = 'Shipped' AND a.pincode NOT LIKE'5%'
GROUP BY h.order_id, h.customer_id, Customer_Full_Name;
-------------------------------------------------------------------------------------------------------------------------------





