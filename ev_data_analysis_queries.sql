USE electric_cars_eastside;

/*

1) PM: Lidi Vianney Cala Toloza
2) Uliana Topilina
3) Alena Golovina
*/

-- Indexes for single-field WHERE clauses:
-- Index for Sales table on the tax_credit column - Lidi Cala
CREATE INDEX idx_sales_tax_credit ON Sales (tax_credit);

-- Index for Sales table on the sale_date column - Lidi Cala
CREATE INDEX idx_sales_sale_date ON Sales (sale_date);

-- Index for Cars table on the sale_id column - Lidi Cala
CREATE INDEX idx_cars_sale_id ON Cars (sale_id);

-- Index for Cars table on the battery_id column - Lidi Cala
CREATE INDEX idx_cars_battery_id ON Cars (battery_id);

-- Index for ChargingStations table on the Tesla_ports column - Lidi Cala
CREATE INDEX idx_chargingstations_tesla_ports ON ChargingStations (Tesla_ports);

-- Index for Owners table on the owner_zip column - Lidi Cala
CREATE INDEX idx_owners_owner_zip ON Owners (owner_zip);

-- Index for Cars table on the owner_id column - Lidi Cala 
CREATE INDEX idx_cars_owner_id ON Cars (owner_id);

-- Index for ChargingStations table on the charging_location column - Lidi Cala
CREATE INDEX idx_chargingstations_charging_location ON ChargingStations (charging_location);

-- Index for Batteries table on the battery_id column - Lidi Cala
CREATE INDEX idx_batteries_battery_id ON Batteries (battery_id);

-- Index for Batteries table on the battery_type column - Lidi Cala
CREATE INDEX idx_batteries_battery_type ON Batteries (battery_type);


-- Indexes for single-field WHERE clauses -- Uliana
CREATE INDEX idx_manufacturer_address ON Manufacturers(manufacturer_address);
CREATE INDEX idx_vin_number ON Cars(vin_number);
CREATE INDEX idx_model_year ON Cars(model_year);

-- Composite index for multi-field WHERE clause -- Uliana
CREATE INDEX idx_manufacturer_id_battery_id ON Cars(manufacturer_id, battery_id);

-- index for discount_price_sf stored function -- Alena
CREATE INDEX idx_sales_sales_id ON Sales(sale_id);

-- indexes for teslaModelsCost_sp; -- Alena
CREATE INDEX idx_manufacturer_name ON Manufacturers(manufacturer_name);
CREATE INDEX idx_sale_amount ON Sales(sale_amount);


/*This query retrieves information about cars where the tax credit is $7500. It displays the VIN number, 
model, model year, sale amount, and tax credit for each car, organized by the sale amount in ascending order.*/
-- Query 1: Taxes of $7500, organized by the cost of the vehicle
SELECT c.vin_number, c.model, c.model_year, s.sale_amount, s.tax_credit
FROM Cars c
JOIN Sales s ON c.sale_id = s.sale_id
WHERE s.tax_credit = 7500
ORDER BY s.sale_amount;

-- Query 2: Cars sold in 2019, organized by the lowest price
/*This query retrieves information about cars sold in 2019. It displays the VIN number, model, model year, and 
sale amount for each car, organized by the sale amount in ascending order.
*/
SELECT c.vin_number, c.model, c.model_year, s.sale_amount
FROM Cars c
JOIN Sales s ON c.sale_id = s.sale_id
WHERE YEAR(s.sale_date) = 2019
ORDER BY s.sale_amount ASC;

-- Query 3: Cars sold in 2023, cars with PHEV sorted by price from lowest to highest, showing the amount of taxes for these cars
/*This query retrieves information about cars sold in 2023 with PHEV batteries. It displays the VIN number, 
model, model year, sale amount, and tax credit for each car, organized by the sale amount in ascending order.
*/
SELECT c.vin_number, c.model, c.model_year, s.sale_amount, s.tax_credit
FROM Cars c
JOIN Sales s ON c.sale_id = s.sale_id
JOIN Batteries b ON c.battery_id = b.battery_id
WHERE YEAR(s.sale_date) = 2023 AND b.battery_type = 'PHEV'
ORDER BY s.sale_amount ASC;

-- Query 4: Number of charging stations for non-Tesla cars
/*This query counts the number of charging stations that do not have Tesla ports
*/
SELECT COUNT(*)
FROM ChargingStations
WHERE Tesla_ports = 0;

-- Query 5: Number of users with postal code 98052 and charging stations from the same postal code, organized by battery type
/*This query retrieves information about users with postal code 98052 and their cars, organized by battery type.
 It includes the owner ID, city, postal code, and battery type for each user.
*/
SELECT o.owner_id, o.owner_city, o.owner_zip, b.battery_type
FROM Owners o
JOIN Cars c ON o.owner_id = c.owner_id
JOIN ChargingStations cs ON c.manufacturer_id = c.manufacturer_id
JOIN Batteries b ON c.battery_id = b.battery_id
WHERE o.owner_zip = 98052 AND cs.charging_location LIKE '%98052%'
GROUP BY o.owner_id, o.owner_city, o.owner_zip, b.battery_type
ORDER BY o.owner_id DESC;

