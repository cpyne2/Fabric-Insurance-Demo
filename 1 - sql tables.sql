-- ============================================================
--  Insurance Claims Demo Dataset
--  For use with Microsoft Fabric / Power BI
--  ~10% of claims are intentionally OUTSIDE the policy window
--  to demonstrate denial scenarios.
-- ============================================================
 
-- ============================================================
--  TABLE: Customers
-- ============================================================
DROP TABLE IF EXISTS dbo.Claims;
DROP TABLE IF EXISTS dbo.Policies;
DROP TABLE IF EXISTS dbo.Customers;
GO

CREATE TABLE dbo.Customers (
    CustomerID      INT PRIMARY KEY,
    FirstName       NVARCHAR(50),
    LastName        NVARCHAR(50),
    DateOfBirth     DATE,
    Gender          NVARCHAR(10),
    Email           NVARCHAR(100),
    Phone           NVARCHAR(20),
    State           NVARCHAR(2)
);
 
INSERT INTO dbo.Customers (CustomerID, FirstName, LastName, DateOfBirth, Gender, Email, Phone, State) VALUES
(1,  'James',    'Harrington', '1978-03-14', 'Male',   'james.harrington@email.com',  '617-555-0101', 'MA'),
(2,  'Sofia',    'Delgado',    '1985-07-22', 'Female', 'sofia.delgado@email.com',     '617-555-0102', 'TX'),
(3,  'Marcus',   'Webb',       '1990-11-05', 'Male',   'marcus.webb@email.com',       '617-555-0103', 'FL'),
(4,  'Priya',    'Nair',       '1972-04-30', 'Female', 'priya.nair@email.com',        '617-555-0104', 'CA'),
(5,  'Derek',    'Okafor',     '1968-09-18', 'Male',   'derek.okafor@email.com',      '617-555-0105', 'NY'),
(6,  'Lauren',   'Fitzgerald', '1995-02-11', 'Female', 'lauren.fitz@email.com',       '617-555-0106', 'OH'),
(7,  'Carlos',   'Mendez',     '1983-06-27', 'Male',   'carlos.mendez@email.com',     '617-555-0107', 'AZ'),
(8,  'Aisha',    'Thompson',   '1991-12-03', 'Female', 'aisha.thompson@email.com',    '617-555-0108', 'GA'),
(9,  'Nathan',   'Caldwell',   '1976-08-15', 'Male',   'nathan.caldwell@email.com',   '617-555-0109', 'WA'),
(10, 'Rachel',   'Kim',        '1988-01-09', 'Female', 'rachel.kim@email.com',        '617-555-0110', 'IL'),
(11, 'Brandon',  'Patel',      '1980-05-20', 'Male',   'brandon.patel@email.com',     '617-555-0111', 'NJ'),
(12, 'Mei',      'Chen',       '1993-10-16', 'Female', 'mei.chen@email.com',          '617-555-0112', 'WA'),
(13, 'Anthony',  'Russo',      '1965-03-08', 'Male',   'anthony.russo@email.com',     '617-555-0113', 'NY'),
(14, 'Danielle', 'Brooks',     '1997-07-04', 'Female', 'danielle.brooks@email.com',   '617-555-0114', 'TX'),
(15, 'Kevin',    'Nguyen',     '1975-11-29', 'Male',   'kevin.nguyen@email.com',      '617-555-0115', 'CA');
 
 
-- ============================================================
--  TABLE: Policies
-- ============================================================
CREATE TABLE dbo.Policies (
    PolicyID        INT PRIMARY KEY,
    CustomerID      INT REFERENCES dbo.Customers(CustomerID),
    PolicyType      NVARCHAR(50),    -- Auto, Home, Health, Life
    PolicyStatus    NVARCHAR(20),    -- Active, Expired, Cancelled
    PolicyBeginDate DATE,
    PolicyEndDate   DATE,
    PremiumAmount   DECIMAL(10,2),
    CoverageLimit   DECIMAL(12,2)
);
 
