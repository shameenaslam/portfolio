/* analysing cleaned tables from employees database by using 
		inner join, group by, having, aggregate function, case,
		sub query, stored procedure etc
*/

USE employees;
## Using multiple join, group by , having --to find out average salary of men and women 
## in each deaprtment till 2002
SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calander_year
FROM
    t_employees e
        JOIN
    t_salaries s ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_name , e.gender , calander_year
HAVING calander_year <= 2002
ORDER BY d.dept_no , calander_year;
        
## using case statement and cross join and inner select function to find out active
## in all the department by gender
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

#creating stored procedure with 2 input to find average salary of employees between min and max salary ranges

DROP PROCEDURE IF EXISTS pull_average_salary;
DELIMITER $$
CREATE PROCEDURE pull_average_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT
round(AVG(s.salary),2) as avg_salary,
e.gender,
d.dept_name
FROM
t_salaries s
		JOIN
t_dept_emp de on s.emp_no = de.emp_no
        JOIN
t_departments d on de.dept_no = d.dept_no
		JOIN
t_employees e on s.emp_no = e.emp_no
where
s.salary between p_min_salary and p_max_salary
group by e.gender, d.dept_name
ORDER BY d.dept_no;
END $$
delimiter ;

-- end --