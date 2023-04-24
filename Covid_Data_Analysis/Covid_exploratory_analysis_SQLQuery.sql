-- Preview the data
SELECT *
FROM Covid_Portfolio_Project..CovidDeaths

SELECT *
FROM Covid_Portfolio_Project..CovidVaccinations



-- Total cases vs Total deaths
-- Shows the likelihood of death after contracting Covid in Kenya
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	population,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE location = 'Kenya'
ORDER BY 1,2


-- Total cases vs Population
SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as CasePercentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE location = 'Kenya' AND total_cases>=1
ORDER BY 1,2


-- Countries with highest contraction rate vs their poulation
SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS CasePercentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY CasePercentage DESC


-- Countries with highest death count
SELECT 
	location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Check the death count based on continents
SELECT 
	location,
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Check out the Global Numbers
SELECT date,
	SUM(new_cases) AS DailyCases,
	SUM(CAST(new_deaths as int)) AS DailyDeaths,
	(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Check the total infections and deaths globally
SELECT SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths as int)) AS TotalDeaths,
	(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL


-- Create a TEMP Table to Compare Total Population with Vaccinations

DROP TABLE IF EXISTS #PopvsVacc
CREATE TABLE #PopvsVacc
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_People_Vaccinated numeric)

INSERT INTO #PopvsVacc
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Total_People_Vaccinated
FROM Covid_Portfolio_Project..CovidDeaths AS dea
JOIN Covid_Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,
	(Total_People_Vaccinated/Population)*100 AS Vaccinated_Population_Percentage
FROM #PopvsVacc


-- Create view to store data for later visualizations
USE Covid_Portfolio_Project
GO
CREATE VIEW Population_vs_Vaccinations AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS Total_People_Vaccinated
FROM Covid_Portfolio_Project..CovidDeaths AS dea
JOIN Covid_Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL