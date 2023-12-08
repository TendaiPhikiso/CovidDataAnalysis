/*
Coronavirus Pandemic (COVID-19) Data Exploration | Data sourced from (Our world in data) --https://ourworldindata.org/covid-deaths

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * From CovidDeaths;

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2;

--Looking at the total cases vs total deaths | shows the likelihood of dying if you get covid in your country 

Select location, date, total_cases, total_deaths,
(CONVERT(DECIMAL(18,2), total_deaths)/ CONVERT(DECIMAL(18,2), total_cases)) *100 as DeathPercentage
From CovidDeaths
Where continent is not null 
Order by 1,2;

--Zambia 
Select location, date, total_cases, total_deaths,
(CONVERT(DECIMAL(18,2), total_deaths)/ CONVERT(DECIMAL(18,2), total_cases)) *100 as DeathPercentage
From CovidDeaths
Where location = 'Zambia' and continent is not null 
Order by 1,2;

--Looking at total cases vs population | shows what % of population got Covid

Select location, date,population, total_cases, 
(CONVERT(DECIMAL(18,2), total_cases)/population) *100 as PercentOfPopulationInfected
From CovidDeaths
Where location = 'Zambia'
Order by 1,2;

--Looking at countries with highest infection rate compared to population 

Select location,population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(DECIMAL(18,2), total_cases)/population)) *100 as PercentOfPopulationInfected
From CovidDeaths
Group by location, population
Order by PercentOfPopulationInfected desc;


--showing countries with highest death count 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not NULL
Group by location 
Order by TotalDeathCount desc;

---BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is NULL
Group by location
Order by TotalDeathCount desc;

--Visualisation point of view 
--Global Number | Total cases and total deaths 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidDeaths
Where continent is not null
Order by 1,2;

---Joining covid deaths table with covid Vaccinations table
Select * From CovidDeaths dea Join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date;


--Total no of people in the world that got vacinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3;

--Rolling count
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
order by 2,3;

-- How many people in the country are vaccinated
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (continent, location, date, population, new_vaccination,  RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null 

Select * From PercentPopulationVaccinated