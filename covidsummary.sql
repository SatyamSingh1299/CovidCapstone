SELECT *
FROM covid..coviddeaths$
order by 3,4

--Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in United states
SELECT Location, date, total_cases, total_deaths, 
(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 AS deathPerc
FROM covid..coviddeaths$
WHERE Location like '%states%'
order by 1,2

--Looking at total cases vs population
SELECT Location, date, total_cases, population, 
(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))*100 AS Perc
FROM covid..coviddeaths$
WHERE Location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectedCount,
(CAST(MAX(total_cases) AS FLOAT) / CAST(MAX(population) AS FLOAT))*100 AS Perc
FROM covid..coviddeaths$
group by Location, population
order by Perc desc

--show countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid..coviddeaths$
WHERE continent is not NULL
group by Location
order by TotalDeathCount DESC

--Lets summarize by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid..coviddeaths$
WHERE continent is not NULL
group by continent
order by TotalDeathCount DESC

--global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPerc
FROM covid..coviddeaths$
where continent is not null
order by 1,2


--covid Vaccines joun coviddeaths
select *
FROM covid..coviddeaths$ d
JOIN covid..covidvaccines$ v
ON d.location=v.location
AND d.date=v.date

--population vs vaccinations
select d.continent, d.location,d.date, d.population, v.new_vaccinations
FROM covid..coviddeaths$ d
JOIN covid..covidvaccines$ v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent is not NULL
order by 2,3

--population vs vaccinations cumulative
select d.continent, d.location,d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over ( Partition by d.location ORDER by d.location,d.date) as CumulativeVacc
FROM covid..coviddeaths$ d
JOIN covid..covidvaccines$ v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent is not NULL
order by 2,3

--CTE
with PopvsVac (continent,location,date,population,new_vaccinations,CumulativeVacc)
as
(
select d.continent, d.location,d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over ( Partition by d.location ORDER by d.location,d.date) as CumulativeVacc
FROM covid..coviddeaths$ d
JOIN covid..covidvaccines$ v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent is not NULL
)
Select *,(CumulativeVacc/population)*100
From PopvsVac


CREATE VIEW percPopVacc as
select d.continent, d.location,d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) over ( Partition by d.location ORDER by d.location,d.date) as CumulativeVacc
FROM covid..coviddeaths$ d
JOIN covid..covidvaccines$ v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent is not NULL

SELECT * FROM percPopVacc
