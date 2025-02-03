SELECT *
FROM Covid19..CovidDeaths
ORDER BY 3,4

SELECT *
FROM Covid19..CovidVaccinations
ORDER BY 3,4

SELECT location,date,population,total_cases,new_cases,total_deaths
FROM Covid19..CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases VS Total Deaths
SELECT location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Percentage_Num_of_Deaths
FROM Covid19..CovidDeaths
ORDER BY Percentage_Num_of_Deaths DESC, location

-- Looking at Total Cases VS Population
SELECT location,date,population,total_cases,total_deaths,(total_cases/population)*100 AS Percentage_Num_of_cases
FROM Covid19..CovidDeaths

-- Looking for country with Highest Infection rate compared to population
SELECT 
    location, 
    population, 
    MAX(total_cases) AS Max_Cases, 
    MAX((total_cases / population) * 100) AS Percentage_Num_of_Cases
FROM Covid19..CovidDeaths
GROUP BY location, population
ORDER BY Percentage_Num_of_Cases DESC

--Showing Countries with Highest Death Count Per population
SELECT 
	location,
	MAX(CAST(total_deaths AS int)) AS Percentage_Num_of_Deaths
FROM Covid19..CovidDeaths
GROUP BY location
ORDER BY Percentage_Num_of_Deaths DESC

--Showing Continents with Highest Death Count
SELECT 
	Continent,
	MAX(CAST(total_deaths AS int)) AS Percentage_Num_of_Deaths
FROM Covid19..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY Percentage_Num_of_Deaths DESC

--Total Death Cases Across the World
SELECT
	SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS int)) AS Total_Deaths,SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS Deaths_per_Cases
FROM Covid19..CovidDeaths

--Looking at people in the world that are vaccinated each day
SELECT dea.location,dea.date,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS Total_People_Vaccinated
FROM Covid19..CovidDeaths dea
JOIN Covid19..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE new_vaccinations is not null
ORDER BY 1,2


--Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population,  
        vac.new_vaccinations, 
        SUM(CAST(vac.new_vaccinations AS BIGINT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM Covid19..CovidDeaths dea
    JOIN Covid19..CovidVaccinations vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE vac.new_vaccinations IS NOT NULL
)
SELECT * FROM PopvsVac  -- You must use the CTE in a final SELECT
ORDER BY Location, Date;


-- Create Temporary Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population BIGINT,  
    New_Vaccinations BIGINT, 
    RollingPeopleVaccinated BIGINT  
);

-- Insert Data Into Temporary Table
INSERT INTO #PercentPopulationVaccinated
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        CAST(dea.population AS BIGINT),  -- Ensuring proper data type
        CAST(vac.new_vaccinations AS BIGINT), 
        SUM(CAST(vac.new_vaccinations AS BIGINT)) 
           OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM Covid19..CovidDeaths dea
    JOIN Covid19..CovidVaccinations vac
        ON dea.location = vac.location AND dea.date = vac.date
    WHERE vac.new_vaccinations IS NOT NULL;

-- Retrieve Data
SELECT * FROM #PercentPopulationVaccinated;


