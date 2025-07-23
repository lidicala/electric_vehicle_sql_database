/*****************************************************************************
* This script creates the database named electric_cars_eastside in Washington State 
******************************************************************************/

DROP DATABASE IF EXISTS electric_cars_eastside;
CREATE DATABASE electric_cars_eastside;
USE electric_cars_eastside;

/* create the tables for the database */
CREATE TABLE Manufacturers (
    manufacturer_id INT,
    manufacturer_name VARCHAR(20) NOT NULL,
    manufacturer_address VARCHAR(100) 
);

-- Add the manufacturer_id column as primary key
ALTER TABLE Manufacturers ADD CONSTRAINT manufacturer_pk
PRIMARY KEY (manufacturer_id), MODIFY manufacturer_id INT AUTO_INCREMENT;

-- CSS- BMW, VWagen, GMotors, Rivian
-- CHAdeMO - Nissan, Mitsubishi, Kia, +Tesla if adapter
-- J1772 - All EVs - Level 1 and 2, +Tesla if adapter
CREATE TABLE ChargingStations (
    chargingStation_id INT,
    chargingStation_name VARCHAR(40) NOT NULL,
    charging_location VARCHAR(100) NOT NULL,
    CCS_SAE_ports INT NOT NULL,
    CHAdeMO_ports INT NOT NULL,
    J1772_ports INT NOT NULL,
    Tesla_ports INT NOT NULL
);

-- Add the primary key constraint to chargingStation_id column
ALTER TABLE ChargingStations ADD CONSTRAINT chargingStation_pk
PRIMARY KEY (chargingStation_id), MODIFY chargingStation_id INT AUTO_INCREMENT;


/*join table*/
-- Create the table without primary key
CREATE TABLE ChargingStations_Manufacturers (
    chargingStation_id INT,
    manufacturer_id INT
);

-- Add primary key constraint using ALTER TABLE
ALTER TABLE ChargingStations_Manufacturers ADD CONSTRAINT chargingStations_manufacturers_pk
PRIMARY KEY (chargingStation_id, manufacturer_id);

-- Add foreign key constraints
ALTER TABLE ChargingStations_Manufacturers ADD CONSTRAINT chargingStation_fk_manufacturer
FOREIGN KEY (chargingStation_id) REFERENCES ChargingStations(chargingStation_id);

ALTER TABLE ChargingStations_Manufacturers ADD CONSTRAINT chargingStations_fk_manufacturers
FOREIGN KEY (manufacturer_id) REFERENCES Manufacturers(manufacturer_id);


CREATE TABLE Batteries (
    battery_id INT,
	battery_type VARCHAR(10) NOT NULL
);
-- Add the battery_id column as primary key
ALTER TABLE Batteries ADD CONSTRAINT battery_pk
PRIMARY KEY (battery_id), MODIFY battery_id INT AUTO_INCREMENT;

CREATE TABLE Owners (
    owner_id INT,
    owner_county VARCHAR(20) DEFAULT 'King' NOT NULL,
    owner_city VARCHAR(25) NOT NULL,
    owner_zip INT NOT NULL
);
-- Add the owner_id column as primary key
ALTER TABLE Owners ADD CONSTRAINT owner_pk
PRIMARY KEY (owner_id), MODIFY owner_id INT AUTO_INCREMENT;


CREATE TABLE Sales (
    sale_id INT,
    sale_date DATE NOT NULL, 
    sale_amount DECIMAL(8,2) NOT NULL,
    tax_credit DECIMAL(6,2) NOT NULL,
    owner_id INT
);

-- Add the sales_id column as primary key
ALTER TABLE Sales ADD CONSTRAINT sale_pk
PRIMARY KEY (sale_id), MODIFY sale_id INT AUTO_INCREMENT;

-- Add FK constraint to Slaes referencing Owners - one-to-many relationship
ALTER TABLE Sales ADD CONSTRAINT sales_fk_owners 
FOREIGN KEY (owner_id) REFERENCES Owners (owner_id);


CREATE TABLE Cars (
    car_id INT,
    vin_number VARCHAR(17) NOT NULL,
    model VARCHAR(40) NOT NULL,
    model_year INT NOT NULL,
    manufacturer_id INT,
    battery_id INT,
    owner_id INT,
    sale_id INT
);

-- Add primary key for the "car_id" column
ALTER TABLE Cars ADD CONSTRAINT car_pk
PRIMARY KEY (car_id), MODIFY car_id INT AUTO_INCREMENT;

