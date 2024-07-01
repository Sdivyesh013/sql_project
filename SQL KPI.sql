Create database Projectdb;
Use  Projectdb;
select count(*) from finance_1;
select count(*) from finance_2;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Total Loan Amount
SELECT Concat(Round((sum(loan_amnt)/1000000),2),' M') "Total Loan Amount" 
FROM finance_1;
-- KPI 1.Year wise Loan Amount Stats

SELECT year(issue_d) AS "Year of Loan Amt", Concat(Round((sum(loan_amnt)/1000000),2),' M') AS "Total Loan Amount"
FROM finance_1 
GROUP BY year(issue_d)
ORDER BY year(issue_d);

# year on year increase in loan amount---
select year(issue_d) as year,sum(loan_amnt) as loan_amount,concat(round((((sum(loan_amnt)-lag(sum(loan_amnt),1,0) 
over (order by year(issue_d)))/lag(sum(loan_amnt),1,0) over (order by year(issue_d)))*100),2),'%') as yoy_increase
from finance_1 group by year(issue_d) order by year(issue_d);

# Average Loan Amount Year Wise
SELECT year(issue_d) as Year,Round(avg(loan_amnt),2) "Total Loan Amount" 
FROM finance_1
GROUP BY Year
ORDER BY Year;

# MTD Total Loan Amount
SELECT Concat(Round((sum(loan_amnt)/1000000),2),' M') AS "MTD Loan Amount"
FROM finance_1
WHERE month(issue_d) = 12 And year(issue_d)=2011;
-- # Alternate method for MTD of loan Amount
select concat(round((sum(loan_amnt)/1000000),2),'M') as mtd_loan_amnt from finance_1 
 where year(issue_d) =(select max(year(issue_d)) from finance_1) and
 month(issue_d)=(select max(month(issue_d)) from finance_1);

# PMTD Loan Applicaton
SELECT  Concat(Round((sum(loan_amnt)/1000000),2),' M') AS "PMTD Loan Amount"
FROM finance_1
WHERE month(issue_d) = 11 And year(issue_d)=2011;

# MOM Loan Amount

select concat(round((((cm-pm)/pm)*100),2),'%') as mom_loan_amounmt 
from
(select sum(case when year(issue_d)=2011 and month(issue_d)=12 then loan_amnt else 0 end) as cm,
sum(case when year(issue_d)=2011 and month(issue_d)=11 then loan_amnt else 0 end) as pm 
from finance_1) as sub_query;
-- # Alternate method for MOM of loan amount

SELECT ((SELECT Concat(Round((sum(loan_amnt)/1000000),2),' M') AS "MTD Loan Amount" FROM finance_1 WHERE month(issue_d) = 12 And year(issue_d)=2011)-
         (SELECT  Concat(Round((sum(loan_amnt)/1000000),2),' M') AS "PMTD Loan Amount" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011))/
         (SELECT  Concat(Round((sum(loan_amnt)/1000000),2),' M') AS "PMTD Loan Amount" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011) AS "MOM Loan Applicaton";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- KPI 2.Grade and sub Grade wise revol_bal
SELECT f1.grade AS Grade, f1.sub_grade AS "Sub Grade", Concat(Round((sum(f2.revol_bal)/1000000),2),' M') AS "Revol Balance"
FROM finance_1 f1
INNER JOIN finance_2 f2
ON f1.id = f2.id
GROUP BY f1.grade , f1.sub_grade
ORDER BY f1.grade;

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3.Total Payment for Verified Status Vs Total Payment for Non Verified Status
SELECT verification_status AS "Verification Status", Concat(Round((sum(total_pymnt)/1000000),2),' M') AS "Total Payment"
FROM finance_1
INNER JOIN finance_2 
USING (id)
GROUP BY verification_status
HAVING verification_status IN ("Verified" , "Not Verified")
ORDER BY verification_status;

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4.State wise and month wise loan status
SELECT addr_state AS "State", term AS "Terms", loan_status AS "Loan Status"
FROM finance_1
ORDER BY addr_state,term;
-- # alternate 
select addr_state as state,monthname(issue_d) as month,loan_status,count(loan_status) as customer_count from finance_1 
group by addr_state,monthname(issue_d),loan_status order by count(loan_status) desc;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5.Home ownership Vs last payment date stats
select year(b.last_pymnt_d) as year,a.home_ownership as home_ownership,count(a.home_ownership) as count_of_home_ownership from 
finance_1 as a join finance_2 as b on a.id=b.id where year(b.last_pymnt_d) is not null group by year(b.last_pymnt_d),a.home_ownership 
order by year(b.last_pymnt_d),a.home_ownership;
-- alternate----------------------------------------------------------------------------------------------------------------------------
SELECT home_ownership AS " Home Ownership" , last_pymnt_d AS "Last Payment Date", 
       Concat(Round((sum(total_pymnt)/100000),2),' K') As "Last Payment Amount"
