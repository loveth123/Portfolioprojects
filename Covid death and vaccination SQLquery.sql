select *
from [Covid deaths and vaccination portfolio project]..['Covid deaths$']
where continent is not null
order by 3, 4

select *
from [Covid deaths and vaccination portfolio project]..['Covid vaccination data$']
where continent is not null
order by 3, 4


-- select data that i am using 

select location, date, total_cases, new_cases, total_deaths, population
from [Covid deaths and vaccination portfolio project]..['Covid deaths$']

order by 1,2


-- looking at total cases vs total deaths 
-- shows the likelihood of dying from covid by countries
select location, date, total_cases,total_deaths, convert(float, total_deaths) / convert(float, total_cases) * 100 as death_rate_percentage
from [Covid deaths and vaccination portfolio project]..['Covid deaths$']
where continent is not null
--where location like '%africa%'
order by 1,2

-- looking at the total cases vs the population
-- shows total population till date that got covid
select location, date, population, total_cases, convert(float, population) / convert(float, total_cases)*100 as total_population_percentage
from [Covid deaths and vaccination portfolio project]..['Covid deaths$']
where continent is not null
-- where location like '%africa%'
order by 1,2

-- country with the highest infection rate compared to the population
select location,continent, population,MAX(total_cases) as Highest_InfectionCount , Max(convert(float, population) / convert(float, total_cases))*100 as percentofpopulationinfected
From [Covid deaths and vaccination portfolio project]..['Covid deaths$']
where continent is not null
-- where location like '%africa%'
group by location, population , continent
order by percentofpopulationinfected desc


-- countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Covid deaths and vaccination portfolio project]..['Covid deaths$']
-- where location like '%africa%'
where continent is null
group by location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT 
--showing the continent with the highest death rate per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Covid deaths and vaccination portfolio project]..['Covid deaths$']
-- where location like '%africa%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,case 
when sum(new_cases) = 0 then 0 
else sum(new_deaths)/sum(new_cases)*100 end as death_percentages
from [Covid deaths and vaccination portfolio project]..['Covid deaths$']
where continent is not null
--where location like '%africa%'
--group by date
order by 1,2

-- by dates 
select date, sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,case 
when sum(new_cases) = 0 then 0 
else sum(new_deaths)/sum(new_cases)*100 end as death_percentages
from [Covid deaths and vaccination portfolio project]..['Covid deaths$']
where continent is not null
--where location like '%africa%'
group by date
order by 1,2


-- looking at the total vaccination and death data 

select * 
from [Covid deaths and vaccination portfolio project]..['Covid deaths$'] death
join [Covid deaths and vaccination portfolio project]..['Covid vaccination data$'] vac
on death.location = vac.location
and death.date = vac.date

-- looking at the total population vs vaccination globally
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
from [Covid deaths and vaccination portfolio project]..['Covid deaths$'] death
join [Covid deaths and vaccination portfolio project]..['Covid vaccination data$'] vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 2,3

--role count by location to keep adding up the vaccinations by each location and when it gets to a new location it starts a new count
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as countofpeoplevaccinated
from [Covid deaths and vaccination portfolio project]..['Covid deaths$'] death
join [Covid deaths and vaccination portfolio project]..['Covid vaccination data$'] vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 2,3

--total population vs vaccinations 
--using CTE to enable using new column to perform a query

with popvsvac (continent, location, date, population, new_vaccinations, countofpeoplevaccinated)
as(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as countofpeoplevaccinated
from [Covid deaths and vaccination portfolio project]..['Covid deaths$'] death
join [Covid deaths and vaccination portfolio project]..['Covid vaccination data$'] vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3
)
select * ,(countofpeoplevaccinated/population) *100 as totalpopvaccinated
from popvsvac

--creating view to store data for visualizations

create view totalpopvaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as countofpeoplevaccinated
from [Covid deaths and vaccination portfolio project]..['Covid deaths$'] death
join [Covid deaths and vaccination portfolio project]..['Covid vaccination data$'] vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3


select *
from totalpopvaccinated
