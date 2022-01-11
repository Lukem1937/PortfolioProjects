SELECT location, date, total_cases, new_cases, total_deaths, population
FROM deaths 

--Total Cases vs Total Deaths
--Shows liklihood of dying from covid by country
SELECT location, date, total_cases, total_deaths, ((CAST(total_deaths AS float) / CAST(total_cases AS float))*100.00000) AS Mortailty_Perc
FROM deaths
WHERE location like "United S%" AND continent is not null

--Looking at Total Cases vs Population
SELECT location, date, total_cases, population, ((CAST(total_cases AS float) / CAST(population AS float))*100.00000) AS Infected_Perc
FROM deaths
WHERE location like "%United%" AND continent is not null

--Looking at countries with highest infection rate compared to population
SELECT location, population,MAX(total_cases) as MaxInfectedCount, ((CAST(total_cases AS float) / CAST(population AS float))*100.00000) AS Infected_Perc
FROM deaths
WHERE continent is not null
GROUP BY location
ORDER BY Infected_Perc desc
--WHERE location like "%United S%"

--Showing total death count per country
SELECT location, population,MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM deaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount desc

--Showing countries with highest death to population ratio
SELECT location, population,MAX(CAST(total_deaths AS INT)) AS DeathCount, ((CAST(total_deaths AS float) / CAST(population AS float))*100.00000) AS Death_Perc
FROM deaths
WHERE continent is not null
GROUP BY location
ORDER BY Death_Perc desc

--Breaking things down by Continent
SELECT location, continent, population,MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM deaths
WHERE continent is null AND (location LIKE "Asia" OR location LIKE "%North A%" OR location LIKE "%South A%" OR location LIKE "%Oc%" OR location LIKE "%Europe" OR location LIKE "%fr%")
GROUP BY location
ORDER BY DeathCount desc
--Incorrect alt. query for punch-in
SELECT location, continent, population,MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM deaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount desc

--Continents with highest death count by population
SELECT location, population,MAX(CAST(total_deaths AS INT)) AS DeathCount, ((CAST(total_deaths AS float) / CAST(population AS float))*100.00000) AS Death_Perc
FROM deaths
WHERE continent is null AND (location LIKE "Asia" OR location LIKE "%North A%" OR location LIKE "%South A%" OR location LIKE "%Oc%" OR location LIKE "%Europe" OR location LIKE "%fr%")
GROUP BY location
ORDER BY Death_Perc desc

--Creating View to store data for later visualizations
CREATE VIEW PercentPopVaccinated 
AS
SELECT deaths.continent, vaccine.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations AS int)) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Cmltv_Vccns
FROM deaths
JOIN vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
WHERE deaths.continent is not null
--ORDER BY 2, 3
SELECT *
FROM PercentPopVaccinated


--Global Numbers
--Daily global mortality percentage
SELECT date, SUM(new_cases) AS Dly_Cases, SUM(cast(new_deaths AS int)) AS Dly_Deaths, (SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)))*100.00000 AS Dly_Glbl_Mort_Perc
FROM deaths
WHERE continent is not null
GROUP BY date

--Cumulative global cases, deaths, and mortality percentage
SELECT location, date, total_cases, total_deaths, ((CAST(total_deaths AS float) / CAST(total_cases AS float))*100.00000) AS Cmltv_Glbl_Mort_Perc
FROM deaths
WHERE location like "Worl%" AND continent is null

--Vaccinations by country
--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Cmltv_Vccns)
AS(
SELECT deaths.continent, vaccine.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations AS int)) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Cmltv_Vccns
FROM deaths
JOIN vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
WHERE deaths.continent is not null
--ORDER BY 2, 3
)
Select *, (cast(Cmltv_Vccns AS float) / cast(population AS float))*100.00 AS Per_Pop_Vccntd
FROM PopvsVac
ORDER BY location, date

--Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
Cmltv_Vccns numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT deaths.continent, vaccine.location, deaths.date, deaths.population, vaccine.new_vaccinations, SUM(cast(vaccine.new_vaccinations AS int)) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS Cmltv_Vccns
FROM deaths
JOIN vaccine
    ON deaths.location = vaccine.location
    AND deaths.date = vaccine.date
WHERE deaths.continent is not null


Select *, (cast(Cmltv_Vccns AS float) / cast(population AS float))*100.00 AS Per_Pop_Vccntd
FROM PercentPopulationVaccinated