[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/MazamaTimeSeries)](https://cran.r-project.org/package=MazamaTimeSeries)
[![Downloads](http://cranlogs.r-pkg.org/badges/MazamaTimeSeries)](https://cran.r-project.org/package=MazamaTimeSeries)
[![Build Status](https://travis-ci.org/MazamaScience/MazamaTimeSeries.svg?branch=master)](https://travis-ci.org/MazamaScience/MazamaTimeSeries)


# MazamaTimeSeries

```
A suite of utility functions for working with environmental time
series data from known locations. The compact data model is structured as a 
list with two dataframes. A 'meta' dataframe contains spatial metadata
associated with known locations. A 'data' dataframe contains a 'datetime'
column followed by measurements made at each time.
```

## Background

This package is intended to be used in support of data management activities
associated with environmental time series collected at fixed locations in space.
The motivating fields include both air and water quality monitoring where fixed 
sensors report at regular time intervals.

## Data Model

The most compact format for time series data collected at fixed locations 
is a list including two tables. Time series measurements are stored in a `data`
table where each row is a _record_ for a particular UTC timestamp and each 
column contains data associated with that time. Any time invariant 
_spatial metadata_ associated with a location should be stored in a separate
`meta` table. A unique identifier connects the two tables. In the language of 
relational databases, this "normalizes" the database and can greatly reduce the 
memory and disk space needed to work with the data

### Single Time Series

Time series data from a single environmental sensor will typically consist of 
multiple parameters measured at each time. This data will be stored in an R 
list of two dataframes. The package refers to this structure as an `sts` object
for **S**ingle**T**ime**S**eries:

`sts$meta` -- 1 row = unique sensor-deployment; cols = sensor/location metadata

`sts$data` -- rows = UTC time; cols = measured parameters (plus an additional `datetime` column)

Each `sts` object can support the following types of time series data:

* stationary sensor deployments only (no "mobile" sensors)
* single instrument only
* regular and irregular time axes
* multiple parameters
* multiple deployments require multiple records in the `meta` dataframe

### Multiple Time Series

Working with timeseries data from multiple instruments is often challenging
because of the amount of memory required to store all the data from each 
instrument. However, a common situation is to have time series that share a 
common time axis -- _e.g._ hourly measurements. In this case, it is possible to
create single-parameter `data` dataframes that contain all data for all 
instruments for a parameter of interest. In air quality applications, common
parameters of interest include PM2.5 and Ozone.

Single-parameter time series data from mulitple environmental sensors will be 
stored in an R list of two dataframes. The package refers to this structure as 
an `mts` object for **M**ultiple**T**ime**S**eries:

`mts$meta` -- N rows = unique sensor-deployments; cols = sensor/location metadata

`mts$data` -- rows = UTC time; N cols = sensor-deployments (plus an additional `datetime` column)

Each `mts` object can support the following types of time series data:

* stationary sensor deployments only (no "mobile" sensors)
* multiple instruments
* regular (shared) time axes only
* single parameter

----

This project is supported by Mazama Science.

