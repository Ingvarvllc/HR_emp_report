CREATE DATABASE Project;

USE Project;

SELECT * FROM Human_Resources;

EXEC sp_rename 'Human_Resources.id', 'emp_id', 'COLUMN';

ALTER TABLE Human_Resources
ALTER COLUMN emp_id VARCHAR(20) NULL;

UPDATE Human_Resources
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN TRY_CONVERT(datetime2(7), birthdate, 101) -- Format: mm/dd/yyyy
    WHEN birthdate LIKE '%-%' THEN TRY_CONVERT(datetime2(7), birthdate, 110) -- Format: mm-dd-yyyy
    ELSE NULL
END;

SELECT * FROM Human_Resources
WHERE birthdate LIKE '%-%'

ALTER TABLE Human_Resources
ALTER COLUMN birthdate DATE;

SELECT * FROM Human_Resources
WHERE hire_date LIKE '%-%'

ALTER TABLE Human_Resources
ALTER COLUMN hire_date DATE;

UPDATE Human_Resources
SET termdate = CAST(REPLACE(termdate, 'UTC', '') AS DATE);

ALTER TABLE Human_Resources
ALTER COLUMN termdate DATE;

ALTER TABLE Human_Resources
ADD age INT;

BEGIN TRANSACTION;

UPDATE Human_Resources
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

SELECT * FROM Human_Resources

-- QUESTIONS --
-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS gendercount FROM Human_Resources
GROUP BY gender;
-- 2. What is the race/ethnicity breakdown of employees in the company? 
SELECT race, COUNT(*) AS racecount FROM Human_Resources
GROUP BY race
ORDER BY COUNT(*) DESC;
-- 3. What is the age distribution of employees in the company?
SELECT MIN(age), MAX(age) FROM Human_Resources 

WITH Age_Categorized AS (
    SELECT 
        CASE
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END AS age_group, gender
    FROM Human_Resources
)
SELECT age_group, gender, COUNT(*) AS count_group
FROM Age_Categorized
GROUP BY age_group, gender
ORDER BY age_group, gender

-- 4. How many employees work at headquarters versus remote locations?
SELECT [location], COUNT(*) AS work_location FROM Human_Resources
GROUP BY [location]

-- 5. What is the average length of employment for employees who have been terminated?
SELECT AVG(DATEDIFF(DAY, hire_date, termdate)) / 365 AS avg_length_employment
FROM Human_Resources
WHERE termdate <= GETDATE();

-- 6. How does the gender distribution vary across departments?
SELECT department, gender, COUNT(*) AS count
FROM Human_Resources
GROUP BY department, gender
ORDER BY department, gender

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS count
FROM Human_Resources
GROUP BY jobtitle
ORDER BY jobtitle

-- 8. Which department has the highest turnover rate?
SELECT department,
       total_count,
       terminated_count,
       CAST(terminated_count AS FLOAT) / total_count AS termination_rate
FROM (
    SELECT department,
           COUNT(*) AS total_count,
           SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminated_count
    FROM Human_Resources
    GROUP BY department
) AS Subquery
ORDER BY termination_rate;

-- 9. What is the distribution of employees across locations by city and state? 
SELECT location_state, COUNT(*) AS count
FROM Human_Resources
GROUP BY location_state
ORDER BY count DESC

-- 10. How has the company's employee count changed over time based on hire and term dates? 

SELECT 
	hire_year as year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND(CAST((hires - terminations) AS FLOAT) / hires * 100, 2) AS net_change_prcntg
FROM ( 
    SELECT 
        YEAR(hire_date) AS hire_year,
        COUNT(*) AS hires, 
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminations 
    FROM Human_Resources
    GROUP BY YEAR(hire_date)
) AS Subquery
ORDER BY hire_year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(DAY, hire_date, termdate) / 365), 0) AS avg_tenure
FROM Human_Resources
WHERE  termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department;


SELECT * FROM Human_Resources


 
 



