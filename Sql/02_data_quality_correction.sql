USE RetailIQ
GO


/*================================================================================================
               DATA QUALITY CORRECTIONS — STAKEHOLDER APPROVED BUSINESS RULES.
==================================================================================================
1. Negative quantities
   Stakeholder review confirmed that negative quantities represent data entry errors rather
   than genuine returns or cancellations. Negative quantities are therefore converted to
   their absolute values.

2. Discounts above 100%
   Stakeholder review confirmed that discount values above 100% are also data entry errors.
   Values are corrected using (discount_pct - 100).

3. Authoritative fields
   Unit price, quantity, and discount percentage are treated as authoritative.
   Line total is therefore recalculated from these fields after correction.
==================================================================================================*/







--                  DATA TRANSFORMATION : Using DDL and DML commands (SELECT, UPDATE, ALTER).

/*=====================================================================================================
1. clean.customers : No data transformation required.
=======================================================================================================*/

SELECT *
FROM clean.customers





/*====================================================================================================
2. clean.products 
======================================================================================================
PROCESS :

         -- ABS(stock_qty) required.
         -- Data transformation -- Dropping columns.
======================================================================================================*/

-- Pre transformation Inspection.

SELECT *
FROM clean.products
WHERE stock_qty < 0            -- Inspecting before updating table

UPDATE  clean.products
SET stock_qty = ABS(stock_qty)
WHERE stock_qty < 0            -- Updating table.


ALTER TABLE clean.products
DROP COLUMN stock_qty_flag     -- Dropping flag column as it wont be needed henceforth.


-- Post transformation Inspection.

SELECT *                   
FROM clean.products     
WHERE stock_qty < 0           -- Expected result is an empty set (o row)





/*================================================================================================
3. clean.orders 
==================================================================================================
   PROSESS :
            
            - Adjusting discounts.
            - Dropping the flag column.
==================================================================================================*/

--                    DISCOUNTS

-- Pre transformation Inspection.

SELECT *
FROM clean.orders
WHERE discount_pct > 100                      -- Inspecting before Updating table.


UPDATE clean.orders                           -- Updating table.
SET discount_pct = (discount_pct - 100)
WHERE discount_pct > 100


ALTER TABLE clean.orders
DROP COLUMN discount_pct_flag                  -- Dropping flag column as it wont be needed henceforth.


-- Post transformation Inspection.

SELECT *
FROM clean.orders
WHERE discount_pct > 100                       -- Expected result is an empty set (o row)





/*========================================================================================================
4. clean.order_items 
==========================================================================================================
    PROCESS :

            - ABS(quantity) required.
            - Drop the quantity flag column.
            - Compute missing unit_price using a supporting table clean.products.
            - Adjusting discounts accordingly.
=========================================================================================================*/


--                   Quantity


SELECT *
FROM clean.order_items
WHERE quantity < 0                 -- Inspecting before updating table

UPDATE clean.order_items
SET quantity = ABS(quantity)
WHERE quantity < 0                 -- Updating table.


ALTER TABLE clean.order_items
DROP COLUMN quantity_flag          -- Dropping flag column as it wont be needed henceforth.


-- Post transformation Inspection

SELECT *
FROM clean.order_items
WHERE quantity < 0                 -- Expected result is an empty set (o row)




--            Missing unit price


SELECT
    oi.item_id,
    oi.product_id,
    oi.unit_price_USD AS old_price,
    p.unit_price_USD AS replacement_price
FROM clean.order_items AS oi
LEFT JOIN clean.products AS p
     ON oi.product_id = p.product_id
WHERE oi.unit_price_USD IS NULL                 -- Inspecting before updating table.
          


UPDATE oi
SET oi.unit_price_USD = p.unit_price_USD
FROM clean.order_items oi
LEFT JOIN clean.products p
    ON oi.product_id = p.product_id
WHERE oi.unit_price_USD IS NULL                 -- Updating table.


-- Post transformation Inspection

SELECT *
FROM clean.order_items
WHERE unit_price_USD IS NULL;                  -- Expected result is an empty set (o row)



--                     Discount

SELECT
    item_id,
    discount_pct
FROM clean.order_items
WHERE discount_pct > 100                       -- Inspecting before updating table.


UPDATE clean.order_items
SET discount_pct = (discount_pct - 100)
WHERE discount_pct > 100                       -- Updating table.


ALTER TABLE clean.order_items
DROP COLUMN discount_pct_flag                  -- Dropping flag column as it wont be needed henceforth.


-- Post transformation Inspection.

SELECT *
FROM clean.order_items
WHERE discount_pct > 100;                      -- Expected result is an empty set (o row)



--               Line total

SELECT                              
    unit_price_USD,
    quantity,
    discount_pct,
    line_total_USD,
    ROUND(((CAST(unit_price_USD AS FLOAT) * quantity) * (1 - (discount_pct / 100.0))),2) AS derived_line_total_USD
FROM clean.order_items                                                                                               -- Investigating before updating table.


UPDATE clean.order_items 
SET line_total_USD = ROUND(((CAST(unit_price_USD AS FLOAT) * quantity) * (1 - (discount_pct / 100.0))),2)            -- Updating table.
-- discount_pct stored as whole number (20 = 20%) hence dividing by 100.0                                                                                              

-- Post transformation Inspection.

SELECT *
FROM clean.order_items





/*==================================================================================================================
5. clean.returns : No transformation required
===================================================================================================================*/

SELECT *
FROM clean.returns





/*========================================================================================================================
6. clean.subscriptions : No transformation required
=========================================================================================================================*/

SELECT *
FROM clean.subscriptions
