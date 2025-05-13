-- Global Food Waste and Environmental Impact Analysis - Exploratory Data analysis Case Study (SQL PROJECT)
-- Author: Rahma Ahmed
-- Description: This SQL case study explores the different sources of food waste and the affect of each on the enviroment, and the affect of each on the enviroment through produced CO2 emissions, as well as explore the relationship between food waste and GDP across countries using two datasets: food_waste_source_by_country and gdp_by_country.
-- Data sources:
--1. Food Waste data: https://www.kaggle.com/datasets/joebeachcapital/food-waste
--2. GDP data: https://www.kaggle.com/datasets/ppb00x/country-gdp
-- ───────────────────────────────────────────────

## 1. Preview Data 
SELECT * FROM `food-waste-459514.food_waste_analysis.food_waste_source_by_country` LIMIT 20;
SELECT * FROM `food-waste-459514.food_waste_analysis.gdp_by_country` LIMIT 20;

-- Dataset 1: food_waste_source_by_country
--   - combined_kg_per_capita_per_year
--   - household_kg_per_capita_per_year
--   - retail_kg_per_capita_per_year
--   - food_service_kg_per_capita_per_year
--   - confidence_in_estimate
--   - region
-- Dataset 2: gdp_by_country
--   - country
--   - gdp_per_capita (USD)
--   - population (millions)
--   - continent

-- ───────────────────────────────────────────────

## 2.  Data Cleaning & Preparation
# 2.1: Format and cast numeric fields
CREATE OR REPLACE TABLE `food-waste-459514.food_waste_analysis.food_waste_source_by_country` AS
SELECT
  country,
  CAST(combined_kg_per_capita_per_year AS FLOAT64) AS combined_kg_per_capita_per_year,
  CAST(household_kg_per_capita_per_year AS FLOAT64) AS household_kg_per_capita_per_year,
  CAST(household_tonnes_per_year AS FLOAT64) AS household_tonnes_per_year,
  CAST(retail_kg_per_capita_per_year AS FLOAT64) AS retail_kg_per_capita_per_year,
  CAST(retail_tonnes_per_year AS FLOAT64) AS retail_tonnes_per_year,
  CAST(food_service_kg_per_capita_per_year AS FLOAT64) AS food_service_kg_per_capita_per_year,
  CAST(food_service_tonnes_per_year AS FLOAT64) AS food_service_tonnes_per_year,
  confidence_in_estimate,
  region
FROM `food-waste-459514.food_waste_analysis.food_waste_source_by_country`;


CREATE OR REPLACE TABLE `food-waste-459514.food_waste_analysis.gdp_by_country` AS
SELECT
  Country AS country,
  Continent AS continent,
  CAST(population_millions AS FLOAT64) AS population_millions,
  CAST(IMF_GDP AS FLOAT64) AS imf_gdp,
  CAST(UN_GDP AS FLOAT64) AS un_gdp,
  CAST(GDP_per_capita AS FLOAT64) AS gdp_per_capita
FROM `food-waste-459514.food_waste_analysis.gdp_by_country`;

# 2.2: Look for rows with nulls or zero values in waste columns
SELECT *
FROM `food-waste-459514.food_waste_analysis.food_waste_source_by_country`
WHERE 
  combined_kg_per_capita_per_year IS NULL
  OR SAFE_CAST(combined_kg_per_capita_per_year AS FLOAT64) = 0
  OR household_kg_per_capita_per_year IS NULL
  OR retail_kg_per_capita_per_year IS NULL
  OR food_service_kg_per_capita_per_year IS NULL;
-- No nulls or zero values found in the  food waste dataset.

SELECT *
FROM `food-waste-459514.food_waste_analysis.gdp_by_country`
WHERE 
  country IS NULL
  OR SAFE_CAST(population_millions AS FLOAT64) = 0
  OR SAFE_CAST(imf_gdp AS FLOAT64) = 0 
  OR SAFE_CAST(un_gdp AS FLOAT64) = 0 
  OR SAFE_CAST(gdp_per_capita AS FLOAT64) = 0 
  OR continent IS NULL;
-- Only IMF GDP and UN GDP have zero values, since this part is not very crucial to the analysis they will not be dropped for now.

## 2.3:Check for duplicates 
SELECT DISTINCT country
FROM `food-waste-459514.food_waste_analysis.food_waste_source_by_country`
ORDER BY country;
-- No duplicates found in the food waste table.

SELECT DISTINCT country
FROM `food-waste-459514.food_waste_analysis.gdp_by_country`
ORDER BY country;
-- No duplicates found in the GDP table.

# 2.4: Find countries in the food waste dataset that do not match the GDP dataset
SELECT f.country
FROM `food-waste-459514.food_waste_analysis.food_waste_source_by_country` f
LEFT JOIN `food-waste-459514.food_waste_analysis.gdp_by_country` g
ON LOWER(f.country) = LOWER(g.country)
WHERE g.country IS NULL;

## 2.5: Apply manual mapping to food waste countries
-- Since the naming of countries is diffrent in each dataset, some countries are not named exactly the same and need to be unified before the tables are joined. 
CREATE OR REPLACE TABLE `food-waste-459514.food_waste_analysis.food_waste_country_mapped` AS
SELECT 
  CASE
    WHEN country = 'United States of America' THEN 'United States'
    WHEN country = 'Czechia' THEN 'Czech Republic'
    WHEN country = 'Republic of Korea' THEN 'South Korea'
    WHEN country = 'China, Macao SAR' THEN 'Macau'
    WHEN country = 'China, Hong Kong SAR' THEN 'Hong Kong'
    WHEN country = 'Sint Maarten (Dutch part)' THEN 'Sint Maarten'
    WHEN country = 'CuraÃ§ao' THEN 'Curacao'
    WHEN country = 'Brunei Darussalam' THEN 'Brunei'
    WHEN country = 'Russian Federation' THEN 'Russia'
    WHEN country = 'Iran (Islamic Republic of)' THEN 'Iran'
    WHEN country = 'Venezuela (Boliv. Rep. of)' THEN 'Venezuela'
    WHEN country = 'Viet Nam' THEN 'Vietnam'
    WHEN country = 'Congo' THEN 'Republic of the Congo'
    WHEN country = 'Bolivia (Plurin. State of)' THEN 'Bolivia'
    WHEN country = 'Republic of Moldova' THEN 'Moldova'
    WHEN country LIKE 'Lao People%Dem. Rep.' THEN 'Laos'
    WHEN country LIKE 'Côte d%Ivoire' THEN 'Ivory Coast'
    WHEN country = 'Cabo Verde' THEN 'Cape Verde'
    WHEN country = 'Micronesia (Fed. States of)' THEN 'Micronesia'
    WHEN country = 'State of Palestine' THEN 'Palestine'
    WHEN country = 'Syrian Arab Republic' THEN 'Syria'
    WHEN country = 'Saint Vincent & Grenadines' THEN 'Saint Vincent and the Grenadines'
    WHEN country = 'Congo' THEN 'Republic of the Congo'
    WHEN country = 'United Rep. of Tanzania' THEN 'Tanzania'
    WHEN country = 'Curaçao' THEN 'Curacao'
    WHEN country LIKE 'Dem.%People%s Rep.%Korea' THEN 'North Korea'

    
 
    ELSE country
  END AS country_cleaned,
  *
EXCEPT(country)
FROM `food-waste-459514.food_waste_analysis.food_waste_source_by_country`
WHERE country NOT IN (
  'Faroe Islands',
  'Gibraltar',
  'Guam',
  'Isle of Man',
  'Saint Martin (French part)',
  'United States Virgin Islands',
  'Northern Mariana Islands',
  'Dem. Rep. of the Congo'
);

# 2.6: check if there are still any countries that do not match the GDP dataset
SELECT f.country_cleaned
FROM `food-waste-459514.food_waste_analysis.food_waste_country_mapped` f
LEFT JOIN `food-waste-459514.food_waste_analysis.gdp_by_country` g
ON LOWER(f.country_cleaned) = LOWER(g.country)
WHERE g.country IS NULL;
--All good.

# 2.7 Join the tables
CREATE OR REPLACE TABLE `food-waste-459514.food_waste_analysis.food_waste_gdp_joined` AS
SELECT 
  f.country_cleaned AS country,
  f.combined_kg_per_capita_per_year,
  f.household_kg_per_capita_per_year,
  f.retail_kg_per_capita_per_year,
  f.food_service_kg_per_capita_per_year,
  f.confidence_in_estimate,
  f.region,
  g.gdp_per_capita,
  g.population_millions,
  g.continent
FROM `food-waste-459514.food_waste_analysis.food_waste_country_mapped` f
JOIN `food-waste-459514.food_waste_analysis.gdp_by_country` g
  ON LOWER(f.country_cleaned) = LOWER(g.country);

-- ───────────────────────────────────────────────

## 3. Data Enrichment: Add Estimated CO2 Emissions
--As per estimates from the FAO’s Food Wastage Footprint report,1kg of food waste produces around 2.5kg of CO2 emissions, this estimate will be used to calculate emissions created.
CREATE OR REPLACE TABLE `food-waste-459514.food_waste_analysis.food_gdp_joined` AS
SELECT 
  f.country_cleaned as country,
  f.combined_kg_per_capita_per_year,
  f.household_kg_per_capita_per_year,
  f.retail_kg_per_capita_per_year,
  f.food_service_kg_per_capita_per_year,
  f.confidence_in_estimate,
  f.region,
  g.gdp_per_capita,
  g.population_millions,
  g.continent,

