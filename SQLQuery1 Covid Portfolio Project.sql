USE PortfolioProject;
SELECT * 
FROM dbo.covidvaccinations
Where continent IS NOT NULL
ORDER BY 3,4;


--SELECT * 
--FROM dbo.coviddeaths
--ORDER BY 3,4;

--Select Location, date, total_cases, new_cases, total_deaths,population
--From Coviddeaths
--Order by 1,2;


-- Choosing Particular Country to see the Statistics 

--Select Location, date, total_cases, new_cases, total_deaths,population
--From Coviddeaths
--Where location Like '%india%'
--Order by 1,2;


-- Looking at Total Cases VS Total Deaths in India
-- Shows the Likelihood of dying in the country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Coviddeaths
Where location Like '%India%'
Order by 1,2;

-- Comparing with United States DeathPercentage 
--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--From Coviddeaths
--Where location Like '%States%'
--Order by 1,2;

--Total Cases VS Population 
-- Shows what percentage of population got Covid 
Select Location, date, total_cases, population, (total_cases/population)*100 AS positivePercentage
From Coviddeaths
--Where location Like '%India%'
Order by 1,2;

-- Looking at Countries with highest Infection rate compared to Population 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS positivePercentage
From Coviddeaths
Where continent IS NOT NULL
Group by location ,Population 
Order by positivePercentage desc;

--Showing the countries with Highest Death Count per population 
Select location, MAX(total_deaths) AS TotalDeathCount 
From CovidDeaths
Where continent IS NOT NULL
Group by location
Order by TotalDeathCount desc;



-- Grouping by Continent  
-- Showing the continent with Highest death count per population  
Select Continent, MAX(total_deaths) AS TotalDeathCount 
From CovidDeaths
Where Continent IS NOT NULL
Group by Continent
Order by TotalDeathCount desc;


-- Global Numbers

Select date, SUM(new_cases) As total_cases, SUM(new_deaths) AS total_deaths , (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
From Coviddeaths
Where continent is not null
Group by date 
Order by 1,2;

-- Total Death Percentage across the World

Select SUM(new_cases) As total_cases, SUM(new_deaths) AS total_deaths , (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
From Coviddeaths
Where continent is not null
Order by 1,2;




Select *
From CovidDeaths as dea
Join CovidVaccinations as vcc
	On dea.location = vcc.location and dea.date = vcc.date;


-- Total Population VS vaccination 
	
Select dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated,
From CovidDeaths as dea
Join CovidVaccinations as vcc
	On dea.location = vcc.location and dea.date = vcc.date
Where dea.continent is not null
Order by 2,3;



-- Using CTE 
With PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccinations as vcc
	On dea.location = vcc.location and dea.date = vcc.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac


-- Using Temp_Table

Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccinations as vcc
	On dea.location = vcc.location and dea.date = vcc.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization 

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vcc.new_vaccinations,
SUM(vcc.new_vaccinations) OVER (Partition By dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From CovidDeaths as dea
Join CovidVaccinations as vcc
	On dea.location = vcc.location and dea.date = vcc.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated
