select *
from PortafolioProject..CovidDeaths$
order by 3,4

--select *
--from PortafolioProject..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from PortafolioProject..CovidDeaths$
order by 1,2

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortafolioProject..CovidDeaths$
where location like '%state%'
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortafolioProject..CovidDeaths$
where location like '%state%'
order by 3,4
select location, population, max(total_cases) AS HighestInfectionCount,
max((total_cases/population))*100 as PercentagePpopulationInfected
from PortafolioProject..CovidDeaths$
where location like '%italy%'
Group By location, population
order by PercentagePpopulationInfected desc

select location,max(Cast (total_deaths as int)) AS TotalDeathCount
from PortafolioProject..CovidDeaths$
--where location like '%italy%'
WHERE Continent IS NOT NULL
Group By location
order by TotalDeathCount DESC

select location,max(Cast (total_deaths as int)) AS TotalDeathCount
from PortafolioProject..CovidDeaths$
--where location like '%italy%'
WHERE Continent IS NULL
Group By location
order by TotalDeathCount DESC

select sum(new_cases) as Totalcases, sum(Cast (new_deaths as int)) AS TotalNewDeaths, 
sum(Cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortafolioProject..CovidDeaths$
--where location like '%italy%'
WHERE Continent IS NULL
--Group By location
order by 1,2

with popvavac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ Dea
join CovidVaccinations$ Vac
on  Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvavac

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
population numeric,
new_vaccinations Numeric,
RollingPeopleVaccinated Numeric)
insert into #PercentPopulationVaccinated

select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ Dea
join CovidVaccinations$ Vac
on  Dea.location = Vac.location
and Dea.date = Vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


create view PercentPopulationVaccinated as
select Dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths$ Dea
join CovidVaccinations$ Vac
on  Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
--order by 2,3


