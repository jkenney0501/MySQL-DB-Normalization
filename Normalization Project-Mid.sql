/***********************************************************************

Normalizing a relational database example.

The example uses a real world scenario based on business requirements

*************************************************************************/

/*SET DEFAULT SCHEMA*/
USE mavenmoviesmini;

/*************************************************************************
Q1. In the current schema, how many tables and what do they represent? 
A1. There is 1 table that represents the store employees/location, its inventory/movie info and its movies.
What is the overall opinion of the DB? Its ineficient with redundancies due to repeat information on the table columns within the table itself.
A2.Currently mavenmoviesmini is one table with 4581 records and is not normalized.
Summary: by breaking the table into 3 separate tables, the schema becomes normalized as the stores table holds only 2 distinct records
which saves storage space overall and wil allow efficient scaling of the business.
*************************************************************************/

-- View the current table
SELECT * 
FROM inventory_non_normalized;

-- Get count 4,581
SELECT count(*)
FROM inventory_non_normalized;

 /*************************************************************************
Q2. If you wanted to break out the data from the inventory_non_normailed table into multiple tables, how many tables would be ideal?
A2. 3 tables would be ideal considering scale of the business in the future.
What would they be named?

-- Inventory (Inventory_id (pk), film_id(fk), store_id(fk))
-- film ( film_id(pk), title, description, release_year_, rental_rate_, rating)
-- store (store_id (pk), store_manager_first_name, store_manager_last_name, store_address, store_city, store_district)

*************************************************************************/




/*************************************************************************
Q3. Based on Q2., create new schema with the tables you think will best serve this data set.
*************************************************************************/

CREATE SCHEMA mavenmoviesmini_normalized;

-- use new schema as default
USE mavenmoviesmini_normalized;

-- Break table into 3 so it can be normalized with stores having store id as a primary ky on it and a foreign key on film
-- create inventory table
-- Inventory (Inventory_id (pk), film_id(fk), store_id(fk))
CREATE TABLE inventory (
	inventory_id INT(11) NOT NULL
    ,film_id INT(11) NOT NULL
    ,store_id INT(11) NOT NULL
    ,PRIMARY KEY (inventory_id)
);


-- create film table
-- film ( film_id(pk), title, description, release_year_, rental_rate_, rating)
create table film (
	film_id INT NOT NULL
    ,title VARCHAR(255) NOT NULL
    ,description VARCHAR(255) NOT NULL
    ,release_year INT NOT NULL
    ,rental_rate DECIMAL(6,2) NOT NULL
    ,rating VARCHAR(45) NOT NULL
    ,PRIMARY KEY(film_id)
);
  
-- create store table
-- store (store_id (pk), store_manager_first_name, store_manager_last_name, store_address, store_city, store_district)
create table store (
	store_id INT NOT NULL
    ,store_manager_first_name VARCHAR(45) NOT NULL
    ,store_manager_last_name VARCHAR(45) NOT NULL
    ,store_address VARCHAR(45) NOT NULL
    ,store_city VARCHAR(45) NOT NULL
    ,store_district VARCHAR(45) NOT NULL
    ,PRIMARY KEY(store_id)
);
    
-- create foreign keys to inventory and store table
ALTER TABLE `mavenmoviesmini_normalized`.`inventory` 
ADD INDEX `inventory_film_id_idx` (`film_id` ASC) VISIBLE,
ADD INDEX `inventory_store_id_idx` (`store_id` ASC) VISIBLE;
;
ALTER TABLE `mavenmoviesmini_normalized`.`inventory` 
ADD CONSTRAINT `inventory_film_id`
  FOREIGN KEY (`film_id`)
  REFERENCES `mavenmoviesmini_normalized`.`film` (`film_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,
ADD CONSTRAINT `inventory_store_id`
  FOREIGN KEY (`store_id`)
  REFERENCES `mavenmoviesmini_normalized`.`store` (`store_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;


/*************************************************************************
Q4. Next, use the data from the original schema to pupoulate the tables in the newly optimized schema.
*************************************************************************/

INSERT INTO inventory (inventory_id, film_id, store_id)
SELECT DISTINCT 
inventory_id
,film_id
,store_id
FROM mavenmoviesmini.inventory_non_normalized;
 -- error 1452 FOREIGN KEY CONSTRAINT!!!
 -- use GUI to remove FK from inventory table in the normailzed db.
 -- or run the code to drop the fk's
 -- run above again

-- check the table 4,581
 SELECT count(*)
 FROM inventory;

-- do the saem for the film table
-- film ( film_id(pk), title, description, release_year_, rental_rate_, rating)
INSERT INTO film (film_id, title, description, release_year, rental_rate, rating)
SELECT DISTINCT
film_id
,title
,description
,release_year
,rental_rate
,rating
FROM mavenmoviesmini.inventory_non_normalized;

-- check the table 958
SELECT count(*)
FROM film;

-- do the same for the store table
-- store (store_id (pk), store_manager_first_name, store_manager_last_name, store_address, store_city, store_district)
INSERT INTO store (store_id, store_manager_first_name, store_manager_last_name, store_address, store_city, store_district)
SELECT DISTINCT
store_id
,store_manager_first_name
,store_manager_last_name
,store_address
,store_city
,store_district
FROM mavenmoviesmini.inventory_non_normalized;

-- check the table 2
SELECT count(*)
FROM store;


/*************************************************************************
Q5. Make sure the new tables have the proper primary keys defined and that the applicable foreign keys are added.
Add any constarints that should apply as well.
A1. Foreign keys to be added, all are indexed and NOT NULL. Most columns are NOT NULL as well.
*************************************************************************/
-- adding back the foreign keys that were deleted earlier during the INSERT INTO process
ALTER TABLE `mavenmoviesmini_normalized`.`inventory` 
ADD INDEX `inventory_film_id_idx` (`film_id` ASC) VISIBLE,
ADD INDEX `inventory_store_id_idx` (`store_id` ASC) VISIBLE;
;
ALTER TABLE `mavenmoviesmini_normalized`.`inventory` 
ADD CONSTRAINT `inventory_film_id`
  FOREIGN KEY (`film_id`)
  REFERENCES `mavenmoviesmini_normalized`.`film` (`film_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,
ADD CONSTRAINT `inventory_store_id`
  FOREIGN KEY (`store_id`)
  REFERENCES `mavenmoviesmini_normalized`.`store` (`store_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;


/*************************************************************************
Q6. Brief summary of the work done:
One table that had much redundancy is now broken into 3 tables which reduces redundancy and creates more efficient storage
as the business scales. This will also optimize queryying the database fro reporting purposes as the primary keys are indexed and 
foreign keys are added to easily join tables for reporting purposes.
*************************************************************************/

-- Base reporting query to identify films and store locations with manager info
SELECT 
b.film_id
,b.title
,b.description
,b.release_year
,b.rental_rate
,b.rating
,c.store_address
,c.store_city
,c.store_district
from inventory as a
join film as b on a.inventory_id = b.film_id
join store as c on a.store_id = c.store_id
;

-- rental rate info
SELECT 
MAX(rental_rate) as Highest_Rate
,MIN(rental_rate) as Lowest_Rate
,ROUND(AVG(rental_rate),2) as Average_Rate
FROM film
;

-- rating counts
SELECT 
rating
,count(rating) as Ratings
FROM film
GROUP BY rating
ORDER BY 2 DESC
;