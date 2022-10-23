create database sql_project;

select *
from sql_project..CovidDeathsData
order by 3,4;

--select *
--from sql_project..CovidVaccinationsData
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from sql_project..CovidDeathsData
order by 1,2;

--Looking at Total Cases vs Total Deaths
--The original data set has locations grouped on the basis of countries as well as entire continents. Hence, when we want to
--look at the statistics for just the countries we add this where clause to our script. This is because the continent column
--is left blank for the rows in the data set in which the location is an entire continent.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as cases_percentage
from sql_project..CovidDeathsData
where continent is not null
order by 1,2;


--Looking at Total Cases vs Population
select location, total_cases, population, (total_cases/population)*100 as infected_percentage
from sql_project..CovidDeathsData
where continent is not null
order by 1,2;


--Looking at countries with the highest infection rates when compared to their entire population
select location, population, max(total_cases) as max_cases,  max((total_cases/population))*100 as infected_percentage
from sql_project..CovidDeathsData
where continent is not null
group by location, population
order by infected_percentage desc;


--Looking at countries with the highest infection rates when compared to their entire population
--The total_deaths column is of type nvarchar, this will result in incorrect calculations. Hence, we cast this column to
--int data type.
select location, max(population) as max_population, max(cast(total_deaths as int)) as max_deaths, max((total_deaths/population))*100 as death_percentage
from sql_project..CovidDeathsData
where continent is not null
group by location
order by death_percentage desc;

--Looking at the same data as above but this time, we group by continents
select continent, max(population) as max_population, max(cast(total_deaths as int)) as max_deaths, max((total_deaths/population))*100 as death_percentage
from sql_project..CovidDeathsData
where continent is not null
group by continent
order by death_percentage desc;

--Global Numbers: total cases till date vs total deaths till date sorted according to date

--Why did we sum the new_cases instead of using the total_cases column? This is beacuse we want to group the data of all the 
--countries according to the date only. Since total case and deaths cannot be left out of agroup by or aggregation
--statement in cas ea group by clause is used, we will have to find an laternate column where we can use an aggregation
--function to achieve the same result. The columns in this case are new_cases and new_deaths.
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from sql_project..CovidDeathsData
where continent is not null
group by date
order by 1;

--Global (cases vs deaths)
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from sql_project..CovidDeathsData
where continent is not null;

--Looking at New Vaccinactions and Total Vaccinations with respect to population

--The partition function is used to sum the new_vaccinations for a specific loaction, if we donot use partition it will
--keep adding to the sum even after the loaction changes which will result in inaccurate calculations. Further, we also need 
--to group by both location and date since we want a rolling count which updates every day, if we donot group by date,
--it will show the same total vaccinations for each date in a given location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from sql_project..CovidDeathsData dea
join sql_project..CovidVaccinationsData vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


--Percentage of Population that has recieved at least one Covid Vaccine

--The calculation for this problem is basically (total_vaccinated/population)*100, however since total_vaccinated is a column
--we just created as part of the script and not a permanant one, we cannot use it to perform arithmetic calculations.
--In such a case, we have two options, either use CTE or use temp tables. I shall demonstrate both.

--Using CTE
with PopvsVac (continent,location, date, population, new_vaccinations, total_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccinated
from sql_project..CovidDeathsData dea
join sql_project..CovidVaccinationsData vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (total_vaccinated/population)*100 as vaccination_percentage
from PopvsVac;


--Using a Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccinated
from sql_project..CovidDeathsData dea
join sql_project..CovidVaccinationsData vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (total_vaccinated/Population)*100 as vaccination_percentage
from #PercentPopulationVaccinated;

--We could also use a view to run the same query. The only problem is that views are permanant i.e. they are stored in memory
--and we can query them later just like we query a normal table.
GO
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccinated
from sql_project..CovidDeathsData dea
join sql_project..CovidVaccinationsData vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
GO

select *, (total_vaccinated/Population)*100 as vaccination_percentage
from PercentPopulationVaccinated;




