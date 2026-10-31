Motor Vehicle Insurance Portfolio Analysis

Project Overview
This project focuses on analyzing an auto insurance portfolio to evaluate policy performance, claim frequency, total payout costs, and overall profitability. Using a relational data warehousing approach, raw insurance data was modeled into a Star Schema to support efficient querying and interactive reporting in Power BI.

---

Tech Stack & Tools
SQL (PostgreSQL / pgAdmin): Database design, schema creation, data transformation, and aggregation.
Power BI: Data modeling, implementation of DAX time-intelligence metrics, and visual dashboard build.
Git & GitHub: Version control and documentation.

---

Data Architecture & Modeling
The data model follows a classic Star Schema design centered around insurance transactions and policy metrics:
Fact Table: `fact_motor_vehicle_insurance` — contains core transactional metrics including written premiums, claim amounts, and deductible figures.
Dimension Tables: 
	- dim_client — demographic and risk profile details of policyholders.
	- dim_contract — terms, policy types, and coverage agreements.
	- dim_vehicle — vehicle specifications, age categories, and risk classes.
	- dim_date — dedicated calendar table established in Power BI to enable seamless time-intelligence calculations (YoY growth, YTD premiums, moving averages).

---

Key Analytical Focus
Loss Ratio & Profitability: Tracking the ratio of paid claims against total premiums earned across different vehicle categories.
Risk Segmentation: Identifying high-risk client segments and vehicle classes to inform underwriting strategies.
Temporal Trends: Evaluating seasonal patterns in claims and contract renewals using dynamic time filtering.

---

Repository Structure
sql — Data model DDL scripts and analytical queries.
dashboards — Power BI reports (`Insurance_Portfolio_Analysis.pbix`) showcasing key insurance metrics.