FROM finance_1
INNER JOIN finance_2
USING (id)
GROUP BY home_ownership,last_pymnt_d
ORDER BY last_pymnt_d desc;

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Total Loan Appliction
SELECT count(id) AS "Total Loan Application" 
FROM finance_1;

# MTD Total Loan Applicaton
SELECT  count(id) AS "MTD Loan Application"
FROM finance_1
WHERE month(issue_d) = 12 And year(issue_d)=2011;
-- # alternate method for mtd of loan application

select count(id) from finance_1 
where year(issue_d)=(select max(year(issue_d)) from finance_1) and
month(issue_d)=(select max(month(issue_d)) from finance_1);

# PMTD Loan Applicaton
SELECT  count(id) AS "PMTD Loan Application"
FROM finance_1
WHERE month(issue_d) = 11 And year(issue_d)=2011;

# MOM Loan Applicaton
SELECT ((SELECT  count(id) AS "MTD Loan Application" FROM finance_1 WHERE month(issue_d) = 12 And year(issue_d)=2011)-
		(SELECT  count(id) AS "PMTD Loan Application" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011))/
        (SELECT  count(id) AS "PMTD Loan Application" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011)AS "MOM Loan Application";
        
-- altrnate method for #mom loan application

select concat(round((((a-b)/cast(b as decimal))*100),2),'%') as mom_loan_application
from
(select count(case when year(issue_d)=2011 and month(issue_d)=12 then id else null end) as a,
count(case when year(issue_d)=2011 and month(issue_d)=11 then id else null end) as b
from  finance_1) as sub;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Average Interest Rate Per Customer 
SELECT  Concat(Round(avg(int_rate), 2),'%')  AS "Avg Interest Rate"
FROM finance_1;

# MTD Average Interest Rate
SELECT Concat(Round(avg(int_rate), 2),'%') AS "MTD Avg Interest Rate"
FROM finance_1
WHERE month(issue_d) = 12 And year(issue_d)=2011;

# PMTD Average Interest Rate
SELECT  Concat(Round(avg(int_rate), 2),'%') AS "PMTD Avg Interest Rate"
FROM finance_1
WHERE month(issue_d) = 11 And year(issue_d)=2011;

# MOM Average Interest Rate
SELECT ((SELECT Concat(Round(avg(int_rate), 2),'%') AS "MTD Avg Interest Rate" FROM finance_1 WHERE month(issue_d) = 12 And year(issue_d)=2011)-
         (SELECT  Concat(Round(avg(int_rate), 2),'%') AS "PMTD Avg Interest Rate" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011))/
         (SELECT  Concat(Round(avg(int_rate), 2),'%') AS "PMTD Avg Interest Rate" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011) AS "MOM Avg Interest Rate";

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Average Dti
SELECT  Concat(Round(avg(dti), 2),'%')  AS "Avg Dept to Income"
FROM finance_1;

# MTD Average DTI
SELECT Concat(Round(avg(dti), 2),'%') AS "MTD Avg Dept to Income"
FROM finance_1
WHERE month(issue_d) = 12 And year(issue_d)=2011;

# PMTD Average DTI
SELECT  Concat(Round(avg(dti), 2),'%') AS "PMTD Avg Dept to Income"
FROM finance_1
WHERE month(issue_d) = 11 And year(issue_d)=2011;

# MOM Average DTI
SELECT ((SELECT Concat(Round(avg(dti), 2),'%') AS "MTD Avg Dept to Income" FROM finance_1 WHERE month(issue_d) = 12 And year(issue_d)=2011)-
         (SELECT  Concat(Round(avg(dti), 2),'%') AS "PMTD Avg Dept to Income" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011))/
         (SELECT  Concat(Round(avg(dti), 2),'%') AS "PMTD Avg Dept to Income" FROM finance_1 WHERE month(issue_d) = 11 And year(issue_d)=2011) AS "MOM Avg Dept to Income";



#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Yearly Interest Received 

SELECT year(last_pymnt_d) as Received_Year, Concat(Round(sum(total_rec_int)/100000,2),' K') as "Interest Received"
FROM finance_2
WHERE year(last_pymnt_d) !=  isnull((last_pymnt_d))
GROUP BY Received_Year
ORDER BY Received_Year;

/* Term Wise Loan Amount */
SELECT term, Concat(Round((sum(loan_amnt)/1000000),2),' M') "Total Amount" 
FROM finance_1
GROUP BY term;

/* Top 5 States in terms of customers count /*

SELECT addr_state AS "State Name", count(*) AS "Customer Count"
FROM finance_1
GROUP BY addr_state
ORDER BY "customer_count" desc
LIMIT 5;