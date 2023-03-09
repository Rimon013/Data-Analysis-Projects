select * from Covids..CovidDeaths
order by 3,4

--select * from Covids..CovidVaccinations
--order by 3,4

Select Location , date, total_cases, new_cases, total_deaths, population
from Covids..CovidDeaths order by 1,2

--Looking for total cases vs total deaths

Select Location , date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Covids..CovidDeaths
where location like '%desh%'
order by 1,2

--Looking for total cases vs Population

Select Location , date, total_cases,population,(total_cases/population)*100 as Affected
from Covids..CovidDeaths
where continent is not null
--where location like '%desh%'
order by 1,2

--looking at countries with highest infection rate compare to population

Select Location , population, sum(total_cases) as highinfectioncount, MAX((total_cases/population))*100 as HighAffected
from Covids..CovidDeaths
--where location like '%desh%'
group by Location , population
order by location

--showing countries with highest death count per population and casting from char to int

select location, MAX(cast(total_deaths as int)) as Totaldeathcount from Covids..CovidDeaths
where continent is not null --because some locations have continent names and for them the continent value is null 
group by location
order by Totaldeathcount desc

--showing continents with the highest death count per population

select continent , max(cast(total_deaths as int)) as totaldeathcount from Covids..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc


Select continent ,sum(population) as totalpopulation, sum(total_cases) as highinfectioncount, sum(total_cases)/sum(population)*100 as HighAffected
from Covids..CovidDeaths
--where location like '%desh%'
where continent is not null
group by continent 
order by HighAffected desc

--global numbers for new cases and  newdeaths

select location ,  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths , 
sum(cast(new_deaths as int))/sum(new_cases)*100 as percemntage from Covids..CovidDeaths
where continent is not null
group by location
order by totaldeaths desc

--data exploration from covid vaccination

--total population vs vaccination
--use allias as column we need to use cte or temp table.
--in cte the number columns should be same as the number of columns in the select statement
with popvsvace (continent , location ,date,population ,new_vaccinations,rollingvaccinaation)
as
(
select dea.continent , dea.location ,dea.date,dea.population ,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as rollingvaccinaation

from Covids..CovidDeaths dea
join Covids..CovidVaccinations vac on dea.location = vac.location
									and dea.date =  vac.date
									where dea.continent is not null
									
--order by 2,3
)
select *,(rollingvaccinaation/population)*100 as vaccinationpercentage from popvsvace


--temp table

--in temp table the number columns should be same as 
--the number of columns in the select statement with same variable name
drop table if exists  #percentvaccination
create table #percentvaccination
(
 continent nvarchar(255) , 
 location nvarchar(255) ,
 date datetime,
 population numeric ,
 new_vaccinations numeric,
 rollingvaccinaation numeric

)

insert into #percentvaccination
select dea.continent , dea.location ,dea.date,dea.population ,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as rollingvaccinaation

from Covids..CovidDeaths dea
join Covids..CovidVaccinations vac on dea.location = vac.location
									and dea.date =  vac.date
									where dea.continent is not null

select *,(rollingvaccinaation/population)*100 as vaccinationpercentage 
from  #percentvaccination

--creating view

create view percentpopulationvaccinated as  

select dea.continent , dea.location ,dea.date,dea.population ,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as rollingvaccinaation

from Covids..CovidDeaths dea
join Covids..CovidVaccinations vac on dea.location = vac.location
									and dea.date =  vac.date
									where dea.continent is not null


with popvsvacc (location ,population,casescountry,casesvaccin )
as
(
select cd.location, cd.population, sum(cd.total_cases) as casescountry,sum(cast(cv.total_vaccinations as bigint)) as casesvaccin 
from Covids..CovidDeaths as cd join Covids..CovidVaccinations as cv on cd.location = cv.location and cd.date = cv.date
																	where cd.continent is not null
																	group by cd.location,cd.population
																	
)
select *,(casescountry/population)*100 as casepercentage,(casesvaccin /population)*100 as vaccinepercantage from popvsvacc




/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covids..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covids..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covids..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covids..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covids..CovidDeaths dea
Join Covids..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covids..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covids..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covids..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From Covids..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covids..CovidDeaths dea
Join Covids..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covids ..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


























