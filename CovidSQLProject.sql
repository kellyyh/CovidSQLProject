
Select *
From CovidPortfolio..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From CovidPortfolio..CovidVax
--order by 3,4

-- select Data that I will be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolio..CovidDeaths
order by 1,2

-- Looking at Total Cases Vs. Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercetage
From CovidPortfolio..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases Vs. Population 
-- Shows what percentage of population got covid 
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 
Select Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationinfected
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationinfected desc

-- Looking at Countries with Highest Death Count per Population 
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING DOWN BY CONTINENT 

-- Looking at continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--  GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolio..CovidDeaths 
--Where location like '%states%'
where continent is not null
group by date
order by 1,2



-- Looking at Total Population vs. Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

 
--USE CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

--TEMP TABLE 

-- DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated 



-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVax vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Select *
--From PercentPopulationVaccinated




--QUERIES USED FOR TABLEAU PROJECT 

--#1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--#2
Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is null 
and Location not in ('World', 'European Union', 'International')
Group by Location
order by TotalDeathCount desc

--#3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--#4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc