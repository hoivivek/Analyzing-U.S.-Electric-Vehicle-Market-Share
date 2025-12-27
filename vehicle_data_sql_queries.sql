USE vehicle_data;

select * FROM vehicle_data;

# Calculate the percentage of EVs, PHEVs, HEVs, and Gasoline vehicles for each state.
WITH total_count AS ( 
SELECT state, EV, PHEV, HEV, Biodiesel, Ethanol, Hydrogen, Gasoline, Diesel,
(EV + PHEV + HEV + Biodiesel + Ethanol + CNG + Propane + Hydrogen + Methanol + Gasoline + Diesel + "Unknown Fuel") AS Total 
FROM vehicle_data) 
SELECT state, Total,
ROUND((EV * 1.0 / Total)*100, 2) AS EV_Percentage, 
ROUND((PHEV * 1.0 / Total)*100, 2) AS PHEV_Percentage, 
ROUND((HEV * 1.0 / Total)*100, 2) AS HEV_Percentage, 
ROUND((Hydrogen * 1.0 / Total)*100, 2) AS Hydrogen_Percentage, 
ROUND((Gasoline * 1.0 / Total)*100, 2) AS Gasoline_Percentage,
ROUND((Diesel * 1.0 / Total)*100, 2) AS Diesel_Percentage,
ROUND((Biodiesel * 1.0 / Total)*100, 2) AS Biodiesel_Percentage,  
ROUND((Ethanol * 1.0 / Total)*100, 2) AS Ethanol_Percentage 
FROM total_count;


# Identify the top 5 states with the highest EV adoption rate (EVs as a % of all registered vehicles).
WITH total_count AS ( 
SELECT state, EV,
(EV + PHEV + HEV + Biodiesel + Ethanol + CNG + Propane + Hydrogen + Methanol + Gasoline + Diesel + "Unknown Fuel") AS Total 
FROM vehicle_data) 
SELECT state,
ROUND((EV * 1.0 / Total)*100, 2) AS EV_Percentage FROM total_count order by EV_Percentage desc limit 5;


# Compare EV adoption in California vs. other large states (e.g., Texas, Florida, New York).
WITH total_count AS ( 
SELECT state, EV,
(EV + PHEV + HEV + Biodiesel + Ethanol + CNG + Propane + Hydrogen + Methanol + Gasoline + Diesel + "Unknown Fuel") AS Total 
FROM vehicle_data) 
SELECT state,
ROUND((EV * 1.0 / Total)*100, 2) AS EV_Percentage FROM total_count where state in ('California', 'Texas', 'Florida', 'New York');


#Highlight which alternative fuels (biodiesel, ethanol, hydrogen) have meaningful presence vs. niche usage.
WITH total_count AS ( 
SELECT sum(Biodiesel) as Total_Biodiesel, sum(Ethanol) as Total_Ethanol, sum(Hydrogen) as Total_Hydrogen,
SUM(EV + PHEV + HEV + Biodiesel + Ethanol + CNG + Propane + Hydrogen + Methanol + Gasoline + Diesel + "Unknown Fuel") AS Total 
FROM vehicle_data) 
SELECT 
ROUND((Total_Biodiesel * 1.0 / Total)*100, 2) AS Biodiesel_Percentage,
CASE 
        WHEN ROUND((Total_Biodiesel * 1.0 / Total)*100, 2) > 1.0 THEN 'Meaningful' 
        ELSE 'Niche' 
    END AS Biodiesel_Status,
ROUND((Total_Ethanol * 1.0 / Total)*100, 2) AS Ethanol_Percentage,
CASE 
        WHEN ROUND((Total_Ethanol * 1.0 / Total)*100, 2) > 1.0 THEN 'Meaningful' 
        ELSE 'Niche' 
    END AS Ethanol_Status,
ROUND((Total_Hydrogen * 1.0 / Total)*100, 2) AS Hydrogen_Percentage,
CASE 
        WHEN ROUND((Total_Hydrogen * 1.0 / Total)*100, 2) > 1.0 THEN 'Meaningful' 
        ELSE 'Niche' 
    END AS Hydrogen_Status
FROM total_count; 



# Breakdown of each fuel type by percentage
WITH national_totals AS (
    SELECT
        SUM(EV) AS EV,
        SUM(PHEV) AS PHEV,
        SUM(HEV) AS HEV,
        SUM(Biodiesel) AS Biodiesel,
        SUM(Ethanol) AS Ethanol,
        SUM(CNG) AS CNG,
        SUM(Propane) AS Propane,
        SUM(Hydrogen) AS Hydrogen,
        SUM(Methanol) AS Methanol,
        SUM(Gasoline) AS Gasoline,
        SUM(Diesel) AS Diesel,
        SUM("Unknown Fuel") AS Unknown_Fuel
    FROM vehicle_data
),
total_count AS (
    SELECT *,
        (EV + PHEV + HEV + Biodiesel + Ethanol + CNG + Propane +
         Hydrogen + Methanol + Gasoline + Diesel + Unknown_Fuel) AS Total
    FROM national_totals
),
final as (
SELECT
    EV,
    PHEV,
    HEV,
    Biodiesel,
    Ethanol,
    Hydrogen,
    Gasoline,
    Diesel,
    Total,
    ROUND((EV * 100.0 / Total), 2) AS EV_Percentage,
    ROUND((PHEV * 100.0 / Total), 2) AS PHEV_Percentage,
    ROUND((HEV * 100.0 / Total), 2) AS HEV_Percentage,
    ROUND((Hydrogen * 100.0 / Total), 2) AS Hydrogen_Percentage,
    ROUND((Gasoline * 100.0 / Total), 2) AS Gasoline_Percentage,
    ROUND((Diesel * 100.0 / Total), 2) AS Diesel_Percentage,
    ROUND((Biodiesel * 100.0 / Total), 2) AS Biodiesel_Percentage,
    ROUND((Ethanol * 100.0 / Total), 2) AS Ethanol_Percentage
FROM total_count)
SELECT 'EV' AS fuel_type, EV AS vehicle_count, EV_Percentage AS percentage FROM final
UNION ALL
SELECT 'PHEV', PHEV, PHEV_Percentage FROM final
UNION ALL
SELECT 'HEV', HEV, HEV_Percentage FROM final
UNION ALL
SELECT 'Gasoline', Gasoline, Gasoline_Percentage FROM final
UNION ALL
SELECT 'Diesel', Diesel, Diesel_Percentage FROM final
UNION ALL
SELECT 'Biodiesel', Biodiesel, Biodiesel_Percentage FROM final
UNION ALL
SELECT 'Ethanol', Ethanol, Ethanol_Percentage FROM final
UNION ALL
SELECT 'Hydrogen', Hydrogen, Hydrogen_Percentage FROM final;