-- Query 6: Car models that have been sold more than once
/*This query retrieves car models that have been sold more than once. It displays the car model 
and the total number of sales for each model, sorted by the total sales in descending order.
*/
SELECT
    c.model AS Model,
    COUNT(s.sale_id) AS Total_Sales
FROM
    Cars c
JOIN
    Sales s ON c.sale_id = s.sale_id
GROUP BY
    c.model
HAVING
    COUNT(s.sale_id) > 1
ORDER BY
    Total_Sales DESC;

/* Multi-table Subquery - Uliana */
SELECT manufacturer_name
FROM Manufacturers
WHERE manufacturer_id IN 
(
    SELECT manufacturer_id
    FROM Cars
    WHERE owner_id IN 
    (
        SELECT owner_id
        FROM Owners
        WHERE owner_county = 'King'
    )
);

/* Updatable Single Table View - Uliana */
CREATE VIEW CarsByVIN AS
SELECT vin_number, model, model_year, manufacturer_id, battery_id, owner_id, sale_id
FROM Cars;

/* Updatable Single Table View - Uliana */
SELECT * FROM CarsByVIN WHERE vin_number = '5YJ3E1EBXK';

/* Updatable Single Table View - Uliana */
UPDATE CarsByVIN SET model_year = 2022 WHERE vin_number = '5YJ3E1EBXK';

/* Updatable Single Table View - Uliana */
SELECT * FROM CarsByVIN WHERE vin_number = '5YJ3E1EBXK';

/*This stored procedure named teslaModelsCost_sp() creates a cursor for a result set that consists of the car_model
(from carst table), sale_amount (from sales table) and tax_discount columns (from
sales table) for each tesla (also joins on manufacturer_name with Manufacturers table to get the rows).
 Then, the procedure should display a string variable that includes the
model, isale_amount and tax_discount for each car so it looks something like
Tesla X, 150600, 4500 - if the condition for the sale_amount is met.
*/
-- indexes for teslaModelsCost_sp;
CREATE INDEX idx_manufacturer_name ON Manufacturers(manufacturer_name);
CREATE INDEX idx_sale_amount ON Sales(sale_amount);


DROP PROCEDURE IF EXISTS teslaModelsCost_sp;
DELIMITER //
CREATE PROCEDURE teslaModelsCost_sp()
BEGIN
  DECLARE model_var VARCHAR(50);
  DECLARE sale_amount_var DECIMAL(10, 2);
  DECLARE tax_credit_var DECIMAL(10, 2);
  DECLARE s                   VARCHAR(10000)   DEFAULT '';
  DECLARE no_teslas INT DEFAULT FALSE;

  DECLARE tesla_cursor CURSOR FOR
    SELECT c.model, s.sale_amount, s.tax_credit
    FROM Sales s
    JOIN  Cars c ON s.sale_id = c.sale_id
    JOIN Manufacturers m ON c.manufacturer_id = m.manufacturer_id
    WHERE m.manufacturer_name = "Tesla" AND s.sale_amount>70500;
    
  BEGIN
  DECLARE EXIT HANDLER FOR NOT FOUND 
	SET no_teslas = TRUE;

  OPEN tesla_cursor;
  WHILE no_teslas = FALSE DO 
  FETCH tesla_cursor 
  INTO model_var, sale_amount_var, tax_credit_var;
  
SET s = CONCAT(s, model_var, '|',
                        sale_amount_var, '|',
                        tax_credit_var, '//');
  END WHILE;
  END;
  CLOSE tesla_cursor;

SELECT s AS message;

END //
DELIMITER ;

-- call teslaModelsCost_sp()
CALL teslaModelsCost_sp();


/*This stored function named discount_price_sf calculates the discount price of a car in the Sales table 
(tax credit subtracted from sale_amount). This function accepts one parameter for the sale ID, 
 and it returns the value of the discount price for that sale.*/

-- index for discount_price_sf stored function
CREATE INDEX idx_sales_sales_id ON Sales(sale_id);


DROP FUNCTION IF EXISTS discount_price_sf;

DELIMITER //
CREATE FUNCTION discount_price_sf (param_item_id INT)
	RETURNS DECIMAL(10,2)
	DETERMINISTIC READS SQL DATA

BEGIN
    DECLARE discounted_price DECIMAL(10,2);
		
	-- Select the discounted price of the parameters id values
	SELECT sale_amount - tax_credit
    INTO discounted_price
    FROM sales
    WHERE sale_id = param_item_id;

    RETURN discounted_price;
END//
DELIMITER ;

-- call discount_price_sf() in a select statement
SELECT 	sale_id, discount_price_sf(sale_id)
FROM sales;