-- ==========================================
-- 2. DIMENSIONAL MODELING (STAR SCHEMA BUILD)
-- ==========================================

-- Step 1: Create Initial Fact Table
CREATE TABLE fact_motor_vehicle_insurance AS
SELECT 
    fact_id, id, date_start_contract, date_last_renewal, date_next_renewal,
    date_birth, date_driving_licence, distribution_channel, seniority,
    policies_in_force, max_policies, max_products, lapse, date_lapse,
    payment, premium, cost_claims_year, n_claims_year, n_claims_history,
    r_claims_history, type_risk, area, second_driver, year_matriculation,
    power, cylinder_capacity, value_vehicle, n_doors, type_fuel, length, weight
FROM motor_vehicle_insurance;

ALTER TABLE fact_motor_vehicle_insurance ADD PRIMARY KEY (fact_id);
ALTER TABLE fact_motor_vehicle_insurance ALTER COLUMN fact_id ADD GENERATED ALWAYS AS IDENTITY;

DROP TABLE motor_vehicle_insurance;

-- Step 2: Build dim_date Table
CREATE TABLE dim_date AS
WITH datee AS (
    SELECT 
        MIN(LEAST(date_start_contract, date_next_renewal, date_last_renewal, date_driving_licence, date_lapse)) AS min_date,
        MAX(GREATEST(date_start_contract, date_next_renewal, date_last_renewal, date_driving_licence, date_lapse)) AS max_date
    FROM fact_motor_vehicle_insurance
)
SELECT
    d::DATE AS date_key,
    EXTRACT(YEAR FROM d)::INT AS year,
    EXTRACT(QUARTER FROM d)::INT AS quarter,
    EXTRACT(MONTH FROM d)::INT AS month,
    EXTRACT(DAY FROM d)::INT AS day
FROM generate_series((SELECT min_date FROM datee)::DATE, (SELECT max_date FROM datee)::DATE, INTERVAL '1 day') AS d;

ALTER TABLE dim_date ADD PRIMARY KEY (date_key);

-- Step 3: Build dim_vehicle Dimension Table & Foreign Key Linking
CREATE TABLE dim_vehicle AS
SELECT DISTINCT
    power, cylinder_capacity, value_vehicle, n_doors, type_fuel, length, weight, type_risk, year_matriculation
FROM fact_motor_vehicle_insurance;

ALTER TABLE dim_vehicle ADD COLUMN vehicle_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
ALTER TABLE fact_motor_vehicle_insurance ADD COLUMN vehicle_id INT;

UPDATE fact_motor_vehicle_insurance AS f
SET vehicle_id = d.vehicle_id
FROM dim_vehicle AS d
WHERE f.power IS NOT DISTINCT FROM d.power
  AND f.cylinder_capacity IS NOT DISTINCT FROM d.cylinder_capacity
  AND f.value_vehicle IS NOT DISTINCT FROM d.value_vehicle
  AND f.n_doors IS NOT DISTINCT FROM d.n_doors
  AND f.type_fuel IS NOT DISTINCT FROM d.type_fuel
  AND f.length IS NOT DISTINCT FROM d.length
  AND f.weight IS NOT DISTINCT FROM d.weight
  AND f.type_risk IS NOT DISTINCT FROM d.type_risk
  AND f.year_matriculation IS NOT DISTINCT FROM d.year_matriculation;

ALTER TABLE fact_motor_vehicle_insurance
DROP COLUMN power, DROP COLUMN cylinder_capacity, DROP COLUMN value_vehicle,
DROP COLUMN n_doors, DROP COLUMN type_fuel, DROP COLUMN length, DROP COLUMN weight,
DROP COLUMN type_risk, DROP COLUMN year_matriculation;

-- Step 4: Build dim_contract Dimension Table & Foreign Key Linking
CREATE TABLE dim_contract (
    contract_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id INT,
    date_start_contract DATE,
    date_last_renewal DATE,
    date_next_renewal DATE,
    distribution_channel INT,
    date_lapse DATE
);

INSERT INTO dim_contract (id, date_start_contract, date_last_renewal, date_next_renewal, distribution_channel, date_lapse)
SELECT DISTINCT id, date_start_contract, date_last_renewal, date_next_renewal, distribution_channel, date_lapse
FROM fact_motor_vehicle_insurance;

ALTER TABLE fact_motor_vehicle_insurance ADD COLUMN contract_id BIGINT;

UPDATE fact_motor_vehicle_insurance AS f
SET contract_id = dc.contract_id
FROM dim_contract AS dc
WHERE f.id IS NOT DISTINCT FROM dc.id
  AND f.date_start_contract IS NOT DISTINCT FROM dc.date_start_contract
  AND f.date_last_renewal IS NOT DISTINCT FROM dc.date_last_renewal
  AND f.date_next_renewal IS NOT DISTINCT FROM dc.date_next_renewal
  AND f.distribution_channel IS NOT DISTINCT FROM dc.distribution_channel;

ALTER TABLE fact_motor_vehicle_insurance
DROP COLUMN id, DROP COLUMN date_start_contract, DROP COLUMN date_last_renewal, DROP COLUMN date_next_renewal, DROP COLUMN distribution_channel, DROP COLUMN date_lapse;

-- Step 5: Build dim_client Dimension Table & Foreign Key Linking
CREATE TABLE dim_client (
    client_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_birth DATE,
    date_driving_licence DATE,
    seniority INT,
    policies_in_force INT,
    max_policies INT,
    max_products INT, 
    lapse INT
);

INSERT INTO dim_client (date_birth, date_driving_licence, seniority, policies_in_force, max_policies, max_products, lapse)
SELECT DISTINCT date_birth, date_driving_licence, seniority, policies_in_force, max_policies, max_products, lapse
FROM fact_motor_vehicle_insurance;

ALTER TABLE fact_motor_vehicle_insurance ADD COLUMN client_id BIGINT;

UPDATE fact_motor_vehicle_insurance AS f
SET client_id = dc.client_id
FROM dim_client AS dc
WHERE f.date_birth IS NOT DISTINCT FROM dc.date_birth
  AND f.date_driving_licence IS NOT DISTINCT FROM dc.date_driving_licence
  AND f.seniority IS NOT DISTINCT FROM dc.seniority
  AND f.policies_in_force IS NOT DISTINCT FROM dc.policies_in_force
  AND f.max_policies IS NOT DISTINCT FROM dc.max_policies
  AND f.max_products IS NOT DISTINCT FROM dc.max_products
  AND f.lapse IS NOT DISTINCT FROM dc.lapse;