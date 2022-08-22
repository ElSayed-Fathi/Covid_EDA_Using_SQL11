use protofolio_project
-------------------------------EDA------------------------------------------
----------------------------------------------------------------------------------------------
select *
from CovidDeaths
where continent is not null
order by 3,4

----------------------------------------------------------------------------------------------
--select *
--from CovidVaccinations
--order by 3,4

----------------------------------------------------------------------------------------------
-- select data that will be using 

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

----------------------------------------------------------------------------------------------
-- looking at total cases and total deaths
-- shows lookhood of dying if you contract covid in your country 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths
where location like '%egypt%'
and continent is not null
order by 1,2

----------------------------------------------------------------------------------------------
-- looking at total vs population 
-- show whate percentage of population got covid in egypt
select location,date,population,total_cases,(total_cases/population)*100 as casespercentage
from CovidDeaths
where continent is not null

--where location like '%egypt%'
order by 1,2

----------------------------------------------------------------------------------------------
-- looking at countries with highest infection rate compared with population

select location,population,max(total_cases) as HighestinvectionCount,
max((total_cases/population))*100 as 
PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location,population
--where location like '%egypt%'
order by PercentPopulationInfected desc


----------------------------------------------------------------------------------------------
-- showing countries with highest death count per population

select location , MAX( cast (total_deaths as int )) as totaldeathcount
from CovidDeaths
where continent is not null
group by location
--where location like '%egypt%'
order by totaldeathcount desc


----------------------------------------------------------------------------------------------
-- let 's breake yhings down by continent 
--select continent , MAX( cast (total_deaths as int )) as totaldeathcount
--from CovidDeaths
--where continent is not  null
--group by continent
----where location like '%egypt%'
--order by totaldeathcount desc

----------------------------------------------------------------------------------------------
-- showing continentent with highest death count per population 
select continent , MAX( cast (total_deaths as int )) as totaldeathcount
from CovidDeaths
where continent is not  null
group by continent
--where location like '%egypt%'
order by totaldeathcount desc





----------------------------------------------------------------------------------------------
-- global numbers 
select date,sum(new_cases) as total_cases ,SUM(cast (new_deaths as int )) as total_death, 
sum(cast (new_deaths as int ))/SUM(new_cases) *100 as Deathpercentage
from CovidDeaths
--where location like '%egypt%'
where continent is not null
group by date 
order by 1,2

-------------------------------------------------------------------------------------
-- looking for total population vs total vaccination 

select dea.continent , dea.date,dea.location,dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date)
Rolling_people_vaccinatted
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--------------------------------------------------------------------------------------------------
-- use CTE 
with PopvsVac (continent,date,location,population,new_vaccinations,Rolling_people_vaccinatted)
as 
(
select dea.continent , dea.date,dea.location,dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) 
Rolling_people_vaccinatted
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

)
select *,(Rolling_people_vaccinatted/population)*100
from PopvsVac


-----------------------------------------------------------------------------------------

-- temp table 
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccinatted numeric


);

insert into  #percentpopulationvaccinated
select dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) 
Rolling_people_vaccinatted
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3 

select *,(Rolling_people_vaccinatted/population)*100
from #percentpopulationvaccinated


--------------------------------------------------------------------------------------------------
-- creating view to store data for later visualization 
create view percentpopulationvaccinated
as 
select dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location ,dea.date) 
Rolling_people_vaccinatted
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 

select *
from percentpopulationvaccinated







