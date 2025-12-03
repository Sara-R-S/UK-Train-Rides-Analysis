IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Railway')
BEGIN
    ALTER DATABASE Railway SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Railway;
END
GO

CREATE DATABASE Railway;
GO

USE Railway;
GO

CREATE TABLE railway_data (
    [Transaction ID] VARCHAR(50),
    [Purchase Date] DATE,
    [Purchase Time] VARCHAR(50),
    [Purchase Type] VARCHAR(50),
    [Payment Method] VARCHAR(50),
    [Railcard] VARCHAR(50),
    [Ticket Class] VARCHAR(50),
    [Ticket Type] VARCHAR(50),
    [Price] INT,
    [Departure Station] VARCHAR(100),
    [Arrival Destination] VARCHAR(100),
    [Departure Date] DATE,
    [Departure Time] VARCHAR(50),
    [Arrival Time] VARCHAR(50),
    [Actual Arrival Time] VARCHAR(50),
    [Journey Status] VARCHAR(50),
    [Reason for Delay] VARCHAR(100),
    [Refund Request] VARCHAR(50),
    [Route] VARCHAR(200),
    [Purchase Weekday] VARCHAR(50),
    [Purchase Timestamp] DATETIME,
    [Departure Weekday] VARCHAR(50),
    [Departure Timestamp] DATETIME,
    [Arrival Timestamp] DATETIME,
    [Actual Arrival Timestamp] DATETIME,
    [Journey Duration] FLOAT,
    [Actual Journey Duration] FLOAT,
    [Delay Duration] FLOAT
);
GO

INSERT INTO railway_data
SELECT 
    [Transaction_ID],
    TRY_CONVERT(DATE, [Purchase_Date]),
    [Purchase_Time],
    [Purchase_Type],
    [Payment_Method],
    NULLIF([Railcard], ''),
    [Ticket_Class],
    [Ticket_Type],
    TRY_CONVERT(INT, [Price]),
    [Departure_Station],
    [Arrival_Destination],
    TRY_CONVERT(DATE, [Departure_Date]),
    [Departure_Time],
    [Arrival_Time],
    NULLIF([Actual_Arrival_Time], ''),
    [Journey_Status],
    NULLIF([Reason_for_Delay], ''),
    [Refund_Request],
    [Route],
    [Purchase_Weekday],
    TRY_CONVERT(DATETIME, [Purchase_Timestamp]),
    [Departure_Weekday],
    TRY_CONVERT(DATETIME, [Departure_Timestamp]),
    TRY_CONVERT(DATETIME, [Arrival_Timestamp]),
    NULLIF(TRY_CONVERT(DATETIME, [Actual_Arrival_Timestamp]), ''),
    TRY_CONVERT(FLOAT, [Journey_Duration]),
    NULLIF(TRY_CONVERT(FLOAT, [Actual_Journey_Duration]), ''),
    NULLIF(TRY_CONVERT(FLOAT, [Delay_Duration]), '')
FROM dbo.preprocessed_railway;
GO



-- DIM TICKET
create table DimTicket(
TicketID int identity (1,1)primary key,
TicketClass varchar(50),
TicketType varchar(50),
RailCard varchar(50)
)

insert into DimTicket(TicketClass,TicketType,RailCard)
select distinct [Ticket Class],[Ticket Type],[Railcard]
from dbo.railway_data


-- DIM DATE

CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,       
    FullDate DATE NOT NULL,       
    Day INT,
    Month INT,
    MonthName VARCHAR(20),
    Quarter INT,
    Year INT,
    DayOfWeek INT,
    DayName VARCHAR(20),
    WeekOfYear INT,
    IsWeekend BIT
) 
;WITH AllDates AS (
    SELECT DISTINCT CAST([Purchase Timestamp] AS DATE) AS TheDate
    FROM dbo.railway_data
    WHERE [Purchase Timestamp] IS NOT NULL
    UNION
    SELECT DISTINCT CAST([Departure Timestamp] AS DATE)
    FROM  dbo.railway_data
    WHERE [Departure Timestamp] IS NOT NULL
    UNION
    SELECT DISTINCT CAST([Arrival Timestamp] AS DATE)
    FROM  dbo.railway_data
    WHERE [Arrival Timestamp] IS NOT NULL
    UNION
    SELECT DISTINCT CAST([Actual Arrival Timestamp] AS DATE)
    FROM  dbo.railway_data
    WHERE [Actual Arrival Timestamp] IS NOT NULL
)
INSERT INTO DimDate (
    DateID, FullDate, Day, Month, MonthName, Quarter, 
    Year, DayOfWeek, DayName, WeekOfYear, IsWeekend
)
SELECT 
    CONVERT(INT, FORMAT(TheDate, 'yyyyMMdd')) AS DateID,
    TheDate,
    DAY(TheDate),
    MONTH(TheDate),
    DATENAME(month, TheDate),
    DATEPART(quarter, TheDate),
    YEAR(TheDate),
    DATEPART(weekday, TheDate),
    DATENAME(weekday, TheDate),
    DATEPART(week, TheDate),
    CASE WHEN DATENAME(weekday, TheDate) IN ('Friday', 'Saturday') THEN 1 ELSE 0 END
FROM AllDates;

-- DIM Purchase

