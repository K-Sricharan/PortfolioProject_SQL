--PortFolio Project

--Use [PortFolio Project]

Select * from CovidDeaths$
Order by 3,4


--Select * from CovidVaccinations$
--Order by 3,4

--Select Data that we are going to use

Select Location,date,total_cases,new_cases, total_deaths,population
From CovidDeaths$
Order by 1,2

--Looking at total cases vs total deaths
--Shows the death_percentage in country

select  Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Percentage_death
From CovidDeaths$
Where location like '%India%'
order by 1,2

--Looking at total_cases VS total_population
--Shows what percentage of pupulation got covid

select  Location,date,population, total_cases, (total_cases/population)*100 AS Percentage_population_infected
From CovidDeaths$
Where location like '%India%'
order by 1,2

--looking at countries with highest infection rate

select  Location,population, MAX(total_cases) as highest_infection, Max((total_cases/population))*100 AS Percentage_population_infected
From CovidDeaths$
--Where location like '%India%'
Group by location,population
order by Percentage_population_infected desc

--Showing Countries with highest death count per population

select  Location,population, MAX(total_deaths) as highest_deaths, Max((total_deaths/population))*100 AS Percentage_population_death
From CovidDeaths$
--Where location like '%India%'
Group by location,population
order by Percentage_population_death desc


select  Location, MAX(cast(total_deaths as int)) as highest_deaths
From CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by location
order by highest_deaths desc


--Let's break things down by continent

select  continent, MAX(cast(total_deaths as int)) as highest_deaths
From CovidDeaths$
--Where location like '%India%'
Where continent is not null
Group by continent
order by highest_deaths desc

--this gives accurate results

select  location, MAX(cast(total_deaths as int)) as highest_deaths
From CovidDeaths$
--Where location like '%India%'
Where continent is null
Group by location
order by highest_deaths desc 


--Showing the continents with highest deaths count per population

Select continent,population, MAX(CAST(total_deaths as int)) as highest_deaths 
From CovidDeaths$
where population is not null
group by population
order by highest_deaths desc


--Global Numbers

select  date, Sum(new_cases), Sum(Cast(new_deaths as int)) --total_deaths, (total_deaths/total_cases)*100 AS Percentage_death
From CovidDeaths$
--Where location like '%India%'
where continent is not null
group by date	
order by 1,2

select  date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 AS Percentage_death
From CovidDeaths$
--Where location like '%India%'
where continent is not null
group by date	
order by 1,2


select   Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 AS Percentage_death
From CovidDeaths$
--Where location like '%India%'
where continent is not null
--group by date	
order by 1,2


--Covid vacinations
--Joins
--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
From CovidDeaths$ dea
	join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3


--In above query rollingpeoplevaccinated can't be used again in query for that we need to use CTE's
--USE CTE

with PopvsVac (continent,location,Date,population,new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
From CovidDeaths$ dea
	join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

select *,(rollingpeoplevaccinated/population)*100
from PopvsVac

--Temp table

Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
From CovidDeaths$ dea
	join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--Creating view to store data for later visualizations

Create View percentpopulationvaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
From CovidDeaths$ dea
	join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * from percentpopulationvaccinated