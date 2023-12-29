USE PortfolioProject;
SELECT * 
FROM dbo.covidvaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;


--SELECT * 
--FROM dbo.coviddeaths
--ORDER BY 3,4;

--SELECT Location, date, total_cases, new_cases, total_deaths,population
--FROM Coviddeaths
--ORDER BY 1,2;


-- CHOOSING PARTICULAR COUNTRY TO SEE THE STATISTICS  

--SELECT Location, date, total_cases, new_cases, total_deaths,population
--FROM Coviddeaths
--WHERE location Like '%india%'
--ORDER BY 1,2;


-- TOTAL CASES VS TOTAL DEATHS IN INDIA 
-- SHOWS LIKELIHOOD OF DYING IN THE COUNTRY


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Coviddeaths
WHERE location Like '%India%'
ORDER BY 1,2;

-- COMPARING WITH THE UNITED STATES' DEPTH PERCENTAGE 

--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM Coviddeaths
--WHERE location Like '%States%'
--ORDER BY 1,2;

--TOTAL CASES VS POPULATION  
-- SHOWS WHAT PERCENTAGE OF THE POPULATION GOT COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS positivePercentage
FROM Coviddeaths
ORDER BY 1,2;

-- LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO THE POPULATION 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS positivePercentage
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location ,Population 
ORDER BY positivePercentage desc;


-- SHOWING THE COUNTRIES HAVING HIGHEST DEATH COUNT PER POPULATION  

SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;



-- GROUPING BY CONTINENT   
-- SHOWING THE CONTINENT HAVING HIGHEST DEATH COUNT PER POPULATION  

SELECT Continent, MAX(total_deaths) AS TotalDeathCount 
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) As total_cases, SUM(new_deaths) AS total_deaths , (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2;

-- TOTAL DEATH PERCENTAGE ACROSS THE WORLD

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths , (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM Coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;




SELECT *
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vcc
	ON dea.location = vcc.location AND dea.date = vcc.date;


-- TOTAL POPULATION VS VACCINATION  
	
SELECT dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vcc
	ON dea.location = vcc.location AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



-- USING CTE 
WITH PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vcc
	ON dea.location = vcc.location AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


-- USING TEMP_TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vcc
	ON dea.location = vcc.location AND dea.date = vcc.date
--Where dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vcc
	ON dea.location = vcc.location AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated
