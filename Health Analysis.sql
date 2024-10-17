-- Total treatment cost, average insurance coverage, grouped by insurance provider and department

select 
    sum(`Treatment Cost`) as cost,
    round(avg(`Insurance Coverage`),2) as ins_cov,
    insurance.`Insurance Provider`,
    departments.Department
from visits
join insurance on visits.`Insurance ID` = insurance.`Insurance ID`
join departments on departments.`Department ID` = visits.`Department ID`
group by insurance.`Insurance Provider`, departments.Department;

-- Count of patients by race and referral source, along with the average patient satisfaction score

select 
    count(Race),
    race,
    `Referral Source`,
    avg(`Patient Satisfaction Score`)
from patients
join visits on patients.`Patient ID` = visits.`Patient ID`
group by Race, `Referral Source`;

-- Count of visits for each provider, grouped by provider ID and name

select 
    count(providers.`Provider ID`),
    providers.`Provider Name`
from providers
join visits on visits.`Provider ID` = providers.`Provider ID`
group by providers.`Provider ID`, providers.`Provider Name`;

-- Count of patients by gender

select 
    count(Gender),
    Gender
from patients
group by Gender;

-- Count of visits for each provider, grouped by provider ID, name, and month of visit

select 
    providers.`provider id`, 
    providers.`provider name`, 
    month(str_to_date(visits.`date of visit`, '%d-%m-%y')) as `month`, 
    count(providers.`provider id`) as `visit_count` 
from providers 
join visits on visits.`provider id` = providers.`provider id` 
group by providers.`provider id`, providers.`provider name`, `month`
order by providers.`provider name`, `month`;

-- Count of visits for each provider, grouped by provider ID, name, and weekday of visit

select 
    providers.`provider id`, 
    providers.`provider name`, 
    dayname(str_to_date(visits.`date of visit`, '%d-%m-%y')) as `weekday`, 
    count(providers.`provider id`) as `visit_count` 
from providers 
join visits on visits.`provider id` = providers.`provider id`
group by providers.`provider id`, providers.`provider name`, `weekday`
order by providers.`provider name`, field(`weekday`, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Provider details along with total procedures, average satisfaction score, and total cost, grouped by provider, gender, nationality, and service type

select 
    providers.`Provider Name`,
    providers.`Gender`,
    providers.`Nationality`,
    count(visits.`Procedure ID`) as `Total Procedures`,
    visits.`Service Type`,
    avg(visits.`Patient Satisfaction Score`) as `Average Satisfaction`,
    sum(visits.`Treatment Cost` + visits.`Medication Cost`) as `Total Cost`
from visits
join providers on visits.`Provider ID` = providers.`Provider ID`
join procedures on visits.`Procedure ID` = procedures.`Procedure ID`
group by providers.`Provider Name`, providers.`Gender`, providers.`Nationality`, visits.`Service Type`;


-- Count Visits by Provider and Insurance Type 
 
select providers.`provider id`, 
providers.`provider name`, 
visits.`insurance id`, 
count(visits.`patient id`) as `visit_count` 
from providers 
join visits on visits.`provider id` = providers.`provider id` 
group by providers.`provider id`, 
providers.`provider name`, 
visits.`insurance id` 
order by providers.`provider name`;

-- Total Treatment Cost by Provider

select providers.`provider id`, 
providers.`provider name`, 
sum(visits.`treatment cost`) as `total_treatment_cost` 
from providers 
join visits on visits.`provider id` = providers.`provider id` 
group by providers.`provider id`, 
providers.`provider name` 
order by `total_treatment_cost` desc;

 -- Average Patient Satisfaction by Provider

select providers.`provider id`, 
providers.`provider name`, 
avg(visits.`patient satisfaction score`) as `average_satisfaction` 
from providers 
join visits on visits.`provider id` = providers.`provider id` 
group by providers.`provider id`, 
providers.`provider name` 
order by `average_satisfaction` desc;


-- Number of Emergency Visits by Provider

select providers.`provider id`, 
providers.`provider name`, 
count(visits.`patient id`) as `emergency_visit_count` 
from providers 
join visits on visits.`provider id` = providers.`provider id` 
where visits.`emergency visit` = 'yes' 
group by providers.`provider id`, 
providers.`provider name` 
order by `emergency_visit_count` desc;

-- This query counts the total number of visits for each gender
select patients.`gender`, 
count(visits.`patient id`) as `visit_count` 
from visits 
join patients on visits.`patient id` = patients.`patient id` 
group by patients.`gender` 
order by `visit_count` desc;

--  Distinct number of patients for each department and insurance provider, ordered by patient count in descending order

select departments.`Department`, 
insurance.`Insurance Provider`, 
count(distinct visits.`patient id`) as `patient_count` 
from visits 
join departments on departments.`Department ID` = visits.`Department ID` 
join insurance on insurance.`Insurance ID` = visits.`Insurance ID` 
group by departments.`Department`, 
insurance.`Insurance Provider` 
order by `patient_count` desc;


-- Number of patients by age group for each department
select 
    departments.`Department`, 
    case 
        when patients.`age` <= 18 then '0-18'
        when patients.`age` between 19 and 35 then '19-35'
        when patients.`age` between 36 and 50 then '36-50'
        when patients.`age` between 51 and 65 then '51-65'
        else '66+' 
    end as `age_group`, 
    count(*) as `patient_count` 
from patients 
join visits on visits.`patient id` = patients.`patient id` 
join departments on departments.`Department ID` = visits.`Department ID` 
group by departments.`Department`, `age_group` 
order by departments.`Department`, `age_group`;

-- Average age of patients in each department

select departments.`Department`, 
       avg(patients.`age`) as `average_age` 
from patients 
join visits on visits.`patient id` = patients.`patient id` 
join departments on departments.`Department ID` = visits.`Department ID` 
group by departments.`Department` 
order by `average_age` desc;

-- Departments with more patients than the average

select departments.`Department`, 
       count(distinct visits.`patient id`) as `patient_count` 
from departments 
join visits on visits.`Department ID` = departments.`Department ID` 
group by departments.`Department` 
having `patient_count` > 
    (select avg(`patient_count`) 
     from (select count(distinct visits.`patient id`) as `patient_count` 
           from visits 
           group by `Department ID`) as avg_count)
order by `patient_count` desc;



-- List of patients with more than one visit

select patients.`patient id`, 
       patients.`Patient Name`, 
       count(*) as `visit_count` 
from patients 
join visits on visits.`patient id` = patients.`patient id` 
group by patients.`patient id`, 
         patients.`Patient Name` 
having `visit_count` > 1;



-- List of patients with more than one visit, including their department and insurance provider

select patients.`patient id`, 
       patients.`Patient Name`, 
       departments.`Department`, 
       insurance.`Insurance Provider`, 
       count(*) as `visit_count` 
from patients 
join visits on visits.`patient id` = patients.`patient id` 
join departments on departments.`Department ID` = visits.`Department ID` 
join insurance on insurance.`Insurance ID` = visits.`Insurance ID` 
group by patients.`patient id`, 
         patients.`Patient Name`, 
         departments.`Department`, 
         insurance.`Insurance Provider` 
having `visit_count` > 1;

-- List of patients who have used more than one insurance provider

select 
    patients.`Patient ID`, 
    patients.`Patient Name`, 
    count(distinct visits.`Insurance ID`) as `insurance_count` 
from patients 
join visits on patients.`Patient ID` = visits.`Patient ID` 
group by patients.`Patient ID`, patients.`Patient Name`
having `insurance_count` > 1;

-- List of patients who visited multiple departments

select 
    patients.`Patient ID`, 
    patients.`Patient Name`, 
    count(distinct visits.`Department ID`) as `department_count` 
from patients 
join visits on patients.`Patient ID` = visits.`Patient ID` 
group by patients.`Patient ID`, patients.`Patient Name` 
having `department_count` > 1;

-- Total revenue (treatment + medication cost) by patient gender

select 
    patients.`Gender`, 
    sum(visits.`Treatment Cost` + visits.`Medication Cost`) as `total_revenue`
from patients
join visits on patients.`Patient ID` = visits.`Patient ID`
group by patients.`Gender`;

-- Average treatment cost per age group

select 
    case 
        when patients.age <= 18 then '0-18'
        when patients.age between 19 and 35 then '19-35'
        when patients.age between 36 and 50 then '36-50'
        when patients.age between 51 and 65 then '51-65'
        else '66+' 
    end as `age_group`, 
    round(avg(visits.`Treatment Cost`), 2) as `avg_treatment_cost` 
from patients 
join visits on patients.`Patient ID` = visits.`Patient ID`
group by `age_group`;