-- Add foreign keys for the referenced columns
ALTER TABLE Cars ADD CONSTRAINT cars_fk_manufacturers 
FOREIGN KEY (manufacturer_id) REFERENCES Manufacturers (manufacturer_id);

ALTER TABLE Cars ADD CONSTRAINT cars_fk_batteries 
FOREIGN KEY (battery_id) REFERENCES Batteries(battery_id);

ALTER TABLE Cars ADD CONSTRAINT cars_fk_owners 
FOREIGN KEY (owner_id) REFERENCES Owners(owner_id);

ALTER TABLE Cars ADD CONSTRAINT cars_fk_sales 
FOREIGN KEY (sale_id) REFERENCES Sales (sale_id);


INSERT INTO Manufacturers (manufacturer_id, manufacturer_name, manufacturer_address)
VALUES
    (1, 'BMW', '300 Chestnut Ridge Road Woodcliff Lake, NJ, 07677-7731, USA'),
    (2, 'Ford', '1 American Rd Dearborn, MI, 48126, USA'),
    (3, 'Tesla', '1 Tesla Road Austin, TX, 78725, USA'),
    (4, 'Toyota', '6565 Headquarters Dr. Plano, TX, 75024, USA'),
    (5, 'Volkswagen', '2200 Ferdinand Porsche Dr. Herndon, VA, 20171, USA'),
    (6, 'Rivian', '14600 Myford Rd Irvine, CA, 92606-1005, USA'),
    (7, 'Volvo', '1800 Volvo Place Mahwah, NJ, 07430, USA'),
    (8, 'Chrysler', '1000 Chrysler Dr Auburn Hills, MI, 48326, USA'),
    (9, 'Audi', '2200 Ferdinand Porsche Drive. Herndon, VA, 20171, USA'),
    (10, 'Jeep', '3800 Stickney Ave, Toledo, OH, 43608, USA'),
    (11, 'Lucid Air', '7373 Gateway Boulevard Newark, CA, 94560, USA'),
    (12, 'Chevrolet', '300 Renaissance Center Detroit, MI, 48265, USA'),
	(13, 'Lexus', '19001 S Western Ave, Torrance, CA, 90501, USA'),
	(14, 'Kia', '52410 Irvine, CA, 92619-2410, USA'),
	(15, 'Porsche', '200 S. Biscayne Blvd. Suite 4620. MI, 33131, USA'),
	(16, 'Nissan', 'One Nissan Way, Franklin, TN, 37067, USA');


-- CSS- BMW, VWagen, GMotors, Rivian
-- CHAdeMO - Nissan, Mitsubishi, Kia, +Tesla if adapter
-- J1772 - All EVs - Level 1 and 2, +Tesla if adapter
INSERT INTO ChargingStations (chargingStation_id, chargingStation_name, charging_location,
 CCS_SAE_ports, CHAdeMO_ports, J1772_ports, Tesla_ports)
VALUES 
    (1, 'Electrify America', '11224 NE 124th St, Kirkland, WA, 98034', 5, 1, 1, 0 ),
    (2, 'Tesla', '12221 120th Ave NE, Kirkland, WA, 98034', 0, 0, 0,12),
    (3, 'Bllink', '11010 NE 124th Ln, Kirkland, WA, 98034', 0, 0, 1, 0),
    (4, 'Shell', '11930 124th Ave NE, Kirkland, WA, 98034', 0, 2, 0, 0),
    (5, 'EVgo', '7525 166th Ave NE, Redmond, WA, 98052', 2, 2, 1, 0);

