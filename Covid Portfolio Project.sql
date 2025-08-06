SELECT *
FROM world_covid_deaths
where continent is not null
order by 4, 5

-- SELECT *
-- FROM world_covid_vaccines
-- order by 3, 4
SELECT location, date, total_cases, new_cases, total_deaths, population
from world_covid_deaths
order by 1,2

-- looking at total cases vs. total deaths
-- shows chances of dying if contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from world_covid_deaths
order by 1,2

-- looking at total cases vs. population
-- shows percentage of popultaion that contacted covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as infectionpercent
from world_covid_deaths
order by 1,2

-- looking at countries with highest infection rate vs population

SELECT location, max(total_cases) as HigestInfectionCount, population, Max((total_cases/population))*100 as infectionpercentage
from world_covid_deaths
Group by location, population
order by infectionpercentage desc

SELECT location, max(total_cases) as HigestInfectionCount, population, Max((total_cases/population))*100 as infectionpercentage
from world_covid_deaths
Group by location, population
order by infectionpercentage 

-- showing countries with highest death count per population

SELECT location, MAX(total_deaths) as total_death_count
from world_covid_deaths
where continent is not null
GROUP BY location
ORDER BY total_death_count desc

-- LETS BREAK THINGS DOWN BY CONTINENT


-- showing continents with the highest death counts

SELECT continent, MAX(total_deaths) as total_death_count
from world_covid_deaths
where continent is not null
GROUP BY continent
ORDER BY total_death_count desc

Select location, MAX(total_deaths) as total_death_count
from world_covid_deaths
where continent is null
group by location
ORDER BY total_death_count desc

-- drill down click on continent shows all info per area.

-- Global Numbers

SELECT date, sum(new_cases) as total_cases, 
sum(new_deaths) as total_deaths, 
sum(new_deaths)/sum(new_cases)*100 as death_percentage 
-- total_cases, total_deaths, (total_death/total_cases) as death_percentage
from world_covid_deaths
where continent is not null and new_cases != 0
group by date
order by 1,2

-- looking at total popultation vs. vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated    
FROM world_covid_deaths dea
JOIN world_covid_vaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- use cte

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated    
FROM world_covid_deaths dea
JOIN world_covid_vaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null)
-- order by 2,3

select *, (rolling_people_vaccinated/population)*100 as pop_vaccination_percent
from popvsvac
order by 2, 3

-- temp table

create Table percent_population_vaccinated
(	continent varchar(255),
    location varchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    Rolling_people_vaccinated numeric)
    
Insert into percent_population_vaccinated
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated    
FROM world_covid_deaths dea
JOIN world_covid_vaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null)

select *, (rolling_people_vaccinated/population)*100 as pop_vaccination_percent
from percent_population_vaccinated

-- create view to store data for later visualization

percent_population_vaccinatedCreate view percent_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated    
FROM world_covid_deaths dea
JOIN world_covid_vaccines vac
	ON dea.location = vac.location
    and dea.date = vac.date