-- Emissions by sector
  ROUND(f.household_kg_per_capita_per_year * 2.5, 2) as emissions_household_kg_per_capita,
  ROUND(f.retail_kg_per_capita_per_year * 2.5, 2) AS emissions_retail_kg_per_capita,
  ROUND(f.food_service_kg_per_capita_per_year * 2.5, 2) as emissions_food_service_kg_per_capita,
  ROUND(f.combined_kg_per_capita_per_year * 2.5, 2) as emissions_total_kg_per_capita

FROM `food-waste-459514.food_waste_analysis.food_waste_country_mapped` f
JOIN `food-waste-459514.food_waste_analysis.gdp_by_country` g
  ON LOWER(f.country_cleaned) = LOWER(g.country);


-- ───────────────────────────────────────────────

## 4. EDA and insights
# 4.1: Top contributier in sectors 
--How much does each sector contribute to emissions across countries?
SELECT 
  ROUND(AVG(emissions_household_kg_per_capita), 2) AS avg_emissions_household,
  ROUND(AVG(emissions_retail_kg_per_capita), 2) AS avg_emissions_retail,
  ROUND(AVG(emissions_food_service_kg_per_capita), 2) AS avg_emissions_food_service,
  ROUND(AVG(emissions_total_kg_per_capita), 2) AS avg_emissions_total
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`;
-- Intrestingly, the average emission produced by households does actually take the first spot! 1st question answered.

# 4.2: Top 10 countries by total emissions per capita
SELECT country, emissions_total_kg_per_capita, combined_kg_per_capita_per_year
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`
ORDER BY emissions_total_kg_per_capita DESC
LIMIT 10;

# 4.3: GDP vs Emissions 
-- Will look at total emission first
SELECT 
  country, 
  gdp_per_capita, 
  emissions_total_kg_per_capita
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`;

-- Then household emission only 
SELECT 
  country, 
  gdp_per_capita, 
  emissions_household_kg_per_capita
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`;

--As per the Pearson correlation Coefficient, the correlation using a Pearson correlation is -0.27 between GDP per capita, and food waste emissions per capita. This suggests a negative correlation that is pretty weak, which means countries with higher GDPs -may- emit slightly less CO₂ per capita from food waste, however, the relationship is not strong enough to draw any firm conclusions, indicating that other factors likely play a significant role, which answers our 2nd question so far.

# 4.4: Region-wise emission vs GDP
Select region,
  ROUND(AVG(emissions_total_kg_per_capita), 2) AS avg_emissions_total,
  ROUND(AVG(gdp_per_capita), 0) AS avg_gdp_per_capita_usd
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`
GROUP BY region
ORDER BY avg_emissions_total DESC;

--After looking at the averages, lets also take a look at the totals population scaled.
SELECT 
  region,
  ROUND(SUM(population_millions * emissions_total_kg_per_capita), 0) AS total_emissions_kg,
  ROUND(SUM(population_millions * gdp_per_capita), 0) AS total_gdp_usd,
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`
GROUP BY region
ORDER BY total_emissions_kg DESC;

SELECT 
  region,
  ROUND(SUM(population_millions * emissions_total_kg_per_capita), 0) AS total_emissions_kg,
  ROUND(SUM(population_millions * gdp_per_capita), 0) AS total_gdp_usd,
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`
GROUP BY region
ORDER BY total_gdp_usd DESC;
-- The Eastern Asia region seems to take the 1st spot on both, but the  value of R is 0.4348 (Pearson Correlation Coefficient) which still is a weak relationship/correlation.
 
# 4.5: Average emissions per capita by sector
SELECT
  ROUND(AVG(emissions_household_kg_per_capita), 2) AS avg_household_emissions,
  ROUND(AVG(emissions_retail_kg_per_capita), 2) AS avg_retail_emissions,
  ROUND(AVG(emissions_food_service_kg_per_capita), 2) AS avg_food_service_emissions
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`;

# 4.6: Total global emission (population scaled)
SELECT
  ROUND(SUM(population_millions * emissions_household_kg_per_capita), 0) AS total_emissions_household,
  ROUND(SUM(population_millions * emissions_retail_kg_per_capita), 0) AS total_emissions_retail,
  ROUND(SUM(population_millions * emissions_food_service_kg_per_capita), 0) AS total_emissions_food_service
FROM `food-waste-459514.food_waste_analysis.food_gdp_joined`;
-- This shows that household food waste alone is responsible for over 60% of global food waste emissions,food services play a significant role, but still less than half of household emissions, which means that in order to reduce food waste we should actually start our kitchens if we want to see real impact, and save our lovely planet and our home, planet earth.

-- And that answers my third and final question, Thank you! :)
