
---------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
use  banking;

select * from bank_transaction;

-- Data Exploration
-- 1. Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM bank_transaction;

-- 2. Total customers/accounts
SELECT COUNT(DISTINCT AccountID) AS total_accounts
FROM bank_transaction;

-- 3. Unique transaction types
SELECT DISTINCT TransactionType
FROM bank_transaction;

-- 4. Date range of transactions
SELECT
    MIN(TransactionDate) AS first_transaction,
    MAX(TransactionDate) AS last_transaction
FROM bank_transaction;

-- Data Quality Checks
-- 5. Find duplicate transactions
SELECT TransactionID, COUNT(*)
FROM bank_transaction
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- 6. Find negative or zero transactions
SELECT *
FROM bank_transaction
WHERE TransactionAmount <= 0;

-- 7. Find invalid transaction dates
SELECT *
FROM bank_transaction
WHERE TransactionDate < PreviousTransactionDate;

-- 8. Find customers with unrealistic age
SELECT *
FROM bank_transaction
WHERE CustomerAge < 18 OR CustomerAge > 100;
   
-- Transaction Analysis
-- 9. Total transaction amount by type
SELECT
    TransactionType,
    SUM(TransactionAmount) AS total_amount
FROM bank_transaction
GROUP BY TransactionType;

-- 10. Average transaction amount by type
SELECT
    TransactionType,
    ROUND(AVG(TransactionAmount),2) AS avg_amount
FROM bank_transaction
GROUP BY TransactionType;

-- 11. Top 10 highest transactions
SELECT *
FROM bank_transaction
ORDER BY TransactionAmount DESC
LIMIT 10;

-- 12. Daily transaction volume
SELECT
    DATE(TransactionDate) AS txn_date,
    COUNT(*) AS total_transactions
FROM bank_transaction
GROUP BY DATE(TransactionDate)
ORDER BY DATE(TransactionDate) DESC ;

-- Customer Analysis
-- 13. Top 10 customers by total transaction amount
SELECT
    AccountID,
    ROUND(SUM(TransactionAmount),2) AS total_spent
FROM bank_transaction
GROUP BY AccountID
ORDER BY total_spent DESC
LIMIT 10;

-- 14. Customers with most transactions
SELECT
    AccountID,
    COUNT(*) AS txn_count
FROM bank_transaction
GROUP BY AccountID
ORDER BY txn_count DESC;

-- 15. Average account balance by location
SELECT
    Location,
    AVG(AccountBalance) AS avg_balance
FROM bank_transaction
GROUP BY Location;

-- Channel & Location Analysis
-- 16. Most used transaction channel
SELECT
    Channel,
    COUNT(*) AS total_transactions
FROM bank_transaction
GROUP BY Channel
ORDER BY total_transactions DESC;

-- 17. Transactions by location
SELECT
    Location,
    COUNT(*) AS txn_count
FROM bank_transaction
GROUP BY Location
ORDER BY txn_count DESC;

-- 18. Highest transaction amount by location
SELECT
    Location,
    MAX(TransactionAmount) AS max_transaction
FROM bank_transaction
GROUP BY Location;

-- Fraud Detection SQL
-- 19. Accounts with more than 5 login attempts
SELECT *
FROM bank_transaction
WHERE LoginAttempts > 5;

-- 20. Transactions greater than account balance
SELECT *
FROM bank_transaction
WHERE TransactionAmount > AccountBalance;

-- 21. Accounts using multiple devices
SELECT
    AccountID,
    COUNT(DISTINCT DeviceID) AS device_count
FROM bank_transaction
GROUP BY AccountID
HAVING COUNT(DISTINCT DeviceID) > 1;

-- 22. Accounts operating from multiple locations
SELECT
    AccountID,
    COUNT(DISTINCT Location) AS location_count
FROM bank_transaction
GROUP BY AccountID
HAVING COUNT(DISTINCT Location) > 1;

-- Intermediate SQL (Window Functions)
-- 23. Rank transactions by amount
SELECT
    TransactionID,
    AccountID,
    TransactionAmount,
    RANK() OVER(ORDER BY TransactionAmount DESC) AS rank_no
FROM bank_transaction;

-- 24. Running transaction total
SELECT
    AccountID,
    TransactionDate,
    TransactionAmount,
    ROUND(SUM(TransactionAmount) OVER(PARTITION BY AccountID ORDER BY TransactionDate),2) AS running_total
FROM bank_transaction;

-- 25. Previous transaction amount
SELECT
    AccountID, TransactionDate, TransactionAmount,
     LAG(TransactionAmount) OVER (PARTITION BY AccountID ORDER BY TransactionDate) AS previous_amount
     FROM bank_transaction;

-- Advanced SQL (Resume-Worthy)
-- 26. Detect sudden increase in transaction amount
WITH txn AS (
    SELECT
        AccountID, TransactionDate, TransactionAmount,
        LAG(TransactionAmount) OVER (PARTITION BY AccountID ORDER BY TransactionDate) AS prev_amount
    FROM bank_transaction
)
SELECT *
FROM txn
WHERE TransactionAmount > prev_amount * 3;

-- 27. Find top 3 transactions per customer
WITH ranked_txn AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY AccountID ORDER BY TransactionAmount DESC) AS rn
    FROM bank_transaction
)
SELECT *
FROM ranked_txn
WHERE rn <= 3;

-- 28. Find inactive customers
SELECT AccountID
FROM bank_transaction
GROUP BY AccountID
HAVING MAX(TransactionDate)< CURRENT_DATE - INTERVAL 30 DAY;

-- 29. Monthly transaction trend
SELECT
    YEAR(TransactionDate) AS year,
    MONTH(TransactionDate) AS month,
    SUM(TransactionAmount) AS total_amount
FROM bank_transaction
GROUP BY YEAR(TransactionDate), MONTH(TransactionDate);

-- 30. Generate Fraud Risk Score
SELECT
    AccountID, LoginAttempts, TransactionAmount, AccountBalance,
    ROUND((TransactionAmount / AccountBalance) * 50 + LoginAttempts * 10,2) AS risk_score
FROM bank_transaction
ORDER BY risk_score DESC;

-- 31 Which day of the week has the highest transaction volume?
SELECT
    DAYNAME(TransactionDate) AS day_name,
    COUNT(*) AS total_transactions
FROM bank_transaction
GROUP BY DAYNAME(TransactionDate)
ORDER BY total_transactions DESC;

-- 32 Which hour of the day sees the most transactions?
SELECT
    HOUR(TransactionDate) AS txn_hour,
    COUNT(*) AS total_transactions
FROM bank_transaction
GROUP BY HOUR(TransactionDate)
ORDER BY total_transactions DESC;

-- 33 Identify dormant accounts (no transactions in last 30 days)
SELECT
    AccountID,
    MAX(TransactionDate) AS last_transaction
FROM bank_transaction
GROUP BY AccountID
HAVING MAX(TransactionDate) < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
