USE Railway;
GO

-- Create a test results table to track all tests
IF OBJECT_ID('TestResults', 'U') IS NOT NULL DROP TABLE TestResults;
CREATE TABLE TestResults (
    TestID INT IDENTITY(1,1) PRIMARY KEY,
    TestCategory VARCHAR(100),
    TestName VARCHAR(200),
    ExpectedResult VARCHAR(500),
    ActualResult VARCHAR(500),
    Status VARCHAR(20),
    ExecutionTime DATETIME DEFAULT GETDATE()
);
GO

-- =====================================================
-- RAILWAY DATABASE COMPREHENSIVE TEST SCRIPT
-- Tests: Data Integrity, Referential Integrity, 
--        Business Logic, and Migration Validation
-- =====================================================

-- === 1. SOURCE DATA VALIDATION ===
PRINT '=== 1. SOURCE DATA VALIDATION ===';

-- Test 1.1: Verify source record count
DECLARE @SourceCount INT = (SELECT COUNT(*) FROM railway_data);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Source Validation', 'Total Source Records', '31653', CAST(@SourceCount AS VARCHAR), 
        CASE WHEN @SourceCount = 31653 THEN 'PASS' ELSE 'FAIL' END);

-- Test 1.2: Check for NULL Transaction IDs
DECLARE @NullTransactions INT = (SELECT COUNT(*) FROM railway_data WHERE [Transaction ID] IS NULL);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Source Validation', 'No NULL Transaction IDs', '0', CAST(@NullTransactions AS VARCHAR),
        CASE WHEN @NullTransactions = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 1.3: Verify unique transactions
DECLARE @UniqueTransactions INT = (SELECT COUNT(DISTINCT [Transaction ID]) FROM railway_data);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Source Validation', 'Unique Transaction IDs', '31653', CAST(@UniqueTransactions AS VARCHAR),
        CASE WHEN @UniqueTransactions = 31653 THEN 'PASS' ELSE 'FAIL' END);

-- === 2. DIMENSION TABLE INTEGRITY TESTS ===
PRINT '=== 2. DIMENSION TABLE TESTS ===';

-- Test 2.1: DimTicket record count
DECLARE @TicketCount INT = (SELECT COUNT(*) FROM DimTicket);
DECLARE @ExpectedTickets INT = (SELECT COUNT(DISTINCT CONCAT([Ticket Class], '|', [Ticket Type], '|', ISNULL([Railcard], 'NULL'))) FROM railway_data);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Dimension Integrity', 'DimTicket Record Count', CAST(@ExpectedTickets AS VARCHAR), CAST(@TicketCount AS VARCHAR),
        CASE WHEN @TicketCount = @ExpectedTickets THEN 'PASS' ELSE 'FAIL' END);

-- Test 2.2: DimDate completeness
DECLARE @DateCount INT = (SELECT COUNT(*) FROM DimDate);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Dimension Integrity', 'DimDate Has Records', '>0', CAST(@DateCount AS VARCHAR),
        CASE WHEN @DateCount > 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 2.3: DimPurchase matches source
DECLARE @PurchaseCount INT = (SELECT COUNT(*) FROM DimPurchase);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Dimension Integrity', 'DimPurchase Record Count', '31653', CAST(@PurchaseCount AS VARCHAR),
        CASE WHEN @PurchaseCount = 31653 THEN 'PASS' ELSE 'FAIL' END);

-- Test 2.4: DimJourney has TransactionID
DECLARE @JourneyWithTxn INT = (SELECT COUNT(*) FROM DimJourney WHERE TransactionID IS NOT NULL);
DECLARE @TotalJourneys INT = (SELECT COUNT(*) FROM DimJourney);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Dimension Integrity', 'DimJourney All Have TransactionID', CAST(@TotalJourneys AS VARCHAR), CAST(@JourneyWithTxn AS VARCHAR),
        CASE WHEN @JourneyWithTxn = @TotalJourneys THEN 'PASS' ELSE 'FAIL' END);

-- Test 2.5: Check for duplicate TransactionIDs in DimJourney
DECLARE @DuplicateJourneys INT = (
    SELECT COUNT(*) FROM (
        SELECT TransactionID, COUNT(*) as cnt 
        FROM DimJourney 
        GROUP BY TransactionID 
        HAVING COUNT(*) > 1
    ) dup
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Dimension Integrity', 'No Duplicate TransactionIDs in DimJourney', '0', CAST(@DuplicateJourneys AS VARCHAR),
        CASE WHEN @DuplicateJourneys = 0 THEN 'PASS' ELSE 'FAIL' END);

-- === 3. FACT TABLE INTEGRITY TESTS ===
PRINT '=== 3. FACT TABLE TESTS ===';

-- Test 3.1: Fact table record count (CRITICAL TEST)
DECLARE @FactCount INT = (SELECT COUNT(*) FROM FactJourney);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Fact Integrity', 'FactJourney Record Count', '31653', CAST(@FactCount AS VARCHAR),
        CASE WHEN @FactCount = 31653 THEN 'PASS' ELSE 'FAIL' END);

-- Test 3.2: No orphaned records - JourneyID
DECLARE @OrphanJourneys INT = (SELECT COUNT(*) FROM FactJourney f WHERE NOT EXISTS (SELECT 1 FROM DimJourney d WHERE d.JourneyID = f.JourneyID));
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Referential Integrity', 'No Orphaned JourneyIDs', '0', CAST(@OrphanJourneys AS VARCHAR),
        CASE WHEN @OrphanJourneys = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 3.3: No orphaned records - TicketID
DECLARE @OrphanTickets INT = (SELECT COUNT(*) FROM FactJourney f WHERE NOT EXISTS (SELECT 1 FROM DimTicket d WHERE d.TicketID = f.TicketID));
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Referential Integrity', 'No Orphaned TicketIDs', '0', CAST(@OrphanTickets AS VARCHAR),
        CASE WHEN @OrphanTickets = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 3.4: No orphaned records - TransactionID
DECLARE @OrphanTransactions INT = (SELECT COUNT(*) FROM FactJourney f WHERE NOT EXISTS (SELECT 1 FROM DimPurchase d WHERE d.TransactionID = f.TransactionID));
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Referential Integrity', 'No Orphaned TransactionIDs', '0', CAST(@OrphanTransactions AS VARCHAR),
        CASE WHEN @OrphanTransactions = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 3.5: All dates exist in DimDate
DECLARE @OrphanDates INT = (
    SELECT COUNT(*) FROM FactJourney f 
    WHERE NOT EXISTS (SELECT 1 FROM DimDate d WHERE d.DateID = f.TravelDateID)
       OR NOT EXISTS (SELECT 1 FROM DimDate d WHERE d.DateID = f.ArrivalDateID)
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Referential Integrity', 'All DateIDs Valid', '0', CAST(@OrphanDates AS VARCHAR),
        CASE WHEN @OrphanDates = 0 THEN 'PASS' ELSE 'FAIL' END);

-- === 4. DATA ACCURACY TESTS ===
PRINT '=== 4. DATA ACCURACY TESTS ===';

