SELECT 
	*
FROM	
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL AND continent != ''
ORDER BY
	3, 4;


-- SELECT THE DATA WE ARE GOING TO USE

SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL AND continent != ''
ORDER BY
	1,
	2

-- Looking at total cases vs total deaths

SELECT
    Location,
    CONVERT(DATE, date) as date,
    total_cases,
    total_deaths,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) = 0 THEN NULL  -- Manejar el caso de división por cero
        ELSE TRY_CAST(total_deaths AS FLOAT) / TRY_CAST(total_cases AS FLOAT) * 100
    END AS death_percentage
FROM
    PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL AND continent != ''
ORDER BY
    1,
    2

-- Looking at total cases vs total deaths in a specific country
-- Shows the likelihood of dying if you contract COVID in your country (Rough estimates)

SELECT
    Location,
    CONVERT(DATE, date) as date,
    total_cases,
    total_deaths,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) = 0 THEN NULL  -- Manejar el caso de división por cero
        ELSE TRY_CAST(total_deaths AS FLOAT) / TRY_CAST(total_cases AS FLOAT) * 100
    END AS death_percentage
FROM
    PortfolioProject..CovidDeaths
WHERE
	location like '%states'
AND
	continent IS NOT NULL AND continent != ''
ORDER BY
    1,
    2

-- Looking at the total cases vs the population
-- Shows the percentage of the population that has gotten COVID

SELECT
    Location,
    CONVERT(DATE, date) as date,
    population,
	total_cases,
    CASE
        WHEN TRY_CAST(population AS FLOAT) = 0 THEN NULL  -- Manejar el caso de división por cero
        ELSE TRY_CAST(total_cases AS FLOAT) / TRY_CAST(population AS FLOAT) * 100
    END AS covid_percentage
FROM
    PortfolioProject..CovidDeaths
WHERE
	location like '%states'
AND	
	continent IS NOT NULL AND continent != ''
ORDER BY
    1,
    2

-- Looking at countries with the highest infection rate compared to the population

SELECT
    Location,
    population,
    MAX(total_cases) as highest_infection_count,
    MAX(
        CASE
            WHEN TRY_CAST(population AS FLOAT) = 0 THEN NULL  -- Manejar el caso de división por cero
            ELSE TRY_CAST(total_cases AS FLOAT) / TRY_CAST(population AS FLOAT) * 100
        END
    ) AS Percentage_Population_Infected
FROM
    PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL AND continent != ''
GROUP BY
    Location, population
ORDER BY
    Percentage_Population_Infected Desc
    
-- Showing countries with highest death count per Population

SELECT
    Location,
	MAX(cast(total_deaths as int)) as Total_Death_Count
FROM
    PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL AND continent != ''
GROUP BY
    Location
ORDER BY
    Total_Death_Count Desc

-- Breaking things by continent

SELECT
    location,
	MAX(cast(total_deaths as int)) as total_death_count
FROM
    PortfolioProject..CovidDeaths
WHERE
	continent = ''
AND 
	location != 'High income'
AND 
	location != 'Upper middle income'
AND 
	location != 'Lower middle income'
AND 
	location != 'Low income'
GROUP BY
    location
ORDER BY
    total_death_count Desc

-- Showing the continents with the highest death count per population

SELECT
    continent,
	MAX(cast(total_deaths as int)) as total_death_count
FROM
    PortfolioProject..CovidDeaths
WHERE
	continent != ''
AND 
	location != 'High income'
AND 
	location != 'Upper middle income'
AND 
	location != 'Lower middle income'
AND 
	location != 'Low income'
GROUP BY
    continent
ORDER BY
    total_death_count Desc

-- looking at total population vs vaccination

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, ((RollingPeopleVaccinated)/(cast(Population as float)))*100 as asd
From PopvsVac


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
	

	
 
