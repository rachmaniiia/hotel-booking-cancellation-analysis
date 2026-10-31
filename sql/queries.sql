-- ============================================================
-- Hotel Booking Cancellation Analysis | SQL queries
-- Table: df (cleaned hotel booking data, 119,390 rows)
-- Run in Python with pandasql: ps.sqldf(query, locals())
-- ============================================================

-- 01. Cancellation rate for each hotel type, by arrival year
SELECT
    hotel,
    arrival_date_year,
    ROUND(SUM(CASE WHEN is_canceled = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS cancellation_rate
FROM df
GROUP BY hotel, arrival_date_year
ORDER BY arrival_date_year, hotel;


-- 02. Average lead time for bookings with above-average lead time,
--     grouped by number of special requests (CTE for the overall average)
WITH avg_lead_time AS (
    SELECT AVG(lead_time) AS overall_avg_lead_time
    FROM df
)
SELECT
    total_of_special_requests,
    ROUND(AVG(lead_time), 2) AS average_lead_time
FROM df
WHERE lead_time > (SELECT overall_avg_lead_time FROM avg_lead_time)
GROUP BY total_of_special_requests
ORDER BY total_of_special_requests;


-- 03. Date with the highest revenue proxy (sum of ADR)
--     Only completed stays (check-out) with more than 2 special requests
SELECT
    reservation_status_date,
    ROUND(SUM(adr), 2) AS total_revenue
FROM df
WHERE reservation_status = 'check-out'
  AND total_of_special_requests > 2
GROUP BY reservation_status_date
ORDER BY total_revenue DESC
LIMIT 1;


-- 04. Average ADR by lead-time range (CTE with CASE WHEN buckets)
WITH lead_time_groups AS (
    SELECT
        CASE
            WHEN lead_time BETWEEN 0 AND 30  THEN '0-30 days'
            WHEN lead_time BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN lead_time BETWEEN 61 AND 90 THEN '61-90 days'
            WHEN lead_time BETWEEN 91 AND 120 THEN '91-120 days'
            WHEN lead_time > 120 THEN '120+ days'
            ELSE 'Unknown'
        END AS lead_time_range,
        adr
    FROM df
)
SELECT
    lead_time_range,
    ROUND(AVG(adr), 2) AS average_adr
FROM lead_time_groups
GROUP BY lead_time_range
ORDER BY lead_time_range;
