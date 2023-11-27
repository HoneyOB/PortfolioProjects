SELECT *
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT*
from PortfolioProject_1..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows % of population w/ covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject_1..CovidDeaths
WHERE location like '%States%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Countries w/ Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries w/ Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(New_deaths) AS Total_Deaths, SUM(New_deaths)/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS Total_Cases, SUM(New_deaths) AS Total_Deaths, SUM(New_deaths)/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Total Population vs Vaccinations AS CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.New_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Rolling_Vaccinated
FROM PopvsVac

-- Total Population vs Vaccinations AS Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.New_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later Visualizations

CREATE VIEW GlobalDeathNumbers AS 
SELECT SUM(new_cases) AS Total_Cases, SUM(New_deaths) AS Total_Deaths, SUM(New_deaths)/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date


CREATE VIEW RollingVaccinatedPeople AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.New_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
JOIN PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

CREATE VIEW DeathsPerContinent AS
SELECT location, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount 
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC

CREATE VIEW InfectionRate AS	
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC