SELECT *
FROM Portfolio_Project..covid_deaths

SELECT	date, 
		new_cases, 
		new_deaths
FROM Portfolio_Project..covid_deaths

SELECT	location, 
		population, 
		date, 
		new_cases, 
		total_cases, 
		new_deaths, 
		total_deaths
FROM covid_deaths
ORDER BY 1, 3


-- Getting to know the data types
-- the query if you're in the right database


SELECT COLUMN_NAME,
       DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH
FROM information_schema.columns
WHERE TABLE_NAME = 'covid_deaths'


-- Can change the databases you're quering off by adding the 'USE' function 


USE Portfolio_Project;
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_deaths';


-- Altering the data_type of the total_cases 

ALTER TABLE covid_deaths
ALTER COLUMN total_cases float NULL


-- Altering the data_type of the total_deaths

USE Portfolio_Project
ALTER TABLE covid_deaths
ALTER COLUMN total_deaths float NULL

ALTER TABLE covid_deaths
ALTER COLUMN total_cases float NULL


-- finding the percentage of the total cases compared to the total deaths

SELECT	location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 AS Death_percentage
FROM covid_deaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

-- Looking at the total cases vs the population percentage

USE Portfolio_Project
SELECT	location, 
		date, 
		population, 
		total_cases, 
		(total_cases/population)*100 AS covid_population_percentage
FROM covid_deaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

SELECT	location, 
		population, 
		MAX(total_cases) AS Max_Total_Cases, 
		MAX((total_cases/population))*100 AS covid_population_percentage
FROM covid_deaths
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY 4 DESC

-- showing countries with highest deaths

SELECT	location, 
		MAX(total_deaths) AS Max_Total_Deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- BREAKING IT DOWN BY CONTINENT

USE Portfolio_Project
SELECT	location, 
		MAX(total_deaths) AS Max_Total_Deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


SELECT continent, 
		MAX(total_deaths) AS Max_Total_Deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- GLOBAL NUMBERS OF TOTAL CASE, DEATHS AND DEATH PERCENTAGE

SELECT	date, 
		SUM(new_cases) AS total_cases, 
		SUM(new_deaths) AS total_deaths,
		SUM(new_deaths)/SUM(new_cases)*100 AS deaths_percentage
FROM covid_deaths
WHERE continent IS NOT NULL AND new_cases > 0
GROUP BY date
ORDER BY 1, 2

SELECT	SUM(new_cases) AS total_cases, 
		SUM(new_deaths) AS total_deaths,
		SUM(new_deaths)/SUM(new_cases)*100 AS deaths_percentage
FROM covid_deaths
WHERE continent IS NOT NULL AND new_cases > 0
ORDER BY 1, 2

--Looking at total population vs total vaccination

SELECT	dea.continent, 
		dea.location, 
		dea.date, 
		population, 
		new_vaccinations,
		SUM(CAST(new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 1,2,3

-- using CTE

WITH Pop_vs_vac (continent, location, date, population, new_vaccination, rolling_people_vaccinated)
AS
(SELECT	dea.continent, 
		dea.location, 
		dea.date, 
		population, 
		new_vaccinations,
		SUM(CAST(new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths AS dea
JOIN covid_vaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 1,2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS vaccinated_rate
FROM Pop_vs_vac
