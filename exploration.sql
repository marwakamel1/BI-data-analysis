use portfolioProject

select *
from [dbo].[covidVaccination]
where [continent] is not null
order by 3,4

-- romve duplicated rows 

--with cte as (
-- select [location],[date],[new_cases],[new_cases_per_million],[total_cases_per_million],[total_deaths],[population],ROW_NUMBER() OVER (PARTITION BY [location],[date] ORDER BY [location],[date] ) row_num
--from [dbo].[covidDeaths]

--)
--delete from cte  
--where row_num > 1


-- showing data 
select [location],[date],[new_cases],[new_cases_per_million],[total_cases_per_million],[total_deaths],[total_deaths_per_million],[population]
from [dbo].[covidDeaths]
where [continent] is not null
order by 1,2

-- death rate 
--shows likelihood of dying if you contact covid

alter table [dbo].[covidDeaths]
ALTER COLUMN [total_deaths] float;

select  [location],[date],[total_cases],[total_deaths], ([total_deaths]/ NULLIF([total_cases], 0))*100 as death_rate
from [dbo].[covidDeaths]
where [continent] is not null
order by 1,2

-- total cases vs population 
-- shows precentege of population got covid 
select  [location],[date],[total_cases],[population], ([total_cases]/[population])*100 as covid_percentage
from [dbo].[covidDeaths]
where [continent] is not null
order by 1,2

-- 

select  [location],[population],MAX([total_cases]) as highest_infection_count ,MAX(([total_cases]/[population]))*100 as covid_population_percentage
from [dbo].[covidDeaths]
where [continent] is not null
group by  [location],[population]
order by covid_population_percentage desc


--select  [location],[population],date,MAX([total_cases]) as highest_infection_count ,MAX(([total_cases]/[population]))*100 as covid_population_percentage
--from [dbo].[covidDeaths]
--where [continent] is not null and [location] like 'bahrain'
--group by  [location],[population],date
--order by covid_population_percentage desc



-- highest countries by death count

select  [location],[population],MAX([total_deaths]) as death_count
from [dbo].[covidDeaths]
where [continent] is not null
group by  [location],[population]
order by death_count desc

-- by continent 
-- max number of deaths by continent
select  [continent],MAX([total_deaths]) as death_count
from [dbo].[covidDeaths]
where [continent] is not null
group by  [continent]
order by death_count desc

-- another way with different numbers 
select  [location],MAX([total_deaths]) as death_count
from [dbo].[covidDeaths]
where [continent] is  null
group by  [location]
order by death_count desc

select  [location],SUM(cast([new_deaths] as int)) as death_count
from [dbo].[covidDeaths]
where [continent] is  null and location not in ('World','European Union','International') and location not like ,'%income%'
group by  [location]
order by death_count desc

-- global daily death rate 

select date , sum([new_cases]) as total_cases, sum(cast([new_deaths] as int)) as total_deaths, sum(cast([new_deaths] as int))/ sum([new_cases])*100 as death_rate
from [dbo].[covidDeaths]
where [continent] is not null
group by  date 
order by death_rate desc


-- accmulated number of vaccinated people by location/country 

with cte (date,location,continent,population,new_vaccinations,total_vacc) as (
select d.date,d.location,d.continent,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as total_vacc
from [dbo].[covidDeaths] d join [dbo].[covidVaccination] v on d.date= v.date and d.location= v.location
where d.[continent] is not null
--order by 2,1 
) 

-- last accmulated number of vaccinated people by location/country 
select *, (total_vacc/population)*100 
from cte

-- create view 

create view vaccinatedPercentage as (
select d.date,d.location,d.continent,d.population,v.new_vaccinations,sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as total_vacc
from [dbo].[covidDeaths] d join [dbo].[covidVaccination] v on d.date= v.date and d.location= v.location
where d.[continent] is not null
--order by 2,1 
)

select *
from vaccinatedPercentage
order by 2,1