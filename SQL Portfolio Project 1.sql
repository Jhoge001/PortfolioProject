select * 
from PorfolioProject..CovidDeaths$
where continent is not null
order by 3,4

-- select * 
-- from PorfolioProject..CovidVaccinations$
-- order by 3,4

-- Selecting Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths 
-- Shows Percentage of dying from contracting covid in US

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at total cases vs Population
-- Showing what % of population has covid

select location, date, total_cases, population, (total_cases/population)*100 as Percent_infected
from PorfolioProject..CovidDeaths$
-- where location like '%states%'
order by 1,2

-- Looking at what countries have the highest infection rate compared to population

select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as Percent_infected
from PorfolioProject..CovidDeaths$
-- where location like '%states%'
group by location, population
order by Percent_infected desc

-- This will Show countries with the highest mortality rate per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- View the previous by continent rather than by country 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths$
-- where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Total as of last day of sample size

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths$
-- where location like '%states%'
where continent is not null
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated / population)*100 as PercentPopulationVaccinatedPerCountry
from PopvsVac

-- temp table approach

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated / population)*100 as PercentPopulationVaccinatedPerCountry
from #PercentPopulationVaccinated


-- Creating a view

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- testing view
 select *
 from PercentPopulationVaccinated