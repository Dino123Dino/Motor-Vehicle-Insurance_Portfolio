-- ==========================================
-- 1. DATA CLEANING & TYPE CONVERSION
-- ==========================================

-- Initial table creation (Raw Staging Table)
CREATE TABLE motor_vehicle_insurance (
    id VARCHAR(50),
    date_start_contract VARCHAR(50),
    date_last_renewal VARCHAR(50),
    date_next_renewal VARCHAR(50),
    distribution_channel VARCHAR(50),
    date_birth VARCHAR(50),
    date_driving_licence VARCHAR(50),
    seniority VARCHAR(50),
    policies_in_force VARCHAR(50),
    max_policies VARCHAR(50),
    max_products VARCHAR(50),
    lapse VARCHAR(50),
    date_lapse VARCHAR(50),
    payment VARCHAR(50),
    premium VARCHAR(50),
    cost_claims_year VARCHAR(50),
    n_claims_year VARCHAR(50),
    n_claims_history VARCHAR(50),
    r_claims_history VARCHAR(50),
    type_risk VARCHAR(50),
    area VARCHAR(50),
    second_driver VARCHAR(50),
    year_matriculation VARCHAR(50),
    power VARCHAR(50),
    cylinder_capacity VARCHAR(50),
    value_vehicle VARCHAR(50),
    n_doors VARCHAR(50),
    type_fuel VARCHAR(50),
    length VARCHAR(50),
    weight VARCHAR(50)
);

-- Check row count, unique IDs, and duplicate occurrences
SELECT 
    COUNT(DISTINCT id) AS unique_count,
    COUNT(*) AS number_of_rows,
    COUNT(*) - COUNT(DISTINCT id) AS number_of_duplicates
FROM motor_vehicle_insurance;

-- Identify repeated IDs
SELECT
    id,
    COUNT(*) AS repetition_count
FROM motor_vehicle_insurance
GROUP BY id
HAVING COUNT(*) > 1
LIMIT 100;

-- Inspect initial sample data
SELECT *
FROM motor_vehicle_insurance
LIMIT 100;

-- Fix misaligned date and distribution channel column headers
ALTER TABLE motor_vehicle_insurance RENAME COLUMN distribution_channel TO temp_date_birth;
ALTER TABLE motor_vehicle_insurance RENAME COLUMN date_birth TO temp_date_driving_licence;
ALTER TABLE motor_vehicle_insurance RENAME COLUMN date_driving_licence TO temp_distribution_channel;

ALTER TABLE motor_vehicle_insurance RENAME COLUMN temp_date_birth TO date_birth;
ALTER TABLE motor_vehicle_insurance RENAME COLUMN temp_date_driving_licence TO date_driving_licence;
ALTER TABLE motor_vehicle_insurance RENAME COLUMN temp_distribution_channel TO distribution_channel;

-- Handle default/invalid date entries in distribution_channel before type conversion
UPDATE motor_vehicle_insurance
SET distribution_channel = NULL
WHERE distribution_channel = '00/01/1900';

ALTER TABLE motor_vehicle_insurance
ALTER COLUMN distribution_channel TYPE INTEGER
USING distribution_channel::INTEGER;

-- Convert string dates to standard DATE data types
ALTER TABLE motor_vehicle_insurance ALTER COLUMN date_start_contract TYPE DATE USING date_start_contract::DATE;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN date_last_renewal TYPE DATE USING date_last_renewal::DATE;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN date_next_renewal TYPE DATE USING date_next_renewal::DATE;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN date_birth TYPE DATE USING date_birth::DATE;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN date_driving_licence TYPE DATE USING date_driving_licence::DATE;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN date_lapse TYPE DATE USING date_lapse::DATE;

-- Verify date ranges for logical anomalies
SELECT 
    MIN(date_start_contract) AS min_start_contract, MAX(date_start_contract) AS max_start_contract,
    MIN(date_last_renewal) AS min_last_renewal, MAX(date_last_renewal) AS max_last_renewal,
    MIN(date_next_renewal) AS min_next_renewal, MAX(date_next_renewal) AS max_next_renewal,
    MIN(date_birth) AS min_date_birth, MAX(date_birth) AS max_date_birth,
    MIN(date_driving_licence) AS min_driving_licence, MAX(date_driving_licence) AS max_driving_licence,
    MIN(date_lapse) AS min_date_lapse, MAX(date_lapse) AS max_date_lapse
FROM motor_vehicle_insurance;

-- Logical sanity check across date fields
SELECT * 
FROM motor_vehicle_insurance
WHERE 
    date_next_renewal < date_last_renewal OR 
    date_birth > date_driving_licence OR 
    date_driving_licence < date_birth + INTERVAL '15 years' OR
    (date_lapse IS NOT NULL AND date_lapse < date_start_contract);

-- Standardize numeric metrics and replace invalid 'NA' or 0 strings with NULL
UPDATE motor_vehicle_insurance SET power = NULL WHERE power = '0';
UPDATE motor_vehicle_insurance SET length = NULL WHERE length = 'NA';
UPDATE motor_vehicle_insurance SET type_fuel = NULL WHERE type_fuel = 'NA';

ALTER TABLE motor_vehicle_insurance ALTER COLUMN premium TYPE NUMERIC USING premium::NUMERIC;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN cost_claims_year TYPE NUMERIC USING cost_claims_year::NUMERIC;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN value_vehicle TYPE NUMERIC USING value_vehicle::NUMERIC;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN power TYPE INT USING power::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN cylinder_capacity TYPE INT USING cylinder_capacity::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN n_doors TYPE INT USING n_doors::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN length TYPE NUMERIC USING length::NUMERIC;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN weight TYPE INT USING weight::INT;

ALTER TABLE motor_vehicle_insurance ALTER COLUMN seniority TYPE INT USING seniority::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN policies_in_force TYPE INT USING policies_in_force::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN max_policies TYPE INT USING max_policies::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN max_products TYPE INT USING max_products::INT;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN lapse TYPE INT USING lapse::INT;

ALTER TABLE motor_vehicle_insurance ALTER COLUMN n_claims_year TYPE INTEGER USING n_claims_year::INTEGER;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN n_claims_history TYPE INTEGER USING n_claims_history::INTEGER;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN r_claims_history TYPE NUMERIC USING r_claims_history::NUMERIC;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN type_risk TYPE INTEGER USING type_risk::INTEGER;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN area TYPE INTEGER USING area::INTEGER;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN second_driver TYPE INTEGER USING second_driver::INTEGER;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN year_matriculation TYPE INTEGER USING year_matriculation::INTEGER;

ALTER TABLE motor_vehicle_insurance ADD COLUMN fact_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;
ALTER TABLE motor_vehicle_insurance ALTER COLUMN id TYPE INTEGER USING id::INTEGER;