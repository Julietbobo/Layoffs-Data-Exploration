# Layoffs Data Exploration - MySql 

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

`Alter table layoffs1 modify column date date;`



