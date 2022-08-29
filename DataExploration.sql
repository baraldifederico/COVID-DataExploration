select * from covidproject.coviddeath;
select * from covidproject.covidvaccinations;

/* CARICARE I DATABASE */

LOAD DATA local INFILE 'C:\\Users\\Federico Baraldi\\Desktop\\Corsi\\DataAnalysisProject\\AlexTheAnalyst\\CovidDeath.csv' 
INTO TABLE covidproject.coviddeath
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA local INFILE 'C:\\Users\\Federico Baraldi\\Desktop\\Corsi\\DataAnalysisProject\\AlexTheAnalyst\\CovidVaccinations.csv' 
INTO TABLE covidproject.covidvaccinations
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

/* MODIFICARE DATA TYPE DELLE COLONNE */

describe covidproject.coviddeath;

alter table covidproject.coviddeath
modify column population double(18,3),
modify column total_cases double (18,1),
modify column new_cases double (18,1),
modify column new_cases_smoothed double (18,3),
modify column total_deaths double (18,1),
modify column new_deaths double (18,1),
modify column new_deaths_smoothed double (18,3),
modify column total_cases_per_million double (18,3),
modify column new_cases_per_million double (18,3),
modify column new_cases_smoothed_per_million double (18,3),
modify column total_deaths_per_million double (18,3),
modify column new_deaths_per_million double (18,3),
modify column new_deaths_smoothed_per_million double (18,3),
modify column icu_patients double (18,3),
modify column icu_patients_per_million double (18,3),
modify column hosp_patients double (18,3),
modify column hosp_patients_per_million double (18,3),
modify column weekly_icu_admissions double (18,3),
modify column weekly_icu_admissions_per_million double (18,3),
modify column weekly_hosp_admissions double (18,3),
modify column weekly_hosp_admissions_per_million double (18,3),
modify column total_tests double (18,3);

alter table coviddeath add column data DATE;
update coviddeath
set data = str_to_date(date, '%d/%m/%Y');

describe covidproject.covidvaccinations;

alter table covidproject.covidvaccinations
modify column new_tests double(18,3),
modify column total_tests_per_thousand double (18,3),
modify column new_tests_per_thousand double (18,3),
modify column new_tests_smoothed double (18,3),
modify column new_tests_smoothed_per_thousand double (18,3),
modify column positive_rate double (18,3),
modify column tests_per_case double (18,3),
modify column total_vaccinations double (18,3),
modify column people_vaccinated double (18,3),
modify column people_fully_vaccinated double (18,3),
modify column total_boosters double (18,3),
modify column new_vaccinations double (18,3),
modify column new_vaccinations_smoothed double (18,3),
modify column total_vaccinations_per_hundred double (18,3),
modify column people_vaccinated_per_hundred double (18,3),
modify column people_fully_vaccinated_per_hundred double (18,3),
modify column total_boosters_per_hundred double (18,3),
modify column new_vaccinations_smoothed_per_million double (18,3),
modify column new_people_vaccinated_smoothed double (18,3),
modify column new_people_vaccinated_smoothed_per_hundred double (18,3),
modify column stringency_index double (18,3),
modify column population_density double (18,3),
modify column median_age double (18,3),
modify column aged_65_older double (18,3),
modify column aged_70_older double (18,3),
modify column gdp_per_capita double (18,3),
modify column extreme_poverty double (18,3),
modify column cardiovasc_death_rate double (18,3),
modify column diabetes_prevalence double (18,3),
modify column female_smokers double (18,3),
modify column male_smokers double (18,3),
modify column handwashing_facilities double (18,3),
modify column hospital_beds_per_thousand double (18,3),
modify column life_expectancy double (18,3),
modify column human_development_index double (18,3),
/*modify column excess_mortality_cumulative_absolute double (18,3),*/
modify column excess_mortality_cumulative double (18,3),
modify column excess_mortality double (18,3)
/*modify column excess_mortality_cumulative_per_million bigint (255)*/;

alter table covidvaccinations add column data DATE;
update covidvaccinations
set data = str_to_date(date, '%d/%m/%Y');


/* DATA EXPLORATION */

select * from coviddeath
order by 3,4;

select location, date, total_cases, new_cases, total_deaths 
from coviddeath
order by 1,2;

/* TOTAL CASE VS TOTAL DEATH */
/* SHOW LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY */

select location, data, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeath
where location like '%states%'
order by 1,2;

/* TOTAL CASE VS POPULATION */
/* SHOW POPULATION WITH COVID */

select location, data, population, total_cases, (total_cases/population)*100 as DeathPercentage
from coviddeath
where location like 'San Marino'
order by 1,2;

/* COUNTIES WITH HIGHEST INFECTION RATE COMPARED WITH POPULATION */

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from coviddeath
group by location, population
order by PercentPopulationInfected desc;

/* COUNTIES WITH HIGHEST death count per POPULATION */
select location, max(total_deaths) as TotalDeathCount
from coviddeath
where continent != ''
group by location
order by TotalDeathCount desc;


/* LET'S BREAK THINGS DOWN BY CONTINENT */
/* SHOW CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION */
select continent, max(total_deaths) as TotalDeathCount
from coviddeath
where continent != ''
group by continent
order by TotalDeathCount desc;

/* GLOBAL NUMBERS */

select data, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeath
where continent != ''
-- group by data
order by 1,2;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from coviddeath
where continent != ''
order by 1,2;

/* USE CTE */

with PopvsVac (Continent, Location, Data, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.data, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.data) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/Population*100
from coviddeath dea
join covidvaccinations vac
on dea.location=vac.location and dea.data=vac.data
where dea.continent != ''
-- order by 2,3
)
select *, RollingPeopleVaccinated/Population*100
from PopvsVac;

/* TEMP TABLE */
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
rollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.data, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.data) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/Population*100
from coviddeath dea
join covidvaccinations vac
on dea.location=vac.location and dea.data=vac.data
where dea.continent != '';
-- order by 2,3

/* CREATE VIEW */

create view PercentPopVaccinated as
select dea.continent, dea.location, dea.data, dea.population, vac.new_vaccinations,
 sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.data) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/Population*100
from coviddeath dea
join covidvaccinations vac
on dea.location=vac.location and dea.data=vac.data
where dea.continent != '';

select * from PercentPopVaccinated;



/*
Queries used for Power BI Project
*/

-- 1. 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases) as DeathPercentage
From coviddeath
-- Where location like '%states%'
where continent != ''
-- Group By date
order by 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- From PortfolioProject..CovidDeaths
-- Where location like '%states%'
-- where location = 'World'
-- Group By date
-- order by 1,2;

-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(new_deaths) as TotalDeathCount
From coviddeath
-- Where location like '%states%'
Where continent = ''
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeath
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4.
Select Location, Population, data, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeath
-- Where location like '%states%'
Group by Location, Population, data
order by PercentPopulationInfected desc
INTO OUTFILE 'C:\\Users\\Federico Baraldi\\Desktop\\Corsi\\DataAnalysisProject\\AlexTheAnalyst\\PowerBI 4.csv' 
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n';

-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out

-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


