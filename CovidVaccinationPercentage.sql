/*DISPLAYING THE DATA*/
SELECT*
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT*
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;

/*SELECT THE DATA WHICH WILL BE USED*/
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

/*LOOKING AT THE TOTAL DEATHS VS TOTAL CASES*/
SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases*100) AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

/*LOOKING AT THE TOTAL CASES VS POPULATION USING PERCENTAGE*/
SELECT location, date, total_cases, population, (total_cases/population*100) AS infection_count
FROM CovidDeaths
ORDER BY 1,2;

/*LOOKING AT THE COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION*/
SELECT location, population, MAX(total_cases) AS highest_infection_count,
	   MAX(total_cases/population*100) AS percent_population_infected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC;

/*COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION*/
SELECT location, MAX(CAST(total_deaths AS integer)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

/*CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION*/
SELECT continent, MAX(CAST(total_deaths AS integer)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

/*GLOBAL NUMBERS*/
SELECT SUM(new_cases) AS total_cases,SUM(CAST(new_deaths AS INT)) AS total_deaths,
	   SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

/*LOOKING FOR TOTAL POPULATION VACCINATED WITH CTE*/
WITH pop_vs_vac AS(
SELECT dea.continent, dea.location, dea.date,
	   dea.population, vac.new_vaccinations,
	   SUM(CAST (vac.new_vaccinations AS INT))
	   OVER (PARTITION BY dea.location
	   ORDER BY dea.location, dea.date) AS
	   rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT*,rolling_people_vaccinated/population*100
FROM pop_vs_vac;

/*TEMP TABLE*/
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,
	   dea.population, vac.new_vaccinations,
	   SUM(CAST (vac.new_vaccinations AS INT))
	   OVER (PARTITION BY dea.location
	   ORDER BY dea.location, dea.date) AS
	   rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT*,rolling_people_vaccinated/population*100
FROM #PercentPopulationVaccinated;

/*CREATING VIEW FOR VACCINATED POPULATION PERCENTAGE*/
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,
	   dea.population, vac.new_vaccinations,
	   SUM(CAST (vac.new_vaccinations AS INT))
	   OVER (PARTITION BY dea.location
	   ORDER BY dea.location, dea.date) AS
	   rolling_people_vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT*
FROM PercentPopulationVaccinated;
