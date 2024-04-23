CREATE TABLE layoffs (
    company VARCHAR(255),
    location VARCHAR(255),
    industry VARCHAR(255),
    total_laid_off INT,
    percentage_laid_off DECIMAL(5,2),
    date DATE,
    stage VARCHAR(50),
    country VARCHAR(50),
    funds_raised_millions DECIMAL(10,2)
);

-- Create a temporary table with the same structure as the layoffs table
CREATE TEMP TABLE tempo_layoffs (
    company VARCHAR(255),
    location VARCHAR(255),
    industry VARCHAR(255),
    total_laid_off INT,
    percentage_laid_off DECIMAL(5,2),
    date VARCHAR(10), -- Date will be temporarily stored as VARCHAR
    stage VARCHAR(50),
    country VARCHAR(50),
    funds_raised_millions DECIMAL(10,2)
);

-- Import data into the temporary table
COPY tempo_layoffs (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) 
FROM 'C:/Users/Lenovo/Downloads/layoffs.csv' 
DELIMITER ',' 
CSV 
HEADER 
NULL 'NULL';

-- Insert data into the main layoffs table, converting date format
INSERT INTO layoffs (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
SELECT 
    company, 
    location, 
    industry, 
    total_laid_off, 
    percentage_laid_off, 
    TO_DATE(date, 'MM/DD/YYYY'), -- Convert date format using TO_DATE
    stage, 
    country, 
    funds_raised_millions 
FROM tempo_layoffs;

-- Drop the temporary table
DROP TABLE temp_layoffs;

select * from layoffs 
-- To identify duplicates values Use a common table expression (CTE) to identify duplicate rows
WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
    FROM layoffs
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

--check rows associated with 'casper' company--
SELECT *
FROM layoffs
WHERE company = 'Casper';

-- by checking we found that company 'casper' has duplicates values so we need to remove--

WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company, date ORDER BY (SELECT NULL)) AS row_num
    FROM layoffs
    WHERE company = 'Casper'  -- Only consider rows for the "Casper" company
)
DELETE FROM layoffs
WHERE (company, date) IN (
    SELECT company, date
    FROM duplicates_cte
    WHERE row_num > 1
    AND date <> (SELECT MIN(date) FROM duplicates_cte WHERE row_num = 1)
);
--identify and counts the number of null values
SELECT 
    COUNT(*) FILTER (WHERE company IS NULL) AS null_company,
    COUNT(*) FILTER (WHERE location IS NULL) AS null_location,
    COUNT(*) FILTER (WHERE industry IS NULL) AS null_industry,
    COUNT(*) FILTER (WHERE total_laid_off IS NULL) AS null_total_laid_off,
    COUNT(*) FILTER (WHERE percentage_laid_off IS NULL) AS null_percentage_laid_off,
    COUNT(*) FILTER (WHERE date IS NULL) AS null_date,
    COUNT(*) FILTER (WHERE stage IS NULL) AS null_stage,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
    COUNT(*) FILTER (WHERE funds_raised_millions IS NULL) AS null_funds_raised_millions
FROM layoffs;

-- remove all rows with null values--
DELETE FROM layoffs
WHERE company IS NULL OR
      location IS NULL OR
      industry IS NULL OR
      total_laid_off IS NULL OR
      percentage_laid_off IS NULL OR
      date IS NULL OR
      stage IS NULL OR
      country IS NULL OR
      funds_raised_millions IS NULL;
	  
---To verify whether the null values have been successfully removed from the table
SELECT *
FROM layoffs
WHERE company IS NULL OR
      location IS NULL OR
      industry IS NULL OR
      total_laid_off IS NULL OR
      percentage_laid_off IS NULL OR
      date IS NULL OR
      stage IS NULL OR
      country IS NULL OR
      funds_raised_millions IS NULL;

--identify all rows with blank values in the table--
SELECT *
FROM layoffs
WHERE 
    TRIM(company) = '' OR
    TRIM(location) = '' OR
    TRIM(industry) = '' OR
    TRIM(stage) = '' OR
    TRIM(country) = '';

--industry column has contained blank values so remove it from the table
DELETE FROM layoffs
WHERE TRIM(industry) = '';

--To identify if there are any extra spaces or concatenated values in the columns
SELECT 
    company,
    LENGTH(company) AS original_length,
    LENGTH(TRIM(company)) AS trimmed_length,
    location,
    LENGTH(location) AS original_length,
    LENGTH(TRIM(location)) AS trimmed_length,
    industry,
    LENGTH(industry) AS original_length,
    LENGTH(TRIM(industry)) AS trimmed_length,
    stage,
    LENGTH(stage) AS original_length,
    LENGTH(TRIM(stage)) AS trimmed_length,
    country,
    LENGTH(country) AS original_length,
    LENGTH(TRIM(country)) AS trimmed_length
FROM 
    layoffs
WHERE
    LENGTH(company) <> LENGTH(TRIM(company)) OR
    LENGTH(location) <> LENGTH(TRIM(location)) OR
    LENGTH(industry) <> LENGTH(TRIM(industry)) OR
    LENGTH(stage) <> LENGTH(TRIM(stage)) OR
    LENGTH(country) <> LENGTH(TRIM(country));
--update the company name to remove extra spaces 
	  
UPDATE layoffs
SET company = TRIM(company)
WHERE company IN ('Twine Solutions ', 'Pear Therapeutics ');




