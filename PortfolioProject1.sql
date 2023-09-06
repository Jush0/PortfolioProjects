Select *
From ProjectPortfolio..CovidDeaths
order by 3,4

--select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- used cast to do operands on a varchar data type
-- Shows likelihood of dying if you contract covid in the Philippines

Select Location, date, total_cases,total_deaths, (cast(total_deaths as float) / NULLIF(cast(total_cases as float), 0))*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%Philippines'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population,total_cases, (cast(total_cases as float) / NULLIF(cast(population as float), 0))*100 as CovidPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max((cast(total_cases as float) / NULLIF(cast(population as float), 0)))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Shows TotalDeathCount per continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(cast(new_cases as int)) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)),0)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total cases, deaths and death percentage

Select SUM(cast(new_cases as int)) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)),0)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated

From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, location, date, Population, New_vaccinations, RollingPopulationVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null
)
Select *, CONVERT(float,(RollingPopulationVaccinated) / (CONVERT(float,Population)))*100
From PopvsVac

-- Temp table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPopulationVaccinated numeric,
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null
	order by 2,3

Select *, (RollingPopulationVaccinated/Population)*100 as RollingPercentVaccinated
From #PercentPopulationVaccinated



-- Creating view to store data for visualizations

-- Rolling Population Vaccinated

Create View RollingPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated

From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
	where dea.continent is not null

-- Total Cases, Deaths, Death Percentage

Create View TotalCasesDeaths as 
Select SUM(cast(new_cases as int)) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as float)) / NULLIF(SUM(cast(new_cases as float)),0)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null

-- Total Death Count per continent

Create View TotalDeathPerContinent as 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by continent

-- Countries Total Death 

Create view TotalDeathPerCountry as 
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
Group by Location

-- Infection rate of country's population

Create view CountryInfectionRate as
Select Location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max((cast(total_cases as float) / NULLIF(cast(population as float), 0)))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
Group by Location, Population

--Select view

Select *
From RollingPopulationVaccinated

Select *
From TotalCasesDeaths

Select *
From TotalDeathPerContinent

Select *
From TotalDeathPerCountry

Select *
From CountryInfectionRate