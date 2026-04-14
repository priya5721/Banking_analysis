CREATE DATABASE bank_project;
USE bank_project;
SHOW DATABASES;
CREATE TABLE bank_data (
    id INT,
    member_id INT,
    loan_amnt FLOAT,
    funded_amnt FLOAT,
    funded_amnt_inv FLOAT,
    term VARCHAR(20),
    int_rate FLOAT,
    installment FLOAT,
    grade VARCHAR(5),
    sub_grade VARCHAR(10),
    emp_title TEXT,
    emp_length VARCHAR(20),
    home_ownership VARCHAR(20),
    annual_inc FLOAT,
    verification_status VARCHAR(50),
    issue_d VARCHAR(20),
    loan_status VARCHAR(50),
    pymnt_plan VARCHAR(10),
    description TEXT,
    purpose VARCHAR(50),
    title VARCHAR(100),
    zip_code VARCHAR(20),
    addr_state VARCHAR(10),
    dti FLOAT,

    delinq_2yrs INT,
    earliest_cr_line VARCHAR(20),
    inq_last_6mths INT,
    mths_since_last_delinq INT,
    mths_since_last_record INT,
    open_acc INT,
    pub_rec INT,
    revol_bal FLOAT,
    revol_util FLOAT,
    total_acc INT,
    initial_list_status VARCHAR(10),
    out_prncp FLOAT,
    out_prncp_inv FLOAT,
    total_pymnt FLOAT,
    total_pymnt_inv FLOAT,
    total_rec_prncp FLOAT,
    total_rec_int FLOAT,
    total_rec_late_fee FLOAT,
    recoveries FLOAT,
    collection_recovery_fee FLOAT,
    last_pymnt_d VARCHAR(20),
    last_pymnt_amnt FLOAT,
    next_pymnt_d VARCHAR(20),
    last_credit_pull_d VARCHAR(20)
);
SHOW TABLES;
SHOW VARIABLES LIKE 'secure_file_priv';
/*data imported*/ 
SELECT * FROM bank_data;
SELECT DATABASE();
SHOW TABLES;

-- Load Data (Update path based on your system)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bank_data.csv'
IGNORE
INTO TABLE bank_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bank_data;
SELECT * FROM bank_data LIMIT 10;

desc bank_data;
ALTER TABLE bank_data
MODIFY loan_amnt DECIMAL(10,2),
MODIFY funded_amnt DECIMAL(10,2),
MODIFY funded_amnt_inv DECIMAL(10,2),
MODIFY int_rate DECIMAL(5,2),
MODIFY installment DECIMAL(10,2);

ALTER TABLE bank_data
MODIFY dti DECIMAL(5,2);

ALTER TABLE bank_data
MODIFY issue_d DATE;

SELECT COUNT(*) 
FROM bank_data
WHERE issue_d IS NULL;

SELECT 
COUNT(*) AS total_rows,
SUM(CASE WHEN loan_amnt IS NULL THEN 1 ELSE 0 END) AS loan_nulls,
SUM(CASE WHEN emp_title IS NULL THEN 1 ELSE 0 END) AS emp_nulls
FROM bank_data;

ALTER TABLE bank_data
MODIFY loan_amnt DECIMAL(10,2) NOT NULL;

SELECT * FROM bank_data
WHERE id IS NULL 
   OR member_id IS NULL
   OR loan_amnt IS NULL
   OR funded_amnt IS NULL
   OR funded_amnt_inv IS NULL
   OR term IS NULL
   OR int_rate IS NULL
   OR installment IS NULL
   OR grade IS NULL
   OR sub_grade IS NULL
   OR home_ownership IS NULL
   OR annual_inc IS NULL
   OR loan_status IS NULL
   OR issue_d IS NULL;
   
   ALTER TABLE bank_data

-- NOT NULL + Correct types
MODIFY id INT NOT NULL,
MODIFY member_id INT NOT NULL,

MODIFY loan_amnt DECIMAL(10,2) NOT NULL,
MODIFY funded_amnt DECIMAL(10,2) NOT NULL,
MODIFY funded_amnt_inv DECIMAL(10,2) NOT NULL,

MODIFY term VARCHAR(20) NOT NULL,
MODIFY int_rate DECIMAL(5,2) NOT NULL,
MODIFY installment DECIMAL(10,2) NOT NULL,

MODIFY grade VARCHAR(5) NOT NULL,
MODIFY sub_grade VARCHAR(5) NOT NULL,
MODIFY home_ownership VARCHAR(20) NOT NULL,

MODIFY annual_inc DECIMAL(12,2) NOT NULL,
MODIFY loan_status VARCHAR(50) NOT NULL,

MODIFY issue_d DATE NOT NULL,

-- NULL allowed columns
MODIFY emp_title TEXT NULL,
MODIFY emp_length VARCHAR(10) NULL,
MODIFY description TEXT NULL,
MODIFY zip_code VARCHAR(20) NULL,
MODIFY dti DECIMAL(5,2) NULL;

select * from bank_data limit 5;

-- 1. TOTAL CUSTOMERS
SELECT 
    COUNT(DISTINCT member_id) AS total_customers
FROM bank_data;

-- 2. TOAL LOAN AMOUNT
SELECT 
    CONCAT(ROUND(SUM(loan_amnt)/1000000, 2), 'M') AS total_loan_amount
FROM bank_data;

-- 3. AVERAGE INTREST
SELECT 
    CONCAT(ROUND(AVG(int_rate)*100, 2), '%') AS avg_interest
FROM bank_data;

-- 4. TOTAL PAYMENT
SELECT 
    CONCAT(ROUND(SUM(total_pymnt)/1000000, 2), 'M') AS total_payment
FROM bank_data;

-- 5. YEAR WISE LOAN AMOUNT
SELECT 
    YEAR(issue_d) AS year,
    CONCAT(ROUND(SUM(loan_amnt)/1000000, 2), 'M') AS total_loan
FROM bank_data
GROUP BY YEAR(issue_d)
ORDER BY year;

-- 6. AVERAGE LOAN AMOUNT BY GRADE
SELECT 
    grade,
    ROUND(AVG(loan_amnt), 0) AS avg_loan
FROM bank_data
GROUP BY grade;

-- 7. GRADE AND SUBGRADE WISE REVOL BAL
SELECT 
    grade,
    sub_grade,
    CONCAT(ROUND(SUM(revol_bal)/1000000, 2), 'M') AS Total_revol_bal 
FROM bank_data
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- 8. VERIFIED AND NON-VERIFIED WISE PAYMENT
SELECT 
    verification_status,
    CONCAT(
        ROUND(SUM(total_pymnt) * 100.0 / 
        (SELECT SUM(total_pymnt) FROM bank_data), 2),
    '%') AS payment_percentage
FROM bank_data
GROUP BY verification_status;

-- 9. HOME OWNERSHIP VS LOAN STATUS
SELECT 
    home_ownership,
    loan_status,
    CONCAT(
        ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM bank_data), 2),
    '%') AS percentage
FROM bank_data
GROUP BY home_ownership, loan_status;

-- 10. STATE AND MONTH WISE LOAN STATUS
    SELECT 
    addr_state,
    DATE_FORMAT(issue_d, '%Y-%m') AS issue_month,
    loan_status,
    COUNT(*) AS total_loans
FROM bank_data
GROUP BY 
    addr_state, 
    issue_month, 
    loan_status
ORDER BY 
    addr_state, 
    issue_month;
    
-- 11. TOP STATE BY LOAN AMOUNT
SELECT 
    addr_state,
    CONCAT(ROUND(SUM(loan_amnt)/1000000, 2), 'M') AS total_loan
FROM bank_data
GROUP BY addr_state
ORDER BY SUM(loan_amnt) DESC
LIMIT 10;

-- 12. TOTAL FUNDED VS TOTAL RECEIVED AND PROFIT
SELECT 
    CONCAT(ROUND(SUM(funded_amnt)/1000000, 2), 'M') AS total_funded,
    CONCAT(ROUND(SUM(total_pymnt)/1000000, 2), 'M') AS total_received,
    CONCAT(
        ROUND(
            (SUM(total_pymnt) - SUM(funded_amnt)) * 100.0 
            / SUM(funded_amnt), 
        2),
    '%') AS profit
FROM bank_data;

-- # LOAN PORTFOLIO SUMMARY
SELECT 
    -- Total Customers
    COUNT(DISTINCT member_id) AS total_customers,

    -- Total Loan Amount (M)
    CONCAT(ROUND(SUM(loan_amnt)/1000000, 2), 'M') AS total_loan_amount,

    -- Total Funded (M)
    CONCAT(ROUND(SUM(funded_amnt)/1000000, 2), 'M') AS total_funded,

    -- Total Received (M)
    CONCAT(ROUND(SUM(total_pymnt)/1000000, 2), 'M') AS total_received,

    -- Profit %
    CONCAT(
        ROUND(
            (SUM(total_pymnt) - SUM(funded_amnt)) * 100.0 
            / SUM(funded_amnt), 
        2),
    '%') AS profit_percentage,

    -- Average Interest Rate
    CONCAT(ROUND(AVG(int_rate)*100, 2), '%') AS avg_interest_rate,

    -- Default Rate %
    CONCAT(
        ROUND(
            SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 
            / COUNT(*), 
        2),
    '%') AS default_rate

FROM bank_data;