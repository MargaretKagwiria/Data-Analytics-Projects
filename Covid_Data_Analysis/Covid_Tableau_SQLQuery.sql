-- Number of cases and deaths in the world
SELECT SUM(new_cases) AS Total_Cases,
	SUM(CAST(new_deaths AS int)) AS Total_Deaths,
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL

-- Number of cases and deaths per continent
SELECT location AS Continent,
	SUM(new_cases) AS Total_Cases,
	SUM(CAST(new_deaths AS int)) AS Total_Deaths,
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NULL AND location not in ('World','European Union','International')
GROUP BY location
ORDER BY Total_Deaths DESC

-- Number of cases and deaths per country
SELECT location AS Country,
	SUM(new_cases) AS Total_Cases,
	SUM(CAST(new_deaths AS int)) AS Total_Deaths,
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Total_Deaths DESC

-- Maximum number of infections count per country
SELECT location AS Country,
	population AS Population,
	MAX(total_cases) AS Highest_Infection_Count,
	(MAX(total_cases)/population)*100 AS Infected_Population_Percentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_Population_Percentage DESC

-- Maximum number of infections count per country per day
SELECT location AS Country,
	population AS Population,
	date,
	MAX(total_cases) AS Highest_Infection_Count,
	(MAX(total_cases)/population)*100 AS Infected_Population_Percentage
FROM Covid_Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population,date
ORDER BY Infected_Population_Percentage DESC