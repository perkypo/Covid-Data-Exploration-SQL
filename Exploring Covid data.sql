--Explore the data from the table

SELECT
	DISTINCT(location)
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
ORDER BY
	1;


--Look at total cases versus population

SELECT
	location AS Country, 
	date AS Date,
	population AS Population,
	total_cases AS Total_Cases,
	population AS Population,
	(total_cases/population)*100 AS Infected_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
ORDER BY
	1, 2;


--Look at total cases vs total deaths 

SELECT
	location AS Country, 
	date AS Date,
	population AS Population,
	total_deaths AS Total_Deaths, 
	total_cases AS Total_Cases, 
	(total_deaths/total_cases)*100 AS Death_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
ORDER BY
	1, 2;


-- Look at countries with highest infected rate

SELECT
	location AS Country, 
	MAX(total_cases/population)*100 AS Infected_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	Infected_Percent DESC;


--Look at countries with highest death rate

SELECT
	location AS Country,
	MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 AS Death_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	Death_Percent DESC;


-- Look at continents with highest infected rate

SELECT
	continent AS Continent, 
	MAX(total_cases/population)*100 AS Infected_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	Infected_Percent DESC;


--Look at continents with highest death rate

SELECT
	continent AS Continent,
	MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 AS Death_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	Death_Percent DESC;

--Look at the locations listed in Oceania(as continent)
--SELECT 
--	DISTINCT(location)
--FROM 
--	CovidPortfolioProject..['CovidDeaths']
--WHERE 
--	continent = 'Oceania'


--Global Numbers

SELECT
	date AS Date,
	SUM(CAST(new_deaths AS INT)) AS New_Deaths, 
	SUM(new_cases) AS New_Cases,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percent
FROM
	CovidPortfolioProject..['CovidDeaths']
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	Date;

	
--Look at Total populations vs vaccinations with CTE

WITH 
	PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated_Till_Date)
AS
	(SELECT
		death.continent AS Continent,
		death.location AS Location,
		death.date AS Date,
		death.population AS Population,
		--vaccine.new_tests,
		--death.new_cases,
		--death.new_deaths,
		vaccine.new_vaccinations AS New_Vaccinations,
		SUM(CONVERT(FLOAT, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS People_Vaccinated_Till_Date

	FROM
		CovidPortfolioProject..['CovidDeaths'] death 
		JOIN CovidPortfolioProject..['CovidVaccinations'] vaccine
		ON death.location = vaccine.location
		AND death.date = vaccine.date
	WHERE
		death.continent IS NOT NULL
	)
SELECT 
	*, (People_Vaccinated_Till_Date/Population) * 100 AS Vaccinated_Percent
FROM 
	PopulationVsVaccinations
ORDER BY
	2,3;



-- Temp Table


DROP TABLE IF EXISTS #PercentofPeopleVaccinated

CREATE 
	TABLE #PercentofPeopleVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	Vaccinated_Till_Date numeric
)


INSERT INTO
	#PercentofPeopleVaccinated
	SELECT
		death.continent,
		death.location,
		death.date,
		death.population,
		--vaccine.new_tests,
		--death.new_cases,
		--death.new_deaths,
		vaccine.new_vaccinations,
		SUM(CONVERT(FLOAT, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
	FROM
		CovidPortfolioProject..['CovidDeaths'] death 
		JOIN CovidPortfolioProject..['CovidVaccinations'] vaccine
		ON death.location = vaccine.location
		AND death.date = vaccine.date


SELECT 
	*, (Vaccinated_Till_Date/Population) * 100 AS Vaccinated_Percent
FROM 
	#PercentofPeopleVaccinated
ORDER BY
	2,3;


--CREATING VIEWS TO STORE DATA FOR VISUALIZATIONS

CREATE VIEW
	PercentOfPopulationVaccinated
AS
	SELECT
		death.continent AS Continent,
		death.location AS Location,
		death.date AS Date,
		death.population AS Population,
		--vaccine.new_tests,
		--death.new_cases,
		--death.new_deaths,
		vaccine.new_vaccinations AS New_Vaccinations,
		SUM(CONVERT(FLOAT, vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS People_Vaccinated_Till_Date
	FROM
		CovidPortfolioProject..['CovidDeaths'] death 
		JOIN CovidPortfolioProject..['CovidVaccinations'] vaccine
		ON death.location = vaccine.location
		AND death.date = vaccine.date
	WHERE
		death.continent IS NOT NULL
)

SELECT 
	*
FROM
	PercentOfPopulationVaccinated
