/*
Covid 19 Data Exploration
Date range from 1st January 2020 to 15 November 2023.
Skills used: Joins, CTE's, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Looking at data from 1st January 2020 to 15 November 2023
-- We use WHERE continent is not NULL, because if you check in the excel sheet, some locations have the names of the continent in them, 
-- and continent column for such lines contains NULL
SELECT *
FROM DataExploration.dbo.cases_death_covid
WHERE continent is not NULL 

-- Converting data type of numeric columns from varchar to bigint
ALTER TABLE DataExploration.dbo.cases_death_covid
ALTER COLUMN total_cases bigint, total_deaths bigint, population bigint, people_fully_vaccinated bigint

-- Looking at total number of cases and deaths in the world as of 15.11.23. 
-- Creating cte to identify the total numbers of cases and deaths in each country as of 15.11.23.
-- And then summarize each country's numbers to get global numbers as of 15.11.23.
with cte as (
    SELECT Continent, Location, MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths
FROM DataExploration.dbo.cases_death_covid
WHERE continent is not NULL
GROUP By location, continent
)
select SUM(total_cases) as total_cases_world2023, SUM(total_deaths) as total_deaths_world2023, 
ROUND((CAST(SUM(total_deaths) as float)/SUM(total_cases)*100),3) as GlobalDeathPercentage
from cte

-- Looking at total cases and total death by continent as of 15.11.23.
with cte2 as (
    SELECT Continent, Location, population, MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths
FROM DataExploration.dbo.cases_death_covid
WHERE continent is not NULL
GROUP By location, continent,population
)
select continent, SUM(total_cases) as total_cases_continent, SUM(total_deaths) as total_deaths_continent
from cte2
GROUP BY continent
ORDER BY total_cases_continent DESC

-- Creating View to store data for later queries with total numbers of cases and deaths as of 15.11.23.
Create View total_statistics as SELECT Continent, Location, population, MAX(total_cases) as total_cases, 
MAX(total_deaths) as total_deaths
FROM DataExploration.dbo.cases_death_covid
WHERE continent is not NULL
GROUP By location, continent, population

-- Looking at daily values of PercentPopulationInfected, DeathPercentage, PercentPopulationVaccinated in the United Kingdom
SELECT location,date, population, total_cases,total_deaths,people_fully_vaccinated,
ROUND((CAST(total_cases as float)/population*100),2) as PercentPopulationInfected,
ROUND(CAST(total_deaths as float)/CAST(total_cases as float)*100,2) as DeathPercentage, 
ROUND((CAST(people_fully_vaccinated as float)/population)*100,2) as PercentPopulationVaccinated
from DataExploration.dbo.cases_death_covid
WHERE location = 'United Kingdom'
ORDER BY 1,2

-- Looking at the countries with highest infection rate compared to population
SELECT location,total_cases, population, ROUND((CAST(total_cases as float)/population*100),2) as PercentPopulationInfected
FROM  DataExploration.dbo.total_statistics
ORDER BY PercentPopulationInfected DESC

-- Looking at Countries with Highest Confirmed Cases Count per Population
SELECT Location, population, total_cases
FROM DataExploration.dbo.total_statistics
Order by total_cases DESC

-- Looking at Countries with Highest Death Count per Population
SELECT Location, population, total_deaths
FROM DataExploration.dbo.total_statistics
Order by total_deaths DESC

-- Looking at Countries with Highest Death Percent 
-- Shows Likelihood of dying if you contact covid in your country
SELECT location,total_cases,total_deaths, ROUND(CAST(total_deaths as float)/CAST(total_cases as float)*100,2) as DeathPercentage
from DataExploration.dbo.total_statistics
ORDER BY percent_deaths DESC 

-- Comparing DeathPercentage vs PercentPopulationVaccinated
SELECT total_statistics.location,total_statistics.population,total_cases,total_deaths, people_fully_vaccinated,
ROUND(CAST(total_deaths as float)/CAST(total_cases as float)*100,2) as DeathPercentage, 
ROUND((CAST(people_fully_vaccinated as float)/total_statistics.population)*100,2) as PercentPopulationVaccinated
from DataExploration.dbo.total_statistics
JOIN DataExploration.dbo.vaccination_statistics ON total_statistics.location=vaccination_statistics.location
ORDER BY percent_vaccinated DESC 
