-- ==========================================
-- 3. EXPLORATORY & BUSINESS ANALYTICS (KPIs & YoY)
-- ==========================================

-- Premiums, Claim Costs, and Underwriting Profit by Distribution Channel (All Time)
SELECT 
    c.distribution_channel,
    SUM(f.premium) AS total_premium,
    COUNT(f.premium) AS total_number_of_contracts,
    SUM(f.cost_claims_year) AS total_cost_incurred,
    COUNT(f.cost_claims_year) FILTER (WHERE f.cost_claims_year > 0) AS count_cost_incurred,
    SUM(f.premium) - SUM(f.cost_claims_year) AS underwriting_profit
FROM fact_motor_vehicle_insurance AS f
LEFT JOIN dim_contract AS c ON f.contract_id = c.contract_id
GROUP BY GROUPING SETS ((distribution_channel), ())
ORDER BY total_premium DESC;

-- Performance Breakdown by Risk Type (Year 2018)
SELECT 
    v.type_risk,
    SUM(f.premium) AS total_premium,
    COUNT(f.premium) AS total_number_of_contracts,
    SUM(f.cost_claims_year) AS total_cost_incurred,
    COUNT(f.cost_claims_year) FILTER (WHERE f.cost_claims_year > 0) AS count_cost_incurred,
    SUM(f.premium) - SUM(f.cost_claims_year) AS underwriting_profit
FROM fact_motor_vehicle_insurance AS f
LEFT JOIN dim_vehicle AS v ON f.vehicle_id = v.vehicle_id
LEFT JOIN dim_contract AS dc ON dc.contract_id = f.contract_id
WHERE EXTRACT(YEAR FROM dc.date_last_renewal) = 2018
GROUP BY GROUPING SETS ((v.type_risk), ())
ORDER BY total_premium DESC;

-- Monthly Performance Breakdown for 2018
SELECT
    TO_CHAR(dc.date_last_renewal, 'TMMonth') AS month,
    SUM(f.premium) AS total_premium,
    COUNT(f.premium) AS total_number_of_contracts,
    SUM(f.cost_claims_year) AS total_cost_incurred,
    COUNT(f.cost_claims_year) FILTER (WHERE f.cost_claims_year > 0) AS count_cost_incurred,
    SUM(f.premium) - SUM(f.cost_claims_year) AS underwriting_profit
FROM fact_motor_vehicle_insurance AS f
LEFT JOIN dim_contract AS dc ON f.contract_id = dc.contract_id
WHERE EXTRACT(YEAR FROM dc.date_last_renewal) = 2018
GROUP BY GROUPING SETS ((EXTRACT(MONTH FROM dc.date_last_renewal), TO_CHAR(dc.date_last_renewal, 'TMMonth')), ())
ORDER BY EXTRACT(MONTH FROM dc.date_last_renewal) ASC NULLS LAST;

-- Overall Year-over-Year (YoY) Growth Metrics (2017 vs 2018)
WITH YoY AS (
    SELECT 
        SUM(f.premium) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2017) AS total_premium_2017,
        SUM(f.premium) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2018) AS total_premium_2018,
        SUM(f.premium - f.cost_claims_year) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2017) AS underwriting_profit_2017,
        SUM(f.premium - f.cost_claims_year) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2018) AS underwriting_profit_2018
    FROM fact_motor_vehicle_insurance AS f
    LEFT JOIN dim_contract AS c ON f.contract_id = c.contract_id
)
SELECT 
    total_premium_2017, 
    total_premium_2018,
    ROUND(((total_premium_2018 - total_premium_2017) / total_premium_2017) * 100, 2) AS YoY_percentage_2017_2018,
    underwriting_profit_2017,
    underwriting_profit_2018,
    ROUND(((underwriting_profit_2018 - underwriting_profit_2017) / underwriting_profit_2017) * 100, 2) AS YoY_underwriting_percentage_2017_2018
FROM YoY;

-- Detailed YoY Growth Breakdown across Channels and Risk Types
WITH YoY AS (
    SELECT 
        c.distribution_channel,
        v.type_risk,
        SUM(f.premium) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2017) AS total_premium_2017,
        SUM(f.premium) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2018) AS total_premium_2018,
        SUM(f.cost_claims_year) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2017) AS total_cost_claims_2017,
        SUM(f.cost_claims_year) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2018) AS total_cost_claims_2018,
        SUM(f.premium - f.cost_claims_year) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2017) AS underwriting_profit_2017,
        SUM(f.premium - f.cost_claims_year) FILTER (WHERE EXTRACT(YEAR FROM c.date_last_renewal) = 2018) AS underwriting_profit_2018
    FROM fact_motor_vehicle_insurance AS f
    LEFT JOIN dim_vehicle AS v ON f.vehicle_id = v.vehicle_id
    LEFT JOIN dim_contract AS c ON f.contract_id = c.contract_id
    GROUP BY GROUPING SETS ((c.distribution_channel, v.type_risk), (c.distribution_channel), (v.type_risk), ())
)
SELECT 
    distribution_channel,
    type_risk,
    total_premium_2017,
    total_premium_2018,
    ROUND(((total_premium_2018 - total_premium_2017) / NULLIF(total_premium_2017, 0)) * 100, 2) AS YoY_percentage_2017_2018,
    total_cost_claims_2017,
    total_cost_claims_2018,
    ROUND(((total_cost_claims_2018 - total_cost_claims_2017) / NULLIF(total_cost_claims_2017, 0)) * 100, 2) AS YoY_cost_claims_percentage_2017_2018,
    underwriting_profit_2017,
    underwriting_profit_2018,
    ROUND(((underwriting_profit_2018 - underwriting_profit_2017) / NULLIF(underwriting_profit_2017, 0)) * 100, 2) AS YoY_underwriting_percentage_2017_2018
FROM YoY
ORDER BY distribution_channel DESC NULLS LAST, type_risk DESC NULLS LAST;