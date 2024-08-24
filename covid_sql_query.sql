select *
from covid_deaths
where continent is not null
order by 3, 4

-- select *
-- from covidvaccinations
-- order by 3, 4

-- Select Data that we're going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where Location like '%States'
order by 1,2

-- Looking at Total Cases vs. Population
-- Show what % of population got Covid
select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from covid_deaths
where Location like '%Thai%'
order by 1,2

-- What country have the highest infection rate compared to poulation?
select Location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from covid_deaths
group by location, population
order by PercentagePopulationInfected desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
	
-- Showing continents with the highest death count per population
select 
	continent,
	MAX(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBER
select
	date,
	sum(new_cases) as totalcases,
	sum(new_deaths) as totaldeath,
	sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs. Vaccinations
select 
	dea.date,
	dea.continent,
	dea.location,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccineted
from covid_deaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccineted)
as (
select 
	dea.date,
	dea.continent,
	dea.location,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccineted
from covid_deaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *,
	(RollingPeopleVaccineted/population)*100
from PopvsVac

-- Temp Table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
	continent nvarchar(255),
	location varchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric
)
	
insert into PercentPopulationVaccinated
select 
	dea.date,
	dea.continent,
	dea.location,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccineted
from covid_deaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null

select *,
	(RollingPeopleVaccineted/population)*100
from PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select 
	dea.date,
	dea.continent,
	dea.location,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccineted
from covid_deaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3