# Layoffs Data Exploration - MySql 

- Snapshot of the table
  
![Screenshot (41)](https://github.com/user-attachments/assets/d0febeaa-3fe3-4542-bd34-02c14cdac47d)


### Data cleaning
- I started by making a copy of the original table (layoffs) incase of any errors I'll have a back up.
  
```
create table layoffs1 like layoffs;
insert into layoffs1 select*from layoff;
```
      
- Then wrote a query to remove duplicates. I achived this by creating an extra row column for row numbers and used  the row_number() window function to identify rows with a row number of greater than and delete them since they would be duplicates.

```
alter table layoffs1 add column row_num int;
insert into layoffs1 select *, row_number()over
(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
from  layoffs;
```
- The Company column had some names wrongly written so I corrected them and some had extra spaces.

`update layoffs1 set company = trim(company);`

`update layoffs1 set industry = "Crypto" where industry like "%Crypto%";`

`update layoffs1 set country = "United States" where country like "%United States%";`

- I changed the data type of the dates column from text to date

`update layoffs1 set date= str_to_date(date, "%m/%d/%Y");`

- Some rows were missing data in the industry column but some had. So I used self join and used it to fill up missing data

 ```
  update layoffs1 t1
join layoffs1 t2 on t1.company=t2.company 
set t1.industry=t2.industry
where (t1.industry is null or t1.industry ='') and (t2.industry is not null and t2.industry !='');

```
- Rows that had both total_laid_off as null and percentage laid off as null weren't useful so I deleted them.
  
`delete from layoffs1 where total_laid_off is null and percentage_laid_off is null;`



### Data Exploration
- Some of the questions i sought to ask were:
  1.  find the most to least layoffs
     `select company, industry, total_laid_off, percentage_laid_off from layoffs1 order by 4 desc;`
  2.  sum of layoffs by country
     `select company, sum(total_laid_off) from layoffs1  group by company order by 2 desc ;`
  3.  sum of layoffs by year
     `select year(date)  as years, sum(total_laid_off) as total_laid_offs from layoffs1  group by years;`
  4.  sum of layoffs by industry
     `select industry, sum(total_laid_off) from layoffs1  group by industry order by 2 desc ;`
  5.  which country had the most layoffs by avg of the  percentage
     
```
 select country, round(avg(percentage_laid_off),2) as avg_layoff , sum(total_laid_off) as total_layoffs from layoffs1
 where total_laid_off is not null  group by country order by 2 desc ;
```
  6.  which company had the most layoffs by avg of the  percentage
  7.  running total of the layoffs
 
  ```
with temp as(select substring(date, 1,7)  as months, sum(total_laid_off) as totals from layoffs1
group by months order by 1)
 select months, totals,  sum(totals) over (order by months) as running from temp ;
```


![running](https://github.com/user-attachments/assets/aa9688d8-8389-4db4-b9d7-44f0f82aea00)

8. Ranked the company by the number of layoffs for each year.

```
with temp (company, years, totals) as
 (select company, year(date) as years, sum(total_laid_off) as totals from layoffs1
 where total_laid_off is not null group by company, years, total_laid_off order by 2 asc),
 temp2 as 
 (select *, dense_rank() over (partition by years order by years, totals desc) as ranks from temp)
 select * from temp2 where years is not null;
```
![rank layoffs by company for each year](https://github.com/user-attachments/assets/d6ec361f-6ecb-4bf0-972c-235fd3cb8bb6)
