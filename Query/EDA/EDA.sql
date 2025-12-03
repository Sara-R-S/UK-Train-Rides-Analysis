USE Railway;
GO

-- ================================================================
-- 1. Most Popular Routes with Journey Status and Revenue Breakdown
-- ================================================================
SELECT 
    dj.[Route],
    COUNT(*) AS JourneyCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS PercentOfTotalJourneys,
    
    -- Journey Status
    SUM(CASE WHEN fj.JourneyStatus = 'On Time' THEN 1 ELSE 0 END) AS OnTimeCount,
	CAST(SUM(CASE WHEN fj.JourneyStatus = 'On Time' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS OnTimePercent,
    SUM(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 ELSE 0 END) AS DelayedCount,
	CAST(SUM(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS DelayedPercent,
    SUM(CASE WHEN fj.JourneyStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledCount,
	CAST(SUM(CASE WHEN fj.JourneyStatus = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS CancelledPercent,
    
    -- Duration and Delay Metrics
    AVG(ISNULL(fj.JourneyDuration, 0)) AS ScheduledDuration,
    AVG(ISNULL(fj.DelayDuration, 0)) AS AvgDelayDuration,
    MIN(ISNULL(fj.DelayDuration, 0)) AS MinDelayDuration,
    MAX(ISNULL(fj.DelayDuration, 0)) AS MaxDelayDuration,
    ISNULL(STDEV(fj.DelayDuration), 0) AS StdDevDelayDuration, -- Standard deviation of delay duration
    
    
    -- Revenue Metrics
    SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
    CAST(SUM(ISNULL(fj.Price, 0)) * 100.0 / SUM(SUM(ISNULL(fj.Price, 0))) OVER() AS DECIMAL(5,2)) AS PercentOfTotalRevenue,
    AVG(ISNULL(fj.Price, 0)) AS AvgPrice,

	-- Refund Requests and Revenue Loss
    SUM(CASE WHEN dp.RefundRequest = 1 THEN 1 ELSE 0 END) AS TotalRefundRequests,
    SUM(CASE WHEN dp.RefundRequest = 1 THEN ISNULL(fj.Price, 0) ELSE 0 END) AS RevenueLoss
FROM FactJourney fj
JOIN DimJourney dj ON fj.JourneyID = dj.JourneyID
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID -- Join with DimPurchase for RefundRequest
GROUP BY dj.Route
ORDER BY JourneyCount DESC;
GO


-- ==========================================
-- 2. Busiest Stations (Departures & Arrivals)
-- ==========================================
SELECT Station, StationType, COUNT(*) AS TotalJourneys
FROM (
    SELECT dj.DepartureStation AS Station, 'Departure' AS StationType
    FROM DimJourney dj
    JOIN FactJourney fj ON fj.JourneyID = dj.JourneyID
    UNION ALL
    SELECT dj.ArrivalDestination, 'Arrival'
    FROM DimJourney dj
    JOIN FactJourney fj ON fj.JourneyID = dj.JourneyID
) AS Stations
GROUP BY Station, StationType
ORDER BY TotalJourneys DESC;
GO

-- =====================================
-- 3. Journey Duration Analysis by Route
-- =====================================
SELECT dj.Route,
       AVG(ISNULL(fj.JourneyDuration, 0)) AS AvgScheduledDuration,
       MIN(ISNULL(fj.JourneyDuration, 0)) AS MinDuration,
       MAX(ISNULL(fj.JourneyDuration, 0)) AS MaxDuration,
       STDEV(ISNULL(fj.JourneyDuration, 0)) AS StdDevDuration
FROM FactJourney fj
JOIN DimJourney dj ON fj.JourneyID = dj.JourneyID
GROUP BY dj.Route
ORDER BY AvgScheduledDuration DESC;
GO

-- =====================================
-- 4. Peak Travel Times
-- =====================================
SELECT DATEPART(HOUR, CAST(dj.DepartureTime AS TIME)) AS DepartureHour,
       dd.DayName,
       COUNT(*) AS JourneyCount
FROM FactJourney fj
JOIN DimJourney dj ON fj.JourneyID = dj.JourneyID
JOIN DimDate dd ON fj.TravelDateID = dd.DateID
GROUP BY DATEPART(HOUR, CAST(dj.DepartureTime AS TIME)), dd.DayName
ORDER BY JourneyCount DESC;
GO

-- =====================================
-- 5. Overall Journey Status Distribution
-- =====================================
SELECT JourneyStatus,
       COUNT(*) AS Count,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM FactJourney
GROUP BY JourneyStatus
ORDER BY Count DESC;
GO

-- =====================================
-- 6. Delay Analysis by Route
-- =====================================
SELECT dj.Route,
       COUNT(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 END) AS DelayedCount,
       COUNT(*) AS TotalJourneys,
       CAST(COUNT(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS DelayPercentage,
       AVG(ISNULL(fj.DelayDuration, 0)) AS AvgDelayMinutes,
       MAX(ISNULL(fj.DelayDuration, 0)) AS MaxDelayMinutes
FROM FactJourney fj
JOIN DimJourney dj ON fj.JourneyID = dj.JourneyID
GROUP BY dj.Route
HAVING COUNT(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 END) > 0
ORDER BY DelayPercentage DESC;
GO

-- =====================================
-- 7. Reasons for Delays
-- =====================================
SELECT ReasonForDelay,
       COUNT(*) AS DelayCount,
       AVG(ISNULL(DelayDuration, 0)) AS AvgDelayMinutes,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM FactJourney
WHERE ReasonForDelay IS NOT NULL
GROUP BY ReasonForDelay
ORDER BY DelayCount DESC;
GO

-- =====================================
-- 8. Performance by Day of Week
-- =====================================
SELECT dd.DayName,
       COUNT(*) AS TotalJourneys,
       COUNT(CASE WHEN fj.JourneyStatus = 'On Time' THEN 1 END) AS OnTimeCount,
       COUNT(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 END) AS DelayedCount,
       COUNT(CASE WHEN fj.JourneyStatus = 'Cancelled' THEN 1 END) AS CancelledCount,
       CAST(COUNT(CASE WHEN fj.JourneyStatus = 'On Time' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS OnTimePercentage
FROM FactJourney fj
JOIN DimDate dd ON fj.TravelDateID = dd.DateID
GROUP BY dd.DayName, dd.DayOfWeek
ORDER BY dd.DayOfWeek;
GO

-- =====================================
-- 9. Monthly Performance Trends
-- =====================================
SELECT dd.Year,
       dd.MonthName,
       COUNT(*) AS TotalJourneys,
       AVG(ISNULL(fj.DelayDuration, 0)) AS AvgDelayMinutes,
       CAST(COUNT(CASE WHEN fj.JourneyStatus = 'Delayed' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS DelayRate
FROM FactJourney fj
JOIN DimDate dd ON fj.TravelDateID = dd.DateID
GROUP BY dd.Year, dd.Month, dd.MonthName
ORDER BY dd.Year, dd.Month;
GO

-- =====================================
-- 10. Purchase Type Distribution
-- =====================================
SELECT dp.PurchaseType,
       COUNT(*) AS PurchaseCount,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice
FROM FactJourney fj
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID
GROUP BY dp.PurchaseType;
GO

-- =====================================
-- 11. Payment Method Preferences
-- =====================================
SELECT dp.PaymentMethod,
       COUNT(*) AS TransactionCount,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       AVG(ISNULL(fj.Price, 0)) AS AvgTransactionValue,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM FactJourney fj
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID
GROUP BY dp.PaymentMethod
ORDER BY TransactionCount DESC;
GO

-- =====================================
-- 12. Advance Purchase Behavior
-- =====================================
SELECT DATEDIFF(DAY, dd_purchase.FullDate, dd_travel.FullDate) AS DaysInAdvance,
       COUNT(*) AS PurchaseCount,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice
FROM FactJourney fj
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID
JOIN DimDate dd_purchase ON dp.PurchaseDateID = dd_purchase.DateID
JOIN DimDate dd_travel ON fj.TravelDateID = dd_travel.DateID
WHERE DATEDIFF(DAY, dd_purchase.FullDate, dd_travel.FullDate) >= 0
GROUP BY DATEDIFF(DAY, dd_purchase.FullDate, dd_travel.FullDate)
ORDER BY DaysInAdvance;
GO

-- =====================================
-- 13. Ticket Type Preferences
-- =====================================
SELECT dt.TicketType, dt.TicketClass,
       COUNT(*) AS TicketCount,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM FactJourney fj
JOIN DimTicket dt ON fj.TicketID = dt.TicketID
GROUP BY dt.TicketType, dt.TicketClass
ORDER BY TicketCount DESC;
GO

-- =====================================
-- 14. Railcard Usage Analysis
-- =====================================
SELECT CASE WHEN dt.RailCard IS NULL OR dt.RailCard = '' THEN 'No Railcard' ELSE dt.RailCard END AS RailcardType,
       COUNT(*) AS JourneyCount,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM FactJourney fj
JOIN DimTicket dt ON fj.TicketID = dt.TicketID
GROUP BY CASE WHEN dt.RailCard IS NULL OR dt.RailCard = '' THEN 'No Railcard' ELSE dt.RailCard END
ORDER BY JourneyCount DESC;
GO

-- =====================================
-- 15. Refund Request Analysis
-- =====================================
SELECT fj.JourneyStatus,
       COUNT(CASE WHEN dp.RefundRequest = 1 THEN 1 END) AS RefundRequests,
       COUNT(*) AS TotalJourneys,
       CAST(COUNT(CASE WHEN dp.RefundRequest = 1 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS RefundRate
FROM FactJourney fj
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID
GROUP BY fj.JourneyStatus
ORDER BY RefundRate DESC;
GO

-- =====================================
-- 16. Total Revenue Overview
-- =====================================
SELECT COUNT(*) AS TotalTransactions,
       SUM(ISNULL(Price, 0)) AS TotalRevenue,
       AVG(ISNULL(Price, 0)) AS AvgTicketPrice,
       MIN(ISNULL(Price, 0)) AS MinPrice,
       MAX(ISNULL(Price, 0)) AS MaxPrice
FROM FactJourney;
GO

-- =====================================
-- 17. Revenue by Route
-- =====================================
SELECT dj.Route,
       COUNT(*) AS TicketsSold,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice,
       CAST(SUM(ISNULL(fj.Price, 0)) * 100.0 / SUM(SUM(ISNULL(fj.Price, 0))) OVER() AS DECIMAL(5,2)) AS RevenuePercentage
FROM FactJourney fj
JOIN DimJourney dj ON fj.JourneyID = dj.JourneyID
GROUP BY dj.Route
ORDER BY TotalRevenue DESC;
GO

-- =====================================
-- 18. Revenue by Ticket Type and Class
-- =====================================
SELECT dt.TicketType, dt.TicketClass,
       COUNT(*) AS TicketsSold,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice
FROM FactJourney fj
JOIN DimTicket dt ON fj.TicketID = dt.TicketID
GROUP BY dt.TicketType, dt.TicketClass
ORDER BY TotalRevenue DESC;
GO

-- =====================================
-- 19. Monthly Revenue Trends
-- =====================================
SELECT dd.Year, dd.MonthName,
       COUNT(*) AS TicketsSold,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice
FROM FactJourney fj
JOIN DimDate dd ON fj.TravelDateID = dd.DateID
GROUP BY dd.Year, dd.Month, dd.MonthName
ORDER BY dd.Year, dd.Month;
GO

-- =====================================
-- 20. Weekend vs Weekday Revenue
-- =====================================
SELECT CASE WHEN dd.IsWeekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS DayType,
       COUNT(*) AS TicketsSold,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice
FROM FactJourney fj
JOIN DimDate dd ON fj.TravelDateID = dd.DateID
GROUP BY CASE WHEN dd.IsWeekend = 1 THEN 'Weekend' ELSE 'Weekday' END;
GO

-- =====================================
-- 21. Revenue Impact of Delays/Cancellations
-- =====================================
SELECT fj.JourneyStatus,
       COUNT(*) AS JourneyCount,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       SUM(CASE WHEN dp.RefundRequest = 1 THEN ISNULL(fj.Price, 0) ELSE 0 END) AS PotentialRefunds,
       CAST(SUM(CASE WHEN dp.RefundRequest = 1 THEN ISNULL(fj.Price, 0) ELSE 0 END) * 100.0 / SUM(ISNULL(fj.Price, 0)) AS DECIMAL(5,2)) AS RefundPercentage
FROM FactJourney fj
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID
GROUP BY fj.JourneyStatus
ORDER BY TotalRevenue DESC;
GO

-- =====================================
-- 22. Revenue by Purchase Channel
-- =====================================
SELECT dp.PurchaseType, dt.TicketType,
       COUNT(*) AS TicketsSold,
       SUM(ISNULL(fj.Price, 0)) AS TotalRevenue,
       AVG(ISNULL(fj.Price, 0)) AS AvgPrice
FROM FactJourney fj
JOIN DimPurchase dp ON fj.TransactionID = dp.TransactionID
JOIN DimTicket dt ON fj.TicketID = dt.TicketID
GROUP BY dp.PurchaseType, dt.TicketType
ORDER BY TotalRevenue DESC;
GO