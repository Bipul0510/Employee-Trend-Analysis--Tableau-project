-- ds_salaries.sql

-- Q1: Compare the average Senior-level (SE) salary in the US vs. the rest of the world.
-- This highlights the global salary inequity problem.
SELECT
    CASE WHEN company_location = 'US' THEN 'US' ELSE 'Rest of World' END AS location_group,
    ROUND(AVG(salary_in_usd), 2) AS average_senior_salary_usd,
    COUNT(*) AS number_of_jobs
FROM
    ds_salaries
WHERE
    experience_level = 'SE'
GROUP BY
    location_group
ORDER BY
    average_senior_salary_usd DESC;

-- Q2: Find the Top 3 highest-paying job titles for Mid-level (MI) employees.
-- This helps Mid-level professionals identify the best next move for a raise.
SELECT
    job_title,
    ROUND(AVG(salary_in_usd), 2) AS average_salary_usd,
    COUNT(*) AS job_count
FROM
    ds_salaries
WHERE
    experience_level = 'MI'
GROUP BY
    job_title
HAVING
    COUNT(*) >= 5 -- Filter for job titles with at least 5 entries for reliability
ORDER BY
    average_salary_usd DESC
LIMIT 3;

-- Q3: Analyze the salary difference between 100% remote and 0% remote jobs overall.
-- This addresses the impact of remote work on compensation.
SELECT
    remote_ratio,
    ROUND(AVG(salary_in_usd), 2) AS average_salary_usd,
    COUNT(*) AS job_count
FROM
    ds_salaries
WHERE
    remote_ratio IN (0, 100)
GROUP BY
    remote_ratio;

-- Q4: Calculate the Year-over-Year (YoY) salary growth rate.
-- This quantifies the market's rapid compensation increase.
WITH YearlyAverages AS (
    SELECT
        work_year,
        AVG(salary_in_usd) AS avg_salary
    FROM
        ds_salaries
    GROUP BY
        work_year
)
SELECT
    t1.work_year,
    t1.avg_salary,
    -- Calculate percentage change from the previous year
    ROUND(((t1.avg_salary - t2.avg_salary) / t2.avg_salary) * 100, 2) AS yoy_growth_rate_percent
FROM
    YearlyAverages t1
LEFT JOIN
    YearlyAverages t2 ON t1.work_year = t2.work_year + 1
ORDER BY
    t1.work_year;

-- Q5: Identify the most common job title for each company size (S, M, L).
-- This helps job seekers understand which roles are in demand at different company scales.
WITH RankedJobs AS (
    SELECT
        company_size,
        job_title,
        COUNT(*) AS title_count,
        ROW_NUMBER() OVER (PARTITION BY company_size ORDER BY COUNT(*) DESC) as rn
    FROM
        ds_salaries
    GROUP BY
        company_size, job_title
)
SELECT
    company_size,
    job_title AS most_common_job,
    title_count
FROM
    RankedJobs
WHERE
    rn = 1;

-- Q6: Find the highest paying job in each experience level for 2022.
-- Provides a current benchmark for top-tier salaries across career stages.
WITH RankedSalaries AS (
    SELECT
        experience_level,
        job_title,
        salary_in_usd,
        ROW_NUMBER() OVER (PARTITION BY experience_level ORDER BY salary_in_usd DESC) as rn
    FROM
        ds_salaries
    WHERE
        work_year = 2022
)
SELECT
    experience_level,
    job_title,
    salary_in_usd AS max_salary_2022
FROM
    RankedSalaries
WHERE
    rn = 1;

-- Q7: Count the number of unique job titles for each company size.
-- Helps understand job title diversity/specialization by company scale.
SELECT
    company_size,
    COUNT(DISTINCT job_title) AS unique_job_titles_count
FROM
    ds_salaries
GROUP BY
    company_size
ORDER BY
    unique_job_titles_count DESC;
