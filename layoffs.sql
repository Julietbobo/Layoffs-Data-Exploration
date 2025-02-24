-- remove  duplicates -- 
create table layoffs1 like layoffs;
alter table layoffs1 add column row_num int;
insert into layoffs1 select *, row_number()over
(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
from  layoffs;



update layoffs1 set company = trim(company);

update layoffs1 set industry = "Crypto" where industry like "%Crypto%";

update layoffs1 set country = "United States" where country like "%United States%";

update layoffs1 set date= str_to_date(date, "%m/%d/%Y");

Alter table layoffs1 modify column date date;


update layoffs1 t1
join layoffs1 t2 on t1.company=t2.company 
set t1.industry=t2.industry
where (t1.industry is null or t1.industry ='') and (t2.industry is not null and t2.industry !='');

delete from layoffs1 where total_laid_off is null and percentage_laid_off is null;
alter table layoffs1 drop column row_num;


-- find the most to least layoffs --
select company, industry, total_laid_off, percentage_laid_off from layoffs1 order by 4 desc;

-- sum of layoffs by country --
select company, sum(total_laid_off) from layoffs1  group by company order by 2 desc ;

-- sum of layoffs by year --
select year(date)  as years, sum(total_laid_off) as total_laid_offs from layoffs1  group by years;

-- sum of layoffs by industry --
select industry, sum(total_laid_off) from layoffs1  group by industry order by 2 desc ;

-- which country had the most layoffs by avg of the  percentage --
select country, round(avg(percentage_laid_off),2) as avg_layoff , sum(total_laid_off) as total_layoffs from layoffs1
 where total_laid_off is not null  group by country order by 2 desc ;

-- which company had the most layoffs by avg of the  percentage --
select company, round(avg(percentage_laid_off),2) as avg_layoff ,sum(total_laid_off) as total_layoffs from layoffs1
 where total_laid_off is not null group by company order by 2 desc;

-- what range of period did these layoffs take place --
select min(date) , max(date) from layoffs1;

-- running total of the layoffs --

with temp as(select substring(date, 1,7)  as months, sum(total_laid_off) as totals from layoffs1
group by months order by 1)
 select months, totals,  sum(totals) over (order by months) as running from temp ;
 
 with temp (company, years, totals) as
 (select company, year(date) as years, sum(total_laid_off) as totals from layoffs1
 where total_laid_off is not null group by company, years, total_laid_off order by 2 asc),
 temp2 as 
 (select *, dense_rank() over (partition by years order by years, totals desc) as ranks from temp)
 select * from temp2 where years is not null;




