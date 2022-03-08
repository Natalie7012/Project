Select * From SQLProject..Covid_death
Go
Select * From SQLProject..Vaccinations
Go

Select C.location, C.date, C.population, C.total_cases, C.new_cases,C.total_deaths
from Covid_death C
Go
--Looking at Total cases and total deaths
--Show likelihood of dying if you contract covid in Viet Nam
Select C.location, C.total_cases, C.total_deaths, (total_deaths/total_cases)*100 as "death_Percentage" 
From SQLProject..Covid_death C
where location like '%Viet%'
Order By 1,2
Go
--Looking at Total cases and Population
--Show likelihood of positive in Viet Nam
Select C.location, C.total_cases, C.population, (total_cases/population)*100 as "Positive_Percentage" 
From SQLProject..Covid_death C
where location like '%Viet%'
Order By 1,2
Go

--Looking at countries with highest ifection rate compared to population
Select C.location, MAX(C.total_cases) as "highest case number", C.population, MAX((total_cases/population))*100 as "PercentPopulationInfected"
From SQLProject..Covid_death C
--where location like '%Viet%'
Group by location, population
Order By PercentPopulationInfected DESC
Go

--Showing countries with highest death case number
Select C.location,  Max(cast(total_deaths as int)) as "TotalDeathCount" 
From SQLProject..Covid_death C
Where continent is not null
Group by location
Order By TotalDeathCount DESC
Go

--Breaking things down by continent
--Showing continent with highest death count per population
Select C.location,  Max(cast(total_deaths as int)) as "TotalDeathCount" 
From SQLProject..Covid_death C
Where continent is null
Group by location
Order By TotalDeathCount DESC
Go

--Global number
Select sum(new_cases) as "Total_case", sum(CAST(new_deaths as int)) as "Total_Death", sum(new_cases)/sum(CAST(new_deaths as int))AS "DeathPercentage"
From Covid_death
where continent is not null
Go

--Looking at Total Population vs Vaccination
--Using CTE
With PopuvsVac (continent,date,population, new_vaccinations, Total_Vaccination)
as
(
Select Cov.continent, Cov.date,Cov.population, Vac.new_vaccinations, Sum(CAST(Vac.new_vaccinations as bigint)) over (Partition by Cov.location order by Cov.location, Cov.date) As Total_Vaccination
From Covid_death Cov
Join Vaccinations Vac On Cov.date = Vac.date And Cov.location = Vac.location
where Cov.continent is not null
)

Select *, (Total_Vaccination/population)*100 as "PercentageVaccinatedPeople"
From PopuvsVac
Go

--TEMP TABLE
DROP table #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	continent NVARCHAR(255),
	date datetime,
	population  numeric,
	new_vaccinations numeric,
	Total_Vaccination numeric
)
Insert into #PercentPopulationVaccinated
Select Cov.continent, Cov.date,Cov.population, Vac.new_vaccinations, Sum(CAST(Vac.new_vaccinations as bigint)) over (Partition by Cov.location order by Cov.location, Cov.date) As Total_Vaccination
From Covid_death Cov
Join Vaccinations Vac On Cov.date = Vac.date And Cov.location = Vac.location
where Cov.continent is not null

Select * 
,(Total_Vaccination/population)*100 as "PercentageVaccinatedPeople"
From #PercentPopulationVaccinated
Go
--VIEW total Population vs Vaccination
Create view PercentPopulationVaccinated as
Select Cov.continent, Cov.date,Cov.population, Vac.new_vaccinations, Sum(CAST(Vac.new_vaccinations as bigint)) over (Partition by Cov.location order by Cov.location, Cov.date) As Total_Vaccination
From Covid_death Cov
Join Vaccinations Vac On Cov.date = Vac.date And Cov.location = Vac.location
where Cov.continent is not null

Select * from PercentPopulationVaccinated