INSERT INTO dbo.Policies (PolicyID, CustomerID, PolicyType, PolicyStatus, PolicyBeginDate, PolicyEndDate, PremiumAmount, CoverageLimit) VALUES
-- Active policies (begin 2023-2024, end 2025-2026)
(101, 1,  'Auto',   'Active',    '2023-01-01', '2025-12-31', 1200.00,  50000.00),
(102, 2,  'Home',   'Active',    '2023-06-01', '2025-05-31', 1800.00, 300000.00),
(103, 3,  'Health', 'Active',    '2024-01-01', '2025-12-31',  950.00, 100000.00),
(104, 4,  'Auto',   'Active',    '2023-03-15', '2025-03-14', 1100.00,  50000.00),
(105, 5,  'Life',   'Active',    '2022-07-01', '2027-06-30', 2400.00, 500000.00),
(106, 6,  'Home',   'Active',    '2024-04-01', '2026-03-31', 1650.00, 250000.00),
(107, 7,  'Health', 'Active',    '2023-09-01', '2025-08-31',  875.00, 100000.00),
(108, 8,  'Auto',   'Active',    '2024-01-01', '2025-12-31', 1050.00,  50000.00),
(109, 9,  'Home',   'Active',    '2023-11-01', '2025-10-31', 1900.00, 350000.00),
(110, 10, 'Health', 'Active',    '2024-02-01', '2026-01-31',  920.00, 100000.00),
-- Expired policies (used for "denied" claim scenarios)
(111, 11, 'Auto',   'Expired',   '2021-01-01', '2022-12-31', 1300.00,  50000.00),
(112, 12, 'Home',   'Expired',   '2020-06-01', '2022-05-31', 1750.00, 275000.00),
(113, 13, 'Health', 'Expired',   '2021-03-01', '2023-02-28',  980.00, 100000.00),
(114, 14, 'Auto',   'Active',    '2023-08-01', '2025-07-31', 1150.00,  50000.00),
(115, 15, 'Life',   'Active',    '2022-01-01', '2032-12-31', 3000.00, 750000.00);
 
 
-- ============================================================
--  TABLE: Claims
--  ~10% of records have ClaimDate outside the policy window
--  These are flagged in the ClaimStatus as 'Denied'
--  and noted in DenialReason.
-- ============================================================
CREATE TABLE dbo.Claims (
    ClaimID         INT PRIMARY KEY,
    PolicyID        INT REFERENCES dbo.Policies(PolicyID),
    CustomerID      INT REFERENCES dbo.Customers(CustomerID),
    ClaimDate       DATE,
    ClaimType       NVARCHAR(50),    -- Accident, Theft, Medical, Property Damage, etc.
    ClaimAmount     DECIMAL(10,2),
    ApprovedAmount  DECIMAL(10,2),
    ClaimStatus     NVARCHAR(20),    -- Submitted, Approved, Denied, In Review
    DenialReason    NVARCHAR(200),   -- NULL unless Denied
    AdjusterName    NVARCHAR(100)
);
 
INSERT INTO dbo.Claims (ClaimID, PolicyID, CustomerID, ClaimDate, ClaimType, ClaimAmount, ApprovedAmount, ClaimStatus, DenialReason, AdjusterName) VALUES
 
-- ✅ VALID CLAIMS (ClaimDate within policy window)
(1001, 101, 1,  '2024-02-10', 'Accident',           8500.00,  8000.00, 'Approved',   NULL, 'Sandra Liu'),
(1002, 101, 1,  '2024-07-15', 'Theft',               3200.00,  3200.00, 'Approved',   NULL, 'Tom Reyes'),
(1003, 102, 2,  '2024-03-22', 'Property Damage',    15000.00, 14500.00, 'Approved',   NULL, 'Sandra Liu'),
(1004, 103, 3,  '2024-05-18', 'Medical',             2100.00,  2100.00, 'Approved',   NULL, 'Maria Osei'),
(1005, 104, 4,  '2024-01-09', 'Accident',            5700.00,  5500.00, 'Approved',   NULL, 'Tom Reyes'),
(1006, 105, 5,  '2024-06-30', 'Life Benefit',       10000.00, 10000.00, 'Approved',   NULL, 'James Park'),
(1007, 106, 6,  '2024-09-11', 'Property Damage',    22000.00, 20000.00, 'In Review',  NULL, 'Sandra Liu'),
(1008, 107, 7,  '2024-04-03', 'Medical',             4800.00,  4800.00, 'Approved',   NULL, 'Maria Osei'),
(1009, 108, 8,  '2024-08-27', 'Accident',            9100.00,  8800.00, 'Approved',   NULL, 'Tom Reyes'),
(1010, 109, 9,  '2024-02-14', 'Property Damage',    31000.00, 30000.00, 'Approved',   NULL, 'James Park'),
(1011, 110, 10, '2024-10-05', 'Medical',             1750.00,  1750.00, 'Approved',   NULL, 'Maria Osei'),
(1012, 114, 14, '2024-11-20', 'Accident',            6200.00,  6000.00, 'Approved',   NULL, 'Tom Reyes'),
(1013, 115, 15, '2024-03-15', 'Life Benefit',       25000.00, 25000.00, 'In Review',  NULL, 'James Park'),
(1014, 102, 2,  '2024-12-01', 'Theft',               1800.00,  1800.00, 'Submitted',  NULL, 'Sandra Liu'),
(1015, 103, 3,  '2025-01-08', 'Medical',             3300.00,  3300.00, 'Approved',   NULL, 'Maria Osei'),
(1016, 104, 4,  '2024-09-19', 'Accident',            7400.00,  7000.00, 'Approved',   NULL, 'Tom Reyes'),
(1017, 107, 7,  '2025-02-12', 'Medical',             5100.00,  5100.00, 'Submitted',  NULL, 'Maria Osei'),
(1018, 108, 8,  '2025-01-22', 'Theft',               2600.00,  2400.00, 'Approved',   NULL, 'Tom Reyes'),
(1019, 109, 9,  '2024-07-04', 'Property Damage',    18500.00, 17000.00, 'Approved',   NULL, 'James Park'),
(1020, 110, 10, '2024-11-30', 'Medical',             2950.00,  2950.00, 'Approved',   NULL, 'Maria Osei'),
(1021, 101, 1,  '2023-11-15', 'Property Damage',     4100.00,  4100.00, 'Approved',   NULL, 'Sandra Liu'),
(1022, 106, 6,  '2025-01-30', 'Property Damage',    11200.00, 10800.00, 'In Review',  NULL, 'Sandra Liu'),
(1023, 114, 14, '2024-06-07', 'Accident',            3800.00,  3800.00, 'Approved',   NULL, 'Tom Reyes'),
(1024, 115, 15, '2023-05-22', 'Life Benefit',       50000.00, 50000.00, 'Approved',   NULL, 'James Park'),
(1025, 105, 5,  '2023-08-09', 'Life Benefit',       15000.00, 15000.00, 'Approved',   NULL, 'James Park'),
(1026, 102, 2,  '2023-10-17', 'Property Damage',     9800.00,  9500.00, 'Approved',   NULL, 'Sandra Liu'),
(1027, 103, 3,  '2024-08-21', 'Medical',             1200.00,  1200.00, 'Approved',   NULL, 'Maria Osei'),
(1028, 104, 4,  '2024-11-11', 'Accident',            6600.00,  6200.00, 'Approved',   NULL, 'Tom Reyes'),
(1029, 109, 9,  '2025-02-03', 'Theft',               5500.00,  5500.00, 'Submitted',  NULL, 'James Park'),
(1030, 110, 10, '2025-01-15', 'Medical',             4400.00,  4400.00, 'Approved',   NULL, 'Maria Osei'),
 
-- ❌ DENIED CLAIMS (~10%): ClaimDate is OUTSIDE the policy effective window
-- Policy 111 (CustomerID=11): Expired 2022-12-31 — claim filed in 2023
(1031, 111, 11, '2023-03-14', 'Accident',            7200.00,     0.00, 'Denied', 'Claim date 2023-03-14 is outside policy effective period (2021-01-01 to 2022-12-31).', 'Sandra Liu'),
-- Policy 112 (CustomerID=12): Expired 2022-05-31 — claim filed in 2022 after expiry
(1032, 112, 12, '2022-08-05', 'Property Damage',    12000.00,     0.00, 'Denied', 'Claim date 2022-08-05 is outside policy effective period (2020-06-01 to 2022-05-31).', 'Tom Reyes'),
-- Policy 113 (CustomerID=13): Expired 2023-02-28 — claim filed in 2023 after expiry
(1033, 113, 13, '2023-06-20', 'Medical',             3500.00,     0.00, 'Denied', 'Claim date 2023-06-20 is outside policy effective period (2021-03-01 to 2023-02-28).', 'Maria Osei'),
-- Policy 101 (CustomerID=1): Begins 2023-01-01 — claim filed before start
(1034, 101, 1,  '2022-11-30', 'Theft',               2200.00,     0.00, 'Denied', 'Claim date 2022-11-30 is prior to policy effective date (2023-01-01).', 'Sandra Liu');
GO 
 
-- ============================================================
--  HELPER VIEW: vw_ClaimSummary
--  Ready-to-use for Power BI — joins all three tables
--  and adds a computed IsOutsidePolicyWindow flag.
-- ============================================================
CREATE OR ALTER VIEW dbo.vw_ClaimSummary AS
SELECT
    c.ClaimID,
    c.ClaimDate,
    c.ClaimType,
    c.ClaimAmount,
    c.ApprovedAmount,
    c.ClaimStatus,
    c.DenialReason,
    c.AdjusterName,
 
    p.PolicyID,
    p.PolicyType,
    p.PolicyStatus,
    p.PolicyBeginDate,
    p.PolicyEndDate,
    p.PremiumAmount,
    p.CoverageLimit,
 
    cu.CustomerID,
    cu.FirstName + ' ' + cu.LastName   AS CustomerName,
    cu.DateOfBirth,
    cu.Gender,
    cu.State,
    cu.Email,
 
    -- Computed flags useful for Power BI measures/visuals
    CASE
        WHEN c.ClaimDate < p.PolicyBeginDate OR c.ClaimDate > p.PolicyEndDate
        THEN 'Outside Policy Window'
        ELSE 'Within Policy Window'
    END AS PolicyWindowStatus,
 
    DATEDIFF(DAY, p.PolicyBeginDate, p.PolicyEndDate) AS PolicyDurationDays,
    DATEDIFF(DAY, p.PolicyBeginDate, c.ClaimDate)     AS DaysFromPolicyStart
 
FROM dbo.Claims      c
JOIN dbo.Policies    p  ON c.PolicyID   = p.PolicyID
JOIN dbo.Customers   cu ON c.CustomerID = cu.CustomerID;