-- Insert data into ChargingStations_Manufacturers table (bridge entity)
INSERT INTO ChargingStations_Manufacturers (chargingStation_id, manufacturer_id) VALUES

    -- Charging Station 1 (Electrify America) compatible with all manufacturers because of the J1772_ports
    (1, 1),  -- BMW
    (1, 2),  -- Ford
    (1, 3),  -- Tesla
    (1, 4),  -- Toyota
    (1, 5),  -- Volkswagen
    (1, 6),  -- Rivian
    (1, 7),  -- Volvo
    (1, 8),  -- Chrysler
    (1, 9),  -- Audi
    (1, 10), -- Jeep
    (1, 11), -- Lucid Air
    (1, 12), -- Chevrolet
    (1, 13), -- Lexus
    (1, 14), -- Kia
    (1, 15), -- Porsche
    (1, 16), -- Nissan

    -- Charging Station 2 (Tesla) compatible with Tesla
    (2, 3),  -- Tesla

    -- Charging Station 3 (Blink) compatible with all manufacturers because of the J1772_ports
    (3, 1),  -- BMW
    (3, 2),  -- Ford
    (3, 3),  -- Tesla
    (3, 4),  -- Toyota
    (3, 5),  -- Volkswagen
    (3, 6),  -- Rivian
    (3, 7),  -- Volvo
    (3, 8),  -- Chrysler
    (3, 9),  -- Audi
    (3, 10), -- Jeep
    (3, 11), -- Lucid Air
	(3, 12), -- Chevrolet
    (3, 13), -- Lexus
    (3, 14), -- Kia
    (3, 15), -- Porsche
    (3, 16), -- Nissan

    -- Charging Station 4 (Shell) may have Tesla adapter
    (4, 11), -- Lucid air (Tesla  if adapter is available)
    
     -- Charging Station 5 (EVgo) compatible with all manufacturers
    (5, 1),  -- BMW
    (5, 2),  -- Ford
    (5, 3),  -- Tesla
    (5, 4),  -- Toyota
    (5, 5),  -- Volkswagen
    (5, 6),  -- Rivian
    (5, 7),  -- Volvo
    (5, 8),  -- Chrysler
    (5, 9),  -- Audi
    (5, 10), -- Jeep
    (5, 11), -- Lucid Air
	(5, 12), -- Chevrolet
    (5, 13), -- Lexus
    (5, 14), -- Kia
    (5, 15), -- Porsche
    (5, 16); -- Nissan
    
INSERT INTO Batteries (battery_id, battery_type)
VALUES 
    (1, 'PHEV'),
    (2, 'BEV');

   
INSERT INTO Owners (owner_id, owner_county, owner_city, owner_zip)
VALUES 
    
    (1, 'King', 'Bellevue', 98005),
    (2, 'King', 'Issaquah', 98027),
    (3, 'King', 'Kirkland', 98034),
    (4, 'King', 'Bellevue', 98005),
    (5, 'King', 'Issaquah', 98029),
    (6, 'King', 'Medina', 98039),
    (7, 'King', 'Kirkland', 98034),
    (8, 'King', 'Medina', 98039),
    (9, 'King', 'Redmond', 98052),
    (10, 'King', 'Kirkland', 98034),
    (11, 'King', 'Redmond', 98052),
    (12, 'King', 'Bellevue', 98005),
    (13, 'King', 'Medina', 98039),
    (14, 'King', 'Redmond', 98052),
    (15, 'King', 'Redmond', 98052),
    (16, 'King', 'Bellevue', 98006),
    (17, 'King', 'Sammamish', 98075),
    (18, 'King', 'Issaquah', 98027),
    (19, 'King', 'Bellevue', 98005),
    (20, 'King', 'Medina', 98039),
    (21, 'King', 'Redmond', 98052),  
    (22, 'King', 'Bellevue', 98007), 
    (23, 'King', 'Bellevue', 98006), 
    (24, 'King', 'North Bend', 98045),  
    (25, 'King', 'Bellevue', 98004), 
    (26, 'King', 'Duvall', 98019),  
    (27, 'King', 'Redmond', 98052),  
    (28, 'King', 'Redmond', 98053), 
    (29, 'King', 'Bothell', 98011),  
    (30, 'King', 'Redmond', 98052), 
    (31, 'King', 'Redmond', 98052), 
    (32, 'King', 'Fall City', 98024), 
    (33, 'King', 'Sammamish', 98074),
    (34, 'King', 'Woodinville', 98072), 
    (35, 'King', 'Mercer Island', 98040), 
    (36, 'King', 'Redmond', 98053), 
    (37, 'King', 'Bellevue', 98007), 
    (38, 'King', 'Kirkland', 98034), 
    (39, 'King', 'Renton', 98059),
    (40, 'King', 'Redmond', 98052),
    (41, 'King', 'Bothell', 98011),
    (42, 'King', 'Redmond', 98052),
    (43, 'King', 'Redmond', 98053),
    (44, 'King', 'Renton', 98059),
    (45, 'King', 'Renton', 98058),
    (46, 'King', 'Clyde Hill', 98004),
    (47, 'King', 'Issaquah', 98027),
    (48, 'King', 'Woodinville', 98072),
    (49, 'King', 'Woodinville', 98072),
    (50, 'King', 'Duvall', 98019),
    (51, 'King', 'Medina', 98039),
    (52, 'King', 'Redmond', 98052),
    (53, 'King', 'Bellevue', 98007),
    (54, 'King', 'Sammamish', 98074),
    (55, 'King', 'Kirkland', 98033),
    (56, 'King', 'Issaquah', 98027),
    (57, 'King', 'Bellevue', 98005),
    (58, 'King', 'Redmond', 98052),
    (59, 'King', 'Kirkland', 98034),
    (60, 'King', 'Bellevue', 98004),
    (61, 'King', 'Redmond', 98052),
    (62, 'King', 'Redmond', 98052),
    (63, 'King', 'Issaquah', 98029),
    (64, 'King', 'Issaquah', 98029),
    (65, 'King', 'Sammamish', 98075),
    (66, 'King', 'Redmond', 98052),
    (67, 'King', 'Bellevue', 98006),
    (68, 'King', 'Bellevue', 98005),
    (69, 'King', 'Kirkland', 98034),
    (70, 'King', 'Bellevue', 98006),
    (71, 'King', 'Redmond', 98052),
    (72, 'King', 'Kirkland', 98034),
    (73, 'King', 'Issaquah', 98027),
    (74, 'King', 'Sammamish', 98075),
    (75, 'King', 'Bellevue', 98005),
    (76, 'King', 'Kirkland', 98034),
    (77, 'King', 'Redmond', 98052),
    (78, 'King', 'Issaquah', 98027),
    (79, 'King', 'Sammamish', 98074),
    (80, 'King', 'Medina', 98039);

   

