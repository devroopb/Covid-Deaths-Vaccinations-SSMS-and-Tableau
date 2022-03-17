--Select the data to be used
--add where continent is not null to remove entries for 'World' and continents
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Order by 1, 2

--Looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in a certain country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Order by 1, 2

--Total cases vs Population
--Percentage of Population that has Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentInfected
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Order by 1, 2

--Countries with Highest Infection Rate compared to Population
--Used in Tableau
Select Location, MAX(cast(total_cases as bigint)) as TotalInfectionCount, population, (MAX(cast(total_cases as bigint))/population)*100 as PercentInfected
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Group by location, population
Order by 4 desc

--Countries with Highest Infection Rate compared to Population as per date
--Used in Tableau
Select Location, Population, date, MAX(cast(total_cases as bigint)) as TotalInfectionCount, (MAX(cast(total_cases as bigint))/population)*100 as PercentInfected
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Group by location, population, date
Order by 5 desc

--Countries with Highest Death Rate
Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount, population, (MAX(cast(total_deaths as bigint))/population)*100 as PercentDied
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Group by location, population
Order by 4 desc

--Death Count by continents
--Used in Tableau
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..['CovidDeaths$']
Where continent is null
	and location not like '%income%'
	and location <> 'International'
	and location <> 'World'
Group by location
Order by 2 desc

--Global Numbers
Select date, SUM(new_cases) as TotalNewCases,
	SUM(cast(new_deaths as bigint)) as TotalNewDeaths,
	(SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..['CovidDeaths$']
where continent is not null
Group by date
Order by 1, 2

--Percentage of people dead from covid worldwide as of 12/03/2022
--Used in Tableau
Select SUM(new_cases) as TotalNewCases,
	SUM(cast(new_deaths as bigint)) as TotalNewDeaths,
	(SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..['CovidDeaths$']
where continent is not null

--Use CTE
With PopVSVac( Continent, Location, Date, Population, New_Vaccinations, TotalVaccinated)
As 
(
--Total population vs vaccinations
--Vaccination Percentage over 100% because some people are doubly vaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (Partition by death.Location Order by death.Location, death.date) as TotalVaccinated
From PortfolioProject..['CovidDeaths$'] death Join PortfolioProject..['CovidVaccinations$'] vac
		On death.location = vac.location and death.date = vac.date
Where death.continent is not null
--Order by 2, 3
)
Select *, (TotalVaccinated/Population)*100 as PercentVaccinated
From PopVSVac

--Temp Table

Drop Table if exists #PercentVaccinated
Create Table #PercentVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccination bigint,
TotalVaccinated float
)

Insert Into #PercentVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (Partition by death.Location Order by death.Location, death.date) as TotalVaccinated
From PortfolioProject..['CovidDeaths$'] death Join PortfolioProject..['CovidVaccinations$'] vac
		On death.location = vac.location and death.date = vac.date
Where death.continent is not null

Select *, (TotalVaccinated/Population)*100 as PercentVaccinated
From #PercentVaccinated

--Creating View to store data for later visualisations
Create View PercentVaccinated as 
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) over (Partition by death.Location Order by death.Location, death.date) as TotalVaccinated
From PortfolioProject..['CovidDeaths$'] death Join PortfolioProject..['CovidVaccinations$'] vac
		On death.location = vac.location and death.date = vac.date
Where death.continent is not null

Select *
From PercentVaccinated