select * 
from portifolio_projects..CovidDeaths
order by 3,4




--select * 
--from portifolio_projects..CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from portifolio_projects..CovidDeaths
order by 1,2


--looking at the total cases vs the total deaths 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_deaths
from portifolio_projects..CovidDeaths
where location like '%Egy%'
order by 1,2


-- looking at the total cases vs the population 

select location, date, population, total_cases,(total_cases/population)*100 as cases_percentage
from portifolio_projects..CovidDeaths
where location like '%Egy%'
order by 1,2


-- looking for countries with the highiest infection vs pop
select location, population, max(total_cases) as max_cases, max((total_cases/population))*100 as cases_percentage
from portifolio_projects..CovidDeaths
group by location, population
order by cases_percentage desc


-- countries with highest death counts 

select location, max(cast(total_deaths as int)) as max_total_deaths
from portifolio_projects..CovidDeaths
where continent is not null
group by location
order by max_total_deaths desc

--breaking things down by continent

select location, max(cast(total_deaths as int)) as max_total_deaths
from portifolio_projects..CovidDeaths
where continent is null
group by location
order by max_total_deaths desc


select sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as total_deaths, (sum(CAST(new_deaths as int))/sum(new_cases))*100 as death_percentage
from portifolio_projects..CovidDeaths
where continent is not null
--group by date
order by 1,2



-- total population vs total vaccination 

with popVSvac (continent, locccaction, date, population, new_vaccinations, rollingvacciantion)
as 
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingvacciantion
from portifolio_projects..CovidDeaths as dea
join portifolio_projects..CovidVaccinations as vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
)
select * , (rollingvacciantion/population)*100 as perent_vacinaated
from popVSvac
order by 2,3

-- temp table 

drop table if exists #PercentPopVacinated
create table #PercentPopVacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinaations numeric,
rollingvacciantion numeric 
)

insert into #PercentPopVacinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvacciantion
from portifolio_projects..CovidDeaths as dea
join portifolio_projects..CovidVaccinations as vac
	on dea.date = vac.date
	and dea.location = vac.location
--where dea.continent is not null

select *, (rollingvacciantion/population)*100 as percent_vacinated
from #PercentPopVacinated



--creating view to store data 
create view PercentPopVacinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvacciantion
from portifolio_projects..CovidDeaths as dea
join portifolio_projects..CovidVaccinations as vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null

select * 
from PercentPopVacinated
