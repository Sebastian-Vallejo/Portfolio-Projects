SELECT *
FROM   portfolioproject..coviddeaths
WHERE  continent IS NOT NULL
       AND continent != ''
ORDER  BY 3,
          4;  


-- SELECT THE DATA WE ARE GOING TO USE

SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM   portfolioproject..coviddeaths
WHERE  continent IS NOT NULL
       AND continent != ''
ORDER  BY 1,
          2  

-- Looking at total cases vs total deaths

 SELECT   location,
         CONVERT(DATE, date) AS date,
         total_cases,
         total_deaths,
         CASE
                  WHEN try_cast(total_cases  as float) = 0 THEN NULL -- Manejar el caso de división por cero
                  ELSE try_cast(total_deaths AS float) / try_cast(total_cases AS float) * 100
         END AS death_percentage
FROM     portfolioproject..coviddeaths
WHERE    continent IS NOT NULL
AND      continent != ''
ORDER BY 1,
         2 

-- Looking at total cases vs total deaths in a specific country
-- Shows the likelihood of dying if you contract COVID in your country (Rough estimates)

 SELECT   location,
         CONVERT(DATE, date) AS date,
         total_cases,
         total_deaths,
         CASE
                  WHEN try_cast(total_cases  as float) = 0 THEN NULL
                  ELSE try_cast(total_deaths AS float) / try_cast(total_cases AS float) * 100
         END AS death_percentage
FROM     portfolioproject..coviddeaths
WHERE    location LIKE '%states'
AND      continent IS NOT NULL
AND      continent != ''
ORDER BY 1,
         2 

-- Looking at the total cases vs the population
-- Shows the percentage of the population that has gotten COVID

 SELECT   location,
         CONVERT(DATE, date) AS date,
         population,
         total_cases,
         CASE
                  WHEN try_cast(population  as float) = 0 THEN NULL
                  ELSE try_cast(total_cases AS float) / try_cast(population AS float) * 100
         END AS covid_percentage
FROM     portfolioproject..coviddeaths
WHERE    location LIKE '%states'
AND      continent IS NOT NULL
AND      continent != ''
ORDER BY 1,
         2 

-- Looking at countries with the highest infection rate compared to the population

 SELECT   location,
         population,
         Max(total_cases) AS highest_infection_count,
         max(
         CASE
                  WHEN try_cast(population  as float) = 0 THEN NULL
                  ELSE try_cast(total_cases AS float) / try_cast(population AS float) * 100
         END ) AS percentage_population_infected
FROM     portfolioproject..coviddeaths
WHERE    continent IS NOT NULL
AND      continent != ''
GROUP BY location,
         population
ORDER BY percentage_population_infected DESC 

-- Showing countries with highest death count per Population

 SELECT location,
       Max(Cast(total_deaths AS INT)) AS Total_Death_Count
FROM   portfolioproject..coviddeaths
WHERE  continent IS NOT NULL
       AND continent != ''
GROUP  BY location
ORDER  BY total_death_count DESC  

-- Breaking things by continent

 SELECT location,
       Max(Cast(total_deaths AS INT)) AS total_death_count
FROM   portfolioproject..coviddeaths
WHERE  continent = ''
       AND location != 'High income'
       AND location != 'Upper middle income'
       AND location != 'Lower middle income'
       AND location != 'Low income'
GROUP  BY location
ORDER  BY total_death_count DESC  

-- Showing the continents with the highest death count per population

 SELECT continent,
       Max(Cast(total_deaths AS INT)) AS total_death_count
FROM   portfolioproject..coviddeaths
WHERE  continent != ''
       AND location != 'High income'
       AND location != 'Upper middle income'
       AND location != 'Lower middle income'
       AND location != 'Low income'
GROUP  BY continent
ORDER  BY total_death_count DESC  

-- looking at total population vs vaccination

 WITH popvsvac (continent, location, date, population, new_vaccinations,
     rollingpeoplevaccinated)
     AS (SELECT dea.continent,
                dea.location,
                dea.date,
                dea.population,
                vac.new_vaccinations,
                Sum(CONVERT(BIGINT, vac.new_vaccinations))
                  OVER (
                    partition BY dea.location
                    ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
         FROM   portfolioproject..coviddeaths dea
                JOIN portfolioproject..covidvaccinations vac
                  ON dea.location = vac.location
                     AND dea.date = vac.date
         WHERE  dea.continent IS NOT NULL)
SELECT *,
       ( ( rollingpeoplevaccinated ) / ( Cast(population AS FLOAT) ) ) * 100 AS
       asd
FROM   popvsvac  


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

 CREATE VIEW percentpopulationvaccinated
AS
  SELECT dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations,
         Sum(CONVERT(INT, vac.new_vaccinations))
           OVER (
             partition BY dea.location
             ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM   portfolioproject..coviddeaths dea
         JOIN portfolioproject..covidvaccinations vac
           ON dea.location = vac.location
              AND dea.date = vac.date
  WHERE  dea.continent IS NOT NULL  
	

	
 
