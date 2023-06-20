use PortfolioProject

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases Vs Totals Deaths'
-- shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
AND continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
Select Location, date,population, total_cases,(total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location,population, MAX(total_cases) as HighestInfectionCountry,MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Group by Location,population
order by InfectedPercentage desc

--Showing Countries with Highest Death Count per Population 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent

-- Showing  continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%state%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global number
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vacinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TempTable
DROP TABLE IF exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated