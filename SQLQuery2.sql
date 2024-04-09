select*
from death
order by 3,4
--select*
--from vaccination
--order by 3,4
--select data that we are going to be using
select location , date , total_cases,new_cases, total_deaths,population
from death
order by 1,2

--looking at total cases vs total deaths in a country
--it also shows likelihood of dying if you contract covid in your country
select location , date , total_cases, total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from death
where location like '%states%'
order by 1,2

--looking at thhe total cases vs the population
select location , date,total_cases,population,(total_cases/population)*100 as casesPercent
from death
where location like '%states%'
order by 1,2

--the highest infection rate compared to people
select location , population, max (total_cases) as highest_Cases ,max((total_cases/population)*100) as highest_cases_population
from death
--where location like '%states%'
group by location,population
order by highest_cases_population  desc

--showing the countries with the highest death count per population
--  AND LET'S BREAK THINGS DOWN BY CONTINENT
select location ,population, max(cast(total_deaths as int)) as MaxTotal_deaths,max((total_deaths/population)*100) as highestDeaths
from death
where continent is  NULL
group by location, population
order by highestDeaths desc
--SHOwing continents with the highest death count per population


--global numbers
select location, total_cases,total_deaths,max((total_deaths/total_cases)*100) as deaths_percent
from  [data analyst portfolio project]..death
where continent is not NULL
group by location, total_cases,total_deaths
order by deaths_percent desc 

select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from [data analyst portfolio project]..death
where continent is not null
--group by date
order by 1,2

-----------------------------------
select*
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
   

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not NULL
and dea.location like '%morocco%'
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location )
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not NULL
and dea.location like '%morocco%'
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)
as RoollingPeopleVaccinated,
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not NULL
and dea.location like '%morocco%'
order by 2,3

--now we want to show how many people are vaccinated 
--so when we use the previous code we wrote 
--(RoollingPeopleVaccinated/population)*100
--and we got an error
-- so we use a CTE 

with popVsVac (continent , location , date, population,new_vaccinations,RoollingPeopleVaccinated,TTL_Vac)
as(
--coping the previous code
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)
as RoollingPeopleVaccinated, SUM(cast(new_vaccinations as int)) over (partition by dea.location) as TTL_Vac
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not NULL
--and dea.location like '%morocco%'
--order by 2,3
)
--now we can add this(RoollingPeopleVaccinated/population)*100
select*,(RoollingPeopleVaccinated/population)*100  as PVac_Day
from popVsVac

--doing the same thing with a temp table
drop table if exists #PPV
create table #PPV
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric,
TTL_Vac numeric,
)

insert into #PPV 

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated, SUM(cast(new_vaccinations as int)) over (partition by dea.location) as TTL_Vac
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not NULL
and dea.location like '%morocco%'
order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PPV

--noww creating a view super easy
create view PPV as 
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated, SUM(cast(new_vaccinations as int)) over (partition by dea.location) as TTL_Vac
from [data analyst portfolio project]..death dea
join [data analyst portfolio project]..vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not NULL
and dea.location like '%morocco%'
--order by 2,3

--we have newss 
-- we can add constraint to a tableau like 
--if there s a tableau gives info for some people -we can 
--add mhm "add constraint ch_sexe check (sexe in('homme','femme')"
--if i want to desictive this constraint i code
--alter table
--nocheck constraint ch_sexe /check===> activer