INSERT INTO Sales (sale_id, sale_date, sale_amount, tax_credit, owner_id)
VALUES 
    (1, '2019-01-03', 35000, 7500, 1),
    (2, '2019-01-20', 35000, 7500, 2),
    (3, '2019-02-10', 37495, 7500, 3),
    (4, '2019-03-17', 24535, 7500, 4),
    (5, '2019-03-13', 35000, 7500, 5),
    (6, '2019-07-23', 72650, 7500, 6),
    (7, '2019-05-01', 25000, 4609, 7),
    (8, '2019-09-29', 45445, 7500, 8),
    (9, '2019-04-08', 65700, 6712, 9),
    (10, '2019-11-14', 75795, 7500, 10),
    (11, '2020-03-08', 36200, 7500, 11),
    (12, '2020-01-25', 48000, 7500, 12),
    (13, '2020-05-28', 45445, 4000, 13),
    (14, '2020-02-10', 36200, 7500, 14),
    (15, '2020-06-19', 48000, 7500, 15),
    (16, '2020-04-27', 28895, 4502, 16),
    (17, '2020-08-06', 28895, 4502, 17),
    (18, '2020-10-19', 36200, 7500, 18),
    (19, '2020-12-26', 48000, 7500, 19),
    (20, '2020-07-15', 31600, 7500, 20),
    (21, '2021-01-07', 45440, 7500, 21),
    (22, '2021-01-21', 50387, 7500, 22),
    (23, '2021-02-14', 42500, 7500, 23),
    (24, '2021-02-17', 72395, 7500, 24),
    (25, '2021-03-08', 50500, 5419, 25),
    (26, '2021-03-15', 56400, 3750, 26),
    (27, '2021-04-04', 62355, 7500, 27),
    (28, '2021-04-04', 68000, 3750, 28),
    (29, '2021-05-30', 59200, 7500, 29),
    (30, '2021-06-07', 115000, 7500, 30),
    (31, '2021-08-26', 56115, 7500, 31),
    (32, '2021-11-01', 41440, 7500, 32),
    (33, '2021-12-24', 48395, 7500, 33),
    (34, '2021-12-30', 65440, 7500, 34),
    (35, '2022-01-30', 118440, 7500, 35),
    (36, '2022-01-30', 58440, 7500, 36),
    (37, '2022-02-13', 50500, 7500, 37),
    (38, '2022-03-06', 49999, 7500, 38),
    (39, '2022-04-18', 100000, 7500, 39),
    (40, '2022-06-21', 50500, 4000, 40),
    (41, '2022-07-07', 43440, 7500, 41),
    (42, '2022-08-07', 64333, 7500, 42),
    (43, '2022-08-26', 47666, 7500, 43),
    (44, '2022-09-01', 50650, 7500, 44),
    (45, '2022-10-03', 69996, 7500, 45),
    (46, '2022-10-25', 110500, 7500, 46),
    (47, '2022-11-01', 77777, 7500, 47),
    (48, '2022-11-11', 61610, 7500, 48),
    (49, '2022-12-02', 55555, 7500, 49),
    (50, '2022-12-22', 31995, 7500, 50),
    (51, '2023-01-07', 61600, 3750, 51),
    (52, '2023-03-24', 61600, 3750, 52),
    (53, '2023-05-04', 61600, 3750, 53),
    (54, '2023-06-20', 61600, 3750, 54),
    (55, '2023-07-16', 61600, 3750, 55),
    (56, '2023-11-08', 61600, 3750, 56),
    (57, '2023-07-29', 40500, 3750, 57),
    (58, '2023-07-30', 40500, 3750, 58),
    (59, '2023-04-04', 38990, 7500, 59),
    (60, '2023-06-04', 38990, 7500, 60),
    (61, '2023-08-08', 38990, 7500, 61),
    (62, '2023-08-10', 74990, 7500, 62),
    (63, '2023-05-23', 79990, 7500, 63),
    (64, '2023-07-27', 43990, 7500, 64),
    (65, '2023-04-12', 43990, 7500, 65),
    (66, '2023-08-11', 43990, 7500, 66),
    (67, '2023-12-11', 43990, 7500, 67),
    (68, '2023-03-25', 27450, 3750, 68),
    (69, '2023-04-10', 27450, 3750, 69),
    (70, '2023-03-14', 32060, 3750, 70),
    (71, '2023-05-28', 32060, 3750, 71),
    (72, '2023-06-30', 32060, 3750, 72),
    (73, '2023-07-04', 32060, 3750, 73),
    (74, '2023-08-15', 32060, 3750, 74),
    (75, '2023-01-30', 49496, 7500, 75),
    (76, '2023-02-24', 49496, 7500, 76),
    (77, '2023-03-06', 49496, 7500, 77),
    (78, '2023-04-08', 49496, 7500, 78),
    (79, '2023-06-06', 49496, 7500, 79),
    (80, '2023-12-18', 49496, 7500, 80); 



