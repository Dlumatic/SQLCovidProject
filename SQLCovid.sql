
--Select *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Compare cases of Total vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

--Total Cases vs Population
--Show what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is NOT NULL
ORDER BY 1,2

--Look up countries with highest infection rate compared to population


Select Location, Population,  MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected desc

--Shoow countries with highest death count per population

--LET'S BREAK THINGS DOWN BY CONTINENT

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc



Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopvsVAC (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create View to store data for later visualization

use PortfolioProject

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
