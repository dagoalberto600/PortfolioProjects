Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

----Select *
------From PortfolioProject..CovidDeaths
------order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

--Percentage of death rate Covid in Costa Rica
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%costa rica'
order by 1,2

--Percentage of population got Covid in Costa Rica

Select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where location like '%costa rica%'
order by 1,2

-- Countries with the Highest Infection Rate comparted to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where location like '%Germany%'
Group by Location, Population
order by PercentPopulationInfected desc

-- instead of converting it to "int", you will need to convert to "bigint"

--Countries with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Germany%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--By continent

Select continent, Max(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Germany%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Germany%'
Where continent is not null
--Group By date
order by 1,2


--Total amount of people in the world Vaccinated

--USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--View to store data
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3