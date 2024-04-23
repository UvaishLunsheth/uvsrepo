--create the new table 'world_layoff' with the same structure as the 'layoffs' table
CREATE TABLE world_layoff AS
SELECT * FROM layoffs WHERE 1=0;
--insert values into the 'world_layoff' table
INSERT INTO world_layoff
SELECT * FROM layoffs;

select * from world_layoff

--Lets's create exploratory data analysis (EDA) process step by step
---Descriptive statistics for numeric columns such as 'total_laid_off' and 'funds_raised_millions'

-- Descriptive statistics for numeric columns
SELECT 
    COUNT(total_laid_off) AS total_laid_off_count,
    AVG(total_laid_off) AS total_laid_off_avg,
    MIN(total_laid_off) AS total_laid_off_min,
    MAX(total_laid_off) AS total_laid_off_max,
    STDDEV(total_laid_off) AS total_laid_off_stddev,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_laid_off) AS total_laid_off_q1,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_laid_off) AS total_laid_off_median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_laid_off) AS total_laid_off_q3
FROM world_layoff;

SELECT 
    COUNT(funds_raised_millions) AS funds_raised_count,
    AVG(funds_raised_millions) AS funds_raised_avg,
    MIN(funds_raised_millions) AS funds_raised_min,
    MAX(funds_raised_millions) AS funds_raised_max,
    STDDEV(funds_raised_millions) AS funds_raised_stddev,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY funds_raised_millions) AS funds_raised_q1,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY funds_raised_millions) AS funds_raised_median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY funds_raised_millions) AS funds_raised_q3
FROM world_layoff;


-- Frequency counts for country
SELECT 
    country,
    COUNT(*) AS frequency
FROM layoffs
GROUP BY country
ORDER BY frequency DESC;

-- Count of layoffs by year
SELECT 
    EXTRACT(YEAR FROM date) AS year,
    COUNT(*) AS layoffs_count
FROM layoffs
GROUP BY year
ORDER BY year;

-- Count of layoffs by month
SELECT 
    EXTRACT(MONTH FROM date) AS month,
    COUNT(*) AS layoffs_count
FROM layoffs
GROUP BY month
ORDER BY month;

-- Correlation between total_laid_off and funds_raised_millions
SELECT 
    CORR(total_laid_off, funds_raised_millions) AS correlation_coefficient
FROM layoffs;


--find the company with the biggest single layoff

SELECT 
    company,
    total_laid_off
FROM 
    world_layoff
ORDER BY 
    total_laid_off DESC
LIMIT 1;
---Answer: google is the only single company who has biggest layoff


--what are the companies which has most layoff per year
WITH ranked_layoffs AS (
    SELECT 
        company,
        EXTRACT(YEAR FROM date) AS year,
        SUM(total_laid_off) AS total_layoffs,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM date) ORDER BY SUM(total_laid_off) DESC) AS rank
    FROM 
        world_layoff
    GROUP BY 
        company, year
)
SELECT 
    company,
    year,
    total_layoffs
FROM 
    ranked_layoffs
WHERE 
    rank = 1;

--calculates the rolling total of layoffs per month using a Common Table Expression (CTE)
WITH DATE_CTE AS 
(
    SELECT 
        TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM') AS dates,
        SUM(total_laid_off) AS total_laid_off
    FROM 
        world_layoff
    GROUP BY 
        dates
    ORDER BY 
        dates ASC
)
SELECT 
    dates, 
    SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM 
    DATE_CTE
ORDER BY 
    dates ASC;