CREATE TABLE DimPurchase (
    TransactionID VARCHAR(50) PRIMARY KEY,       
    PurchaseDateID INT NOT NULL,         
    PurchaseTime TIME,                     
    PurchaseType VARCHAR(50),              
    PaymentMethod VARCHAR(50),             
    RefundRequest BIT,                     
    FOREIGN KEY (PurchaseDateID) REFERENCES DimDate(DateID)
);

INSERT INTO DimPurchase (
    TransactionID,
    PurchaseDateID,
    PurchaseTime,
    PurchaseType,
    PaymentMethod,
    RefundRequest
)
SELECT 
    [Transaction ID],
    CONVERT(INT, FORMAT([Purchase Timestamp],'yyyyMMdd')) AS PurchaseDateID,
    CAST([Purchase Timestamp] AS TIME) AS PurchaseTime,
    [Purchase Type],
    [Payment Method],
    CASE WHEN [Refund Request] = 'Yes' THEN 1 ELSE 0 END AS RefundRequest
FROM  dbo.railway_data
WHERE [Purchase Timestamp] IS NOT NULL;


CREATE TABLE DimJourney(
    JourneyID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionID VARCHAR(50) UNIQUE NOT NULL,  -- Add this
    DepartureStation VARCHAR(100),
    ArrivalDestination VARCHAR(100),
    DepartureTime VARCHAR(50),
    ArrivalTime VARCHAR(50),
    ActualArrivalTime VARCHAR(50),
    Route VARCHAR(100),
    DepartureDateID INT NOT NULL,
    FOREIGN KEY (DepartureDateID) REFERENCES DimDate(DateID)
);

INSERT INTO DimJourney(
    TransactionID,
    DepartureStation,
    ArrivalDestination,
    DepartureTime,
    ArrivalTime,
    ActualArrivalTime,
    Route,
    DepartureDateID
)
SELECT
    [Transaction ID],
    [Departure Station],
    [Arrival Destination],
    CONVERT(VARCHAR(8), CAST([Departure Timestamp] AS TIME), 108),
    CONVERT(VARCHAR(8), CAST([Arrival Timestamp] AS TIME), 108),
    CONVERT(VARCHAR(8), CAST([Actual Arrival Timestamp] AS TIME), 108),
    [Route],
    CONVERT(INT, FORMAT([Departure Timestamp],'yyyyMMdd'))
FROM dbo.railway_data
WHERE [Departure Timestamp] IS NOT NULL;

CREATE TABLE FactJourney (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    JourneyID INT NOT NULL,
    TicketID INT NOT NULL,
    TransactionID VARCHAR(50) NOT NULL,
    TravelDateID INT NOT NULL,
    ArrivalDateID INT NOT NULL,
    ActualArrivalDateID INT NULL,
    DelayDuration FLOAT NULL,
    Price DECIMAL(10,2) NOT NULL,
    ReasonForDelay VARCHAR(255) NULL,
    JourneyStatus VARCHAR(50) NULL,
    JourneyDuration FLOAT NULL,
    
    CONSTRAINT FK_FactJourney_Journey FOREIGN KEY (JourneyID) REFERENCES DimJourney(JourneyID),
    CONSTRAINT FK_FactJourney_Ticket FOREIGN KEY (TicketID) REFERENCES DimTicket(TicketID),
    CONSTRAINT FK_FactJourney_Transaction FOREIGN KEY (TransactionID) REFERENCES DimPurchase(TransactionID),
    CONSTRAINT FK_FactJourney_TravelDate FOREIGN KEY (TravelDateID) REFERENCES DimDate(DateID),
    CONSTRAINT FK_FactJourney_ArrivalDate FOREIGN KEY (ArrivalDateID) REFERENCES DimDate(DateID),
    CONSTRAINT FK_FactJourney_ActualArrivalDate FOREIGN KEY (ActualArrivalDateID) REFERENCES DimDate(DateID)
);

INSERT INTO FactJourney (
    JourneyID, TicketID, TransactionID, TravelDateID, ArrivalDateID, 
    ActualArrivalDateID, DelayDuration, Price, ReasonForDelay, 
    JourneyStatus, JourneyDuration
)
SELECT
    j.JourneyID,
    t.TicketID,
    r.[Transaction ID],
    dTravel.DateID,
    dArrival.DateID,
    dActualArrival.DateID,
    r.[Delay Duration],
    r.[Price],
    r.[Reason for Delay],
    r.[Journey Status],
    r.[Journey Duration]
FROM dbo.railway_data r
JOIN DimJourney j ON r.[Transaction ID] = j.TransactionID
JOIN DimTicket t
    ON ISNULL(r.[Ticket Class], '') = ISNULL(t.TicketClass, '')
    AND ISNULL(r.[Ticket Type], '') = ISNULL(t.TicketType, '')
    AND ISNULL(r.[Railcard], '') = ISNULL(t.RailCard, '')
JOIN DimPurchase p ON r.[Transaction ID] = p.TransactionID
JOIN DimDate dTravel ON CONVERT(INT, FORMAT(r.[Departure Timestamp],'yyyyMMdd')) = dTravel.DateID
JOIN DimDate dArrival ON CONVERT(INT, FORMAT(r.[Arrival Timestamp],'yyyyMMdd')) = dArrival.DateID

LEFT JOIN DimDate dActualArrival ON CONVERT(INT, FORMAT(r.[Actual Arrival Timestamp],'yyyyMMdd')) = dActualArrival.DateID;
