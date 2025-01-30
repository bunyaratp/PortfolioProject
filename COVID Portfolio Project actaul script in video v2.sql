Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going be using

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in you country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
and location like '%Thailand%'
order by 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
Select Location, date, population,total_cases,  (total_deaths/population)*100 as PercentPopulationonInfected
From PortfolioProject..CovidDeaths
where location like '%Thailand%'
and continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases)as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationonInfected
From PortfolioProject..CovidDeaths
--where location like '%Thailand%'
Group by location, population
order by PercentPopulationonInfected desc

-- LET'S BREAK THONGS DOWN BY CONTINENT
--Showing Countries with Highest Death Count per Population

-- Showing continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Thailand%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--and location like '%Thailand%'
--group by date
order by 1,2

--Looking at Total Pupolation va Vaccinations
-- USE CTE
with PopvsVac (Continent, location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FRom PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FRom PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create View to store data for later visaualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FRom PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated