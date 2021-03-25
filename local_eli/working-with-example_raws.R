library(MazamaTimeSeries)
library(RAWSmet)

# This document will compare MazamaTimeSeries' sts functions with RAWSmet's 
# functions for working with similar types of data

# ----- Our data ---------------------------------------------------------------

raws <- MazamaTimeSeries::example_raws

head(raws$data)
# A tibble: 6 x 12
# datetime            temperature humidity windSpeed windDirection maxGustSpeed maxGustDirection precipitation solarRadiation fuelMoisture
# <dttm>                    <dbl>    <dbl>     <dbl>         <dbl>        <dbl>            <dbl>         <dbl>          <dbl>        <dbl>
# 1 2002-07-18 03:00:00        31.1     13.5      3.58           279         6.26              286            NA            836           NA
# 2 2002-07-18 04:00:00        32.8     13.5      3.13           334         7.15               27            NA            901           NA
# 3 2002-07-18 05:00:00        33.3     13.5      4.47           315         7.15              307             0            924           NA
# 4 2002-07-18 06:00:00        35       13.5      3.13           282         6.71                4             0            899           NA
# 5 2002-07-18 07:00:00        36.1     13.5      2.24           250         5.81              290             0            819           NA
# 6 2002-07-18 08:00:00        36.1     13.5      2.68           287         5.81              280             0            698           NA
# … with 2 more variables: fuelTemperature <chr>, monitorType <chr>


# Add meta columns so 'raws' becomes valid sts
raws$meta$deviceDeploymentID <- "temp"
raws$meta$deviceID <- "temp"
raws$meta$locationID <- "temp"


# ----- Low level data manipulations -------------------------------------------

# --- Analogous functions ---
# sts_filter() = raws_filter()
# sts_filterDate() = raws_filterDate()
# sts_filterDatetime() = NA

# ----- _filter() -----

# one parameter
sts_filter(raws, temperature > 35) %>% 
  sts_extractData() %>% 
  nrow()
# [1] 2252

raws_filter(raws, temperature > 35) %>% 
  raws_extractData() %>% 
  nrow()
# [1] 2252

# multiple parameters
sts_filter(raws, temperature > 5, humidity > 50, precipitation == 13.970) %>% 
  sts_extractData() %>% 
  nrow()
# [1] 2

raws_filter(raws, temperature > 5, humidity > 50, precipitation == 13.970) %>% 
  raws_extractData() %>% 
  nrow()
# [1] 2

# ----- _filterDate() -----

filterDate_sts <- 
  sts_filterDate(raws, startdate = 20170101, enddate = 20180101) %>% 
  sts_extractData()

filterDate_sts$datetime %>% range(na.rm = TRUE)
# [1] "2017-01-01 08:00:00 UTC" "2017-12-31 15:00:00 UTC"

filterDate_raws <- 
  raws_filterDate(raws, startdate = 20170101, enddate = 20180101) %>% 
  raws_extractData()
filterDate_raws$datetime %>% range(na.rm = TRUE)
# [1] "2017-01-01 08:00:00 UTC" "2017-12-31 15:00:00 UTC"

# ----- sts_filterDatetime() -----
# No equivalent exists in RAWSmet 

filterDatetime_sts <- 
  sts_filterDatetime(raws, startdate = 20170101, enddate = 2017010206, timezone = "UTC") %>% 
  raws_extractData()

filterDatetime_sts$datetime %>% range(na.rm = TRUE)
# [1] "2017-01-01 00:00:00 UTC" "2017-01-02 05:00:00 UTC"

# It's a bit harder to get the same result
filterDatetime_raws <- raws %>% 
  sts_extractData() %>% 
  dplyr::filter(datetime >= lubridate::parse_date_time("20170101", "ymd") & 
                  datetime < lubridate::parse_date_time("2017010106", "ymdh"))

filterDatetime_raws$datetime %>% range(na.rm = TRUE)
# [1] "2017-01-01 00:00:00 UTC" "2017-01-01 05:00:00 UTC"