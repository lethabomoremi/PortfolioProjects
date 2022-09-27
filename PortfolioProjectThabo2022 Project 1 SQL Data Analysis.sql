SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- COVID VACCINATION DATA EDA

SELECT location
      ,date 
	  ,total_cases
	  ,new_cases
	  ,total_deaths
	  ,population 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--- TOTAL CASES VS TOTAL DEATHS 
--- CALCULATING THE PERCENTAGE OF PEOPLE WHO DIED OF COVID-19
SELECT location
      ,date 
	  ,total_cases
	  ,total_deaths 
	  ,(total_deaths/total_cases) * 100 AS DeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%state%' AND continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT THE TOTAL CASES PER POPULATION 
-- THIS SHOWS WHAT PERCENTAGE OF POPULATION CONTRACTED COVID-19

SELECT location
      ,date 
	  ,total_cases
	  ,population
	  ,(total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location like '%state%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE 

SELECT Location
	  ,population
	  ,MAX(total_cases) AS HighestInfectionCount
	  ,MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestInfectionCount desc

-- SHOWING COUNTRIES WITH HIGHEST DEATHS PER POPULATION 

SELECT Location
	  ,MAX(cast(total_deaths as int)) AS TotalDeathCount
	  ,MAX((total_deaths/population)) * 100 AS PercentDiedPerPopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT 

SELECT continent
	  ,MAX(cast(total_deaths as int)) AS TotalDeathCount
	  ,MAX((total_deaths/population)) * 100 AS PercentDiedPerPopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent
	  ,MAX(cast(total_deaths as int)) AS TotalDeathCount
	  ,MAX((total_deaths/population)) * 100 AS PercentDiedPerPopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date 
	  ,SUM(new_cases) AS TotalNewCasesCount
	  ,SUM(CAST(new_deaths AS INT)) AS TotalNewDeathsCount
	  ,SUM(CAST(new_deaths AS INT))/ SUM(new_cases) *100 AS NewDeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location like '%state%'
GROUP BY Date
ORDER BY 1,2

-- OVERALL NUMBERS 

SELECT SUM(new_cases) AS TotalNewCasesCount
	  ,SUM(CAST(new_deaths AS INT)) AS TotalNewDeathsCount
	  ,SUM(CAST(new_deaths AS INT))/ SUM(new_cases) *100 AS NewDeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location like '%state%'
--GROUP BY Date
ORDER BY 1,2


SELECT * 
FROM PortfolioProject.dbo.CovidVaccinations


-- COMBINING TWO DATASETS TOGETHER

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations AS INT)) OVER
(partition by Dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vacc
ON Dea.location = Vacc.location 
AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL
ORDER BY 2, 3


---- USE CTE

WITH PopVsVacc ( continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)

as
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations AS INT)) OVER
(partition by Dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vacc
ON Dea.location = Vacc.location 
AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3

)

SELECT *, (Rolling_People_Vaccinated/population) * 100
FROM PopVsVacc


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations AS INT)) OVER
(partition by Dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vacc
ON Dea.location = Vacc.location 
AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (Rolling_People_Vaccinated/population) * 100
FROM #PercentPopulationVaccinated


--- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, SUM(CAST(Vacc.new_vaccinations AS INT)) OVER
(partition by Dea.location, dea.date) AS Rolling_People_Vaccinated
FROM PortfolioProject.dbo.CovidDeaths Dea
JOIN PortfolioProject.dbo.CovidVaccinations Vacc
ON Dea.location = Vacc.location 
AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *

FROM PercentPopulationVaccinated