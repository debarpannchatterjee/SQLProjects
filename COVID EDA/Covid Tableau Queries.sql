--Tableau Queries


--Query 1
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from sql_project..CovidDeathsData
where continent is not null;

--Query 2
select location, SUM(cast(new_deaths as bigint)) as total_death_count
from sql_project..CovidDeathsData
where continent is null 
and location not in ('World', 'European Union', 'International', 'High Income', 'Upper middle income', 'Lower middle income',
'Low income')
group by location
order by total_death_count desc

--Query 3
select location, population, max(total_cases) as max_cases,  max((total_cases/population))*100 as infected_percentage
from sql_project..CovidDeathsData
group by location, population
order by infected_percentage desc;

--Query 4
select location, population, date, max(total_cases) as max_cases,  max((total_cases/population))*100 as infected_percentage
from sql_project..CovidDeathsData
group by location, population, date
order by infected_percentage desc;