INSERT INTO Cars (car_id, vin_number, model, model_year, manufacturer_id, battery_id, owner_id, sale_id)
VALUES 
    (1, '5YJ3E1EAXK', 'TESLA MODEL 3', 2019, 3, 2, 1, 1),        -- BEV
    (2, '5YJ3E1EA9K', 'TESLA MODEL 3', 2019, 3, 2, 2, 2),        -- BEV
    (3, '1G1FY6S04K', 'CHEVROLET BOLT EV', 2019, 12, 2, 3, 3),   -- BEV
    (4, 'KNDCE3LG1K', 'KIA NIRO', 2019, 14, 2, 4, 4),            -- BEV
    (5, '5YJ3E1EBXK', 'TESLA MODEL 3', 2019, 3, 2, 5, 5),        -- BEV
    (6, '5YJXCAE23K', 'TESLA MODEL X', 2019, 3, 2, 6, 6),        -- BEV
    (7, '3FA6P0SU4K', 'FORD FUSION', 2019, 2, 1, 7, 7),          -- PHEV
    (8, 'WBY8P2C58K', 'BMW I3', 2019, 1, 2, 8, 8),               -- BEV
    (9, 'WP1AE2AY2K', 'PORSCHE CAYENNE', 2019, 15, 1, 9, 9),     -- PHEV
    (10, 'WA1VABGEXK', 'AUDI E-TRON', 2019, 9, 2, 10, 10),       -- BEV
    (11, '5YJ3E1EB8L', 'TESLA MODEL 3', 2020, 3, 2, 11, 11),     -- BEV
    (12, '5YJYGDEE1L', 'TESLA MODEL Y', 2020, 3, 2, 12, 12),     -- BEV
    (13, 'WBY8P2C00L', 'BMW I3', 2020, 1, 2, 13, 13),            -- BEV
    (14, '5YJ3E1EB3L', 'TESLA MODEL 3', 2020, 3, 2, 14, 14),     -- BEV
    (15, '5YJYGDEE7L', 'TESLA MODEL Y', 2020, 3, 2, 15, 15),     -- BEV
    (16, 'JTDKARFP6L', 'TOYOTA PRIUS PRIME', 2020, 4, 1, 16, 16),    -- PHEV
    (17, 'JTDKARFP7L', 'TOYOTA PRIUS PRIME', 2020, 4, 1, 17, 17),    -- PHEV
    (18, '5YJ3E1EB9L', 'TESLA MODEL 3', 2020, 3, 2, 18, 18),     -- BEV
    (19, '5YJYGDEE9L', 'TESLA MODEL Y', 2020, 3, 2, 19, 19),     -- BEV
    (20, '1N4AZ1CP0L', 'NISSAN LEAF', 2020, 16, 2, 20, 20),      -- BEV
    (21, '5YJYGDEE2M', 'TESLA MODEL Y', 2021, 3, 2, 21, 21),     -- BEV
    (22, '5YJ3E1EB8M', 'TESLA MODEL 3', 2021, 3, 2, 22, 22),     -- BEV 
    (23, '5YJYGDEEXM', 'TESLA MODEL Y', 2021, 3, 2, 23, 23),     -- BEV
    (24, 'WA1LABGE2M', 'AUDI E-TRON', 2021, 9, 1, 24, 24),       -- PHEV
    (25, 'YV4BR0CL5M', 'VOLVO XC90', 2021, 7, 1, 25, 25),        -- PHEV
    (26, '1C4JJXP61M', 'JEEP WRANGLER', 2021, 10, 1, 26, 26),    -- PHEV
    (27, '5YJYGDEE0M', 'TESLA MODEL Y', 2021, 3, 2, 27, 27),     -- BEV
    (28, '5UXTA6C07M', 'BMW X5', 2021, 1, 1, 28, 28),            -- PHEV
    (29, '5YJ3E1EA2M', 'TESLA MODEL 3', 2021, 3, 2, 29, 29),     -- BEV
    (30, '5YJXCBE23M', 'TESLA MODEL X', 2021, 3, 2, 30, 30),     -- BEV
    (31, '2C4RC1S71M', 'CHRYSLER PACIFICA', 2021, 8, 1, 31, 31),   -- PHEV
    (32, '5YJYGDEE9M', 'TESLA MODEL Y', 2021, 3, 2, 32, 32),     -- BEV
    (33, '5YJYGDEE3M', 'TESLA MODEL Y', 2021, 3, 2, 33, 33),     -- BEV
    (34, '5YJYGDEEXM', 'TESLA MODEL Y', 2021, 3, 2, 34, 34),     -- BEV
    (35, '5YJXGBE22M', 'TESLA MODEL X', 2022, 3, 2, 35, 35),     -- BEV
    (36, '5YJ3E1EA9N', 'TESLA MODEL 3', 2022, 3, 2, 36, 36),     -- BEV
    (37, '5YJ3E1EBXN', 'TESLA MODEL 3', 2022, 3, 2, 37, 37),     -- BEV
    (38, '5YJ3E1EB4N', 'TESLA MODEL 3', 2022, 3, 2, 38, 38),     -- BEV
    (39, '50EA1GBA4N', 'LUCID AIR', 2022, 11, 1, 39, 39),        -- PHEV
    (40, 'JTJHKCFZ5N', 'LEXUS NX', 2022, 13, 1, 40, 40),         -- PHEV
    (41, '7SAYGDEE9N', 'TESLA MODEL Y', 2022, 3, 2, 41, 41),     -- BEV
    (42, '7SAYGAEE0N', 'TESLA MODEL Y', 2022, 3, 2, 42, 42),     -- BEV
    (43, '7SAYGDEE2N', 'TESLA MODEL Y', 2022, 3, 2, 43, 43),     -- BEV
    (44, 'WA1F2AFY4N', 'AUDI Q5', 2022, 9, 1, 44, 44),           -- PHEV
    (45, 'WA1LAAGE0N', 'AUDI E-TRON', 2022, 9, 2, 45, 45),       -- BEV
    (46, '7SAXCDE56N', 'TESLA MODEL X', 2022, 3, 2, 46, 46),     -- BEV
    (47, '7FCTGAAL4N', 'RIVIAN R1T', 2022, 6, 2, 47, 47),        -- BEV
    (48, '7SAYGDEE7N', 'TESLA MODEL Y', 2022, 3, 2, 48, 48),     -- BEV
    (49, '5YJ3E1EB7N', 'TESLA MODEL 3', 2022, 3, 2, 49, 49),     -- BEV
    (50, '1G1FZ6S07N', 'CHEVROLET BOLT EV', 2022, 12, 2, 50, 50),   -- BEV
    (51, '5UXTA6C01P', 'BMW X5', 2023, 1, 1, 51, 51),            -- PHEV
    (52, '5UXTA6C05P', 'BMW X5', 2023, 1, 1, 52, 52),            -- PHEV
    (53, '5UXTA6C06P', 'BMW X5', 2023, 1, 1, 53, 53),            -- PHEV
    (54, '5UXTA6C01P', 'BMW X5', 2023, 1, 1, 54, 54),            -- PHEV
    (55, '5UXTA6C02P', 'BMW X5', 2023, 1, 1, 55, 55),            -- PHEV
    (56, '5UXTA6C04P', 'BMW X5', 2023, 1, 1, 56, 56),            -- PHEV
    (57, '1FMCU0E1XP', 'FORD ESCAPE', 2023, 2, 1, 57, 57),       -- PHEV
    (58, '1FMCU0E19P', 'FORD ESCAPE', 2023, 2, 1, 58, 58),       -- PHEV
    (59, '5YJ3E1EA0P', 'TESLA MODEL 3', 2023, 3, 2, 59, 59),     -- BEV
    (60, '5YJ3E1ECXP', 'TESLA MODEL 3', 2023, 3, 2, 60, 60),     -- BEV
    (61, '5YJ3E1EA8P', 'TESLA MODEL 3', 2023, 3, 2, 61, 61),     -- BEV
    (62, '5YJSA1E54P', 'TESLA MODEL S', 2023, 3, 2, 62, 62),     -- BEV
    (63, '7SAXCBE59P', 'TESLA MODEL X', 2023, 3, 2, 63, 63),     -- BEV
    (64, '7SAYGAEE1P', 'TESLA MODEL Y', 2023, 3, 2, 64, 64),     -- BEV
    (65, '7SAYGAEE9P', 'TESLA MODEL Y', 2023, 3, 2, 65, 65),     -- BEV
    (66, '7SAYGDEE6P', 'TESLA MODEL Y', 2023, 3, 2, 66, 66),     -- BEV
    (67, '7SAYGDEE4P', 'TESLA MODEL Y', 2023, 3, 2, 67, 67),     -- BEV
    (68, 'JTDACACUXP', 'TOYOTA PRIUS', 2023, 4, 1, 68, 68),      -- PHEV
    (69, 'JTDACACU8P', 'TOYOTA PRIUS', 2023, 4, 1, 69, 69),      -- PHEV
    (70, 'JTMAB3FV4P', 'TOYOTA RAV4 PRIME', 2023, 4, 1, 70, 70),  -- PHEV
    (71, 'JTMFB3FV8P', 'TOYOTA RAV4 PRIME', 2023, 4, 1, 71, 71),  -- PHEV
    (72, 'JTMAB3FV3P', 'TOYOTA RAV4 PRIME', 2023, 4, 1, 72, 72),  -- PHEV
    (73, 'JTMAB3FV5P', 'TOYOTA RAV4 PRIME', 2023, 4, 1, 73, 73),  -- PHEV
    (74, 'JTMEB3FV5P', 'TOYOTA RAV4 PRIME', 2023, 4, 1, 74, 74),  -- PHEV
    (75, '1V2GNPE80P', 'VOLKSWAGEN ID.4', 2023, 5, 2, 75, 75),    -- BEV
    (76, '1V2WNPE80P', 'VOLKSWAGEN ID.4', 2023, 5, 2, 76, 76),    -- BEV
    (77, '1V2VMPE83P', 'VOLKSWAGEN ID.4', 2023, 5, 2, 77, 77),    -- BEV
    (78, '1V2GNPE84P', 'VOLKSWAGEN ID.4', 2023, 5, 2, 78, 78),    -- BEV
    (79, '1V2GNPE86P', 'VOLKSWAGEN ID.4', 2023, 5, 2, 79, 79),    -- BEV
    (80, '1V2JNPE8XP', 'VOLKSWAGEN ID.4', 2023, 5, 2, 80, 80);    -- BEV


SELECT * FROM Manufacturers;
SELECT * FROM ChargingStations;
SELECT * FROM ChargingStations_Manufacturers;
SELECT * FROM Batteries;
SELECT * FROM Owners;
SELECT * FROM Sales;
SELECT * FROM Cars;

