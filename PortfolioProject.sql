SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%States%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows ehat Percentage of Population got covid

SELECT location, date, Population,  total_cases, total_deaths, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Countries With Highest Infection  Rate Compared to Population

SELECT location, Population,  MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's Break Things Down by Continent

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(ISNULL(NULLIF(new_cases,0),1))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.location LIKE '%Nigeria%'
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%Nigeria%'
ORDER BY 2,3;

-- USE CTE

WITH PovsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PovsVac;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(25),
	Location nvarchar(25),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%Nigeria%'
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

-----------------------------------------------------------
NULLIF
Divide by zero

Declare @first INT,
		@secondvalue INT

set @first = 1
set @secondvalue = 0

SELECT
CASE
	WHEN @secondvalue = 0 THEN @first
	ELSE
	@first/@secondvalue
END

SELECT @first/ISNULL(NULLIF(@secondvalue,0),1)
-----------------------------------------------------------

-- Creating view to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;