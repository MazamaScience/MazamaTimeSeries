[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/MazamaTimeSeries)](https://cran.r-project.org/package=MazamaTimeSeries)
[![Downloads](http://cranlogs.r-pkg.org/badges/MazamaTimeSeries)](https://cran.r-project.org/package=MazamaTimeSeries)
[![Build Status](https://travis-ci.org/MazamaScience/MazamaTimeSeries.svg?branch=master)](https://travis-ci.org/MazamaScience/MazamaTimeSeries)


# MazamaTimeSeries

```
Utility functions for working with environmental time series data from known 
locations. The compact data model is structured as a list with two dataframes. A 
'meta' dataframe contains spatial and measuring device metadata associated with 
deployments at known locations. A  'data' dataframe contains a 'datetime' column 
followed by measurements made at each time.
```

## Background

This package supports data management activities associated with environmental 
time series collected at fixed locations in space. The motivating fields include 
both air and water quality monitoring where fixed sensors report at regular time 
intervals.

## Data Model

The most compact format for time series data collected at fixed locations is a
list including two tables. **MazamaTimeSeries** stores time series measurements in a
`data` table where each row is a _record_ for a particular UTC timestamp and each 
column contains data measured by a single sensor (aka "device"). Any time invariant 
metadata associated with a sensor at a known location (aka a "device-deployment")
is stored in a separate `meta` table. A unique identifier connects the two tables. 
In the language of relational databases, this "normalizes" the database and can 
greatly reduce the memory and disk space needed to store the data

### Single Time Series

Time series data from a single environmental sensor typically consists of 
multiple parameters measured at successive times. This data is stored in an R 
list containing two dataframes. The package refers to this structure as an `sts` object
for **S**ingle**T**ime**S**eries:

`sts$meta` -- 1 row = unique device-deployment; cols = device/location metadata

`sts$data` -- rows = UTC time; cols = measured parameters (plus an additional `datetime` column)

`sts` objects can support the following types of time series data:

* stationary device-deployments only (no "mobile" sensors)
* single sensor only
* regular or irregular time axes
* multiple parameters
* multiple deployments of a single sensor are supported with multiple records in the `meta` dataframe

### Multiple Time Series

Working with timeseries data from multiple sensors is often challenging
because of the amount of memory required to store all the data from each 
sensor. However, a common situation is to have time series that share a 
common time axis -- _e.g._ hourly measurements. In this case, it is possible to
create single-parameter `data` dataframes that contain all data for all 
sensors for a single parameter of interest. In air quality applications, common
parameters of interest include PM2.5 and Ozone.

Multi-sensor, single-parameter time series data is 
stored in an R list with two dataframes. The package refers to this structure as 
an `mts` object for **M**ultiple**T**ime**S**eries:

`mts$meta` -- N rows = unique device-deployments; cols = sensor/location metadata

`mts$data` -- rows = UTC time; N cols = device-deployments (plus an additional `datetime` column)

A key feature of `mts` objects is the use of the `deviceDeploymentID` as a
"foreign key" that allows sensor `data` columns to be mapped onto the associated
spatial and sensor metadata in a `meta` row. The following will always be true:

```
identical(names(mts$data), c('datetime', mts$meta$deviceDeploymentID))
```

`mts` objects can support the following types of time series data:

* stationary device-deployments only (no "mobile" sensors)
* multiple sensors
* regular (shared) time axes only
* single parameter only

----

This project is supported by Mazama Science.