-- Test 4.1: Price values match
DECLARE @PriceMismatch INT = (
    SELECT COUNT(*) 
    FROM railway_data r
    JOIN FactJourney f ON r.[Transaction ID] = f.TransactionID
    WHERE r.[Price] != f.Price
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Data Accuracy', 'Price Values Match Source', '0', CAST(@PriceMismatch AS VARCHAR),
        CASE WHEN @PriceMismatch = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 4.2: Journey Status matches
DECLARE @StatusMismatch INT = (
    SELECT COUNT(*) 
    FROM railway_data r
    JOIN FactJourney f ON r.[Transaction ID] = f.TransactionID
    WHERE r.[Journey Status] != f.JourneyStatus
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Data Accuracy', 'Journey Status Match Source', '0', CAST(@StatusMismatch AS VARCHAR),
        CASE WHEN @StatusMismatch = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 4.3: Delay Duration matches
DECLARE @DelayMismatch INT = (
    SELECT COUNT(*) 
    FROM railway_data r
    JOIN FactJourney f ON r.[Transaction ID] = f.TransactionID
    WHERE ISNULL(r.[Delay Duration], -999) != ISNULL(f.DelayDuration, -999)
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Data Accuracy', 'Delay Duration Match Source', '0', CAST(@DelayMismatch AS VARCHAR),
        CASE WHEN @DelayMismatch = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 4.4: Journey Duration matches
DECLARE @DurationMismatch INT = (
    SELECT COUNT(*) 
    FROM railway_data r
    JOIN FactJourney f ON r.[Transaction ID] = f.TransactionID
    WHERE ISNULL(r.[Journey Duration], -999) != ISNULL(f.JourneyDuration, -999)
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Data Accuracy', 'Journey Duration Match Source', '0', CAST(@DurationMismatch AS VARCHAR),
        CASE WHEN @DurationMismatch = 0 THEN 'PASS' ELSE 'FAIL' END);

-- === 5. BUSINESS LOGIC TESTS ===
PRINT '=== 5. BUSINESS LOGIC TESTS ===';

-- Test 5.1: Delayed journeys have delay reasons
DECLARE @DelayedNoReason INT = (
    SELECT COUNT(*) 
    FROM FactJourney 
    WHERE JourneyStatus IN ('Delayed', 'Cancelled') 
      AND (ReasonForDelay IS NULL OR ReasonForDelay = '')
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Business Logic', 'Delayed Journeys Have Reasons', '0', CAST(@DelayedNoReason AS VARCHAR),
        CASE WHEN @DelayedNoReason = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 5.2: On-time journeys have no delay duration
DECLARE @OnTimeWithDelay INT = (
    SELECT COUNT(*) 
    FROM FactJourney 
    WHERE JourneyStatus = 'On Time' 
      AND DelayDuration > 0
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Business Logic', 'On-Time Journeys No Delay', '0', CAST(@OnTimeWithDelay AS VARCHAR),
        CASE WHEN @OnTimeWithDelay = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 5.3: Price is always positive
DECLARE @NegativePrice INT = (SELECT COUNT(*) FROM FactJourney WHERE Price <= 0);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Business Logic', 'All Prices Positive', '0', CAST(@NegativePrice AS VARCHAR),
        CASE WHEN @NegativePrice = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 5.4: Journey duration is positive
DECLARE @NegativeDuration INT = (SELECT COUNT(*) FROM FactJourney WHERE JourneyDuration <= 0);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Business Logic', 'Journey Duration Positive', '0', CAST(@NegativeDuration AS VARCHAR),
        CASE WHEN @NegativeDuration = 0 THEN 'PASS' ELSE 'FAIL' END);

-- Test 5.5: Arrival date >= Departure date
DECLARE @InvalidDates INT = (
    SELECT COUNT(*) 
    FROM FactJourney f
    JOIN DimDate dTravel ON f.TravelDateID = dTravel.DateID
    JOIN DimDate dArrival ON f.ArrivalDateID = dArrival.DateID
    WHERE dArrival.FullDate < dTravel.FullDate
);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Business Logic', 'Arrival After Departure', '0', CAST(@InvalidDates AS VARCHAR),
        CASE WHEN @InvalidDates = 0 THEN 'PASS' ELSE 'FAIL' END);

-- === 6. AGGREGATION VALIDATION TESTS ===
PRINT '=== 6. AGGREGATION TESTS ===';

-- Test 6.1: Total revenue matches
DECLARE @SourceRevenue DECIMAL(18,2) = (SELECT SUM([Price]) FROM railway_data);
DECLARE @FactRevenue DECIMAL(18,2) = (SELECT SUM(Price) FROM FactJourney);
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Aggregation', 'Total Revenue Match', CAST(@SourceRevenue AS VARCHAR), CAST(@FactRevenue AS VARCHAR),
        CASE WHEN ABS(@SourceRevenue - @FactRevenue) < 0.01 THEN 'PASS' ELSE 'FAIL' END);

-- Test 6.2: Journey status distribution
DECLARE @SourceOnTime INT = (SELECT COUNT(*) FROM railway_data WHERE [Journey Status] = 'On Time');
DECLARE @FactOnTime INT = (SELECT COUNT(*) FROM FactJourney WHERE JourneyStatus = 'On Time');
INSERT INTO TestResults (TestCategory, TestName, ExpectedResult, ActualResult, Status)
VALUES ('Aggregation', 'On-Time Journey Count', CAST(@SourceOnTime AS VARCHAR), CAST(@FactOnTime AS VARCHAR),
        CASE WHEN @SourceOnTime = @FactOnTime THEN 'PASS' ELSE 'FAIL' END);

-- Query the TestResults table to see the outcome of all tests
SELECT 
    TestID,
    TestCategory,
    TestName,
    ExpectedResult,
    ActualResult,
    Status,
    ExecutionTime
FROM TestResults
ORDER BY ExecutionTime;