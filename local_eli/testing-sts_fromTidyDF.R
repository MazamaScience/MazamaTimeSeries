library(MazamaTimeSeries)
library(readr)

# ---------- FIRST DATA SET ---------
test_data1 <- readr::read_csv('./local_eli/AQView/provider_SCAQMD_small.csv')
names(test_data1)
#  [1] "County"               "Community"            "DataProvider"         "Site"                 "Latitude"            
# [6] "Longitude"            "Elevation"            "Instrument"           "MonitorId"            "ParameterId"         
# [11] "Parameter"            "MeasurementStartTime" "MeasuredValue"        "AdjustedValue"        "Units"               
# [16] "AdjustmentDesc"       "DataProviderFlag"     "LowerLimitCheck"      "UpperLimitCheck"      "RepeatingValueCheck" 
# [21] "SpikeCheck"           "PreliminaryQCResult"  "VerifiedByProvider"   "LastUpdateDate"   

unique(test_data1$Longitude)
# [1] -118.2268 -118.2199 -118.2060 -117.2741 -118.2007

# Multiple locations. Lets just filter by the first one for now
test_data1 <- test_data1 %>% dplyr::filter(Longitude == -118.2268)

unique(test_data1$Instrument)
# [1] "Thermo 42i"     "Thermo 43i-TLE"

# Multiple instruments. Lets filter by the first for now
test_data1 <- test_data1 %>% dplyr::filter(Instrument == "Thermo 42i")


# Missing deviceID, countryCode, stateCode, stateCode, timezone
test_data1$countryCode <- "US"
test_data1$stateCode <- "CA"
test_data1$timezone <- "America/Los_Angeles"

nameMapping1 <- list(Latitude = "latitude", Longitude = "longitude", MeasurementStartTime = "datetime", MonitorId = "deviceID")

test_data1_sts <- sts_fromTidyDF(test_data1, nameMapping1)

test_data1_sts %>% sts_extractMeta()
#   deviceDeploymentID deviceID locationID siteName longitude latitude elevation countryCode stateCode            timezone
#   cb98b110253b3b8b  temp id       <NA>     <NA> -118.2268  34.0664      <NA>          US        CA America/Los_Angeles
# County                       Community     DataProvider       Site Instrument  MonitorId              Parameter
# Los Angeles East Los Angeles, Boyle Heights South Coast AQMD Central LA Thermo 42i NO-0016730 Nitrogen Dioxide (NO2)
# AdjustedValue Units AdjustmentDesc DataProviderFlag LowerLimitCheck UpperLimitCheck RepeatingValueCheck SpikeCheck
#            NA   ppb             NA               NA            Pass            Pass                Pass       Pass
# PreliminaryQCResult VerifiedByProvider LastUpdateDate
#   Passed all checks                 No             NA

test_data1_sts %>% sts_extractData() %>% nrow()
# 1338

test_data2_sts %>% sts_extractData() %>% names()
# [1] "Elevation"     "ParameterId"   "datetime"      "MeasuredValue"

# Try a plot
library(openair)

# We have to parse the datetime first 
plot_data <- test_data1_sts %>% 
  sts_extractData() %>%
  dplyr::mutate(date = 
                  lubridate::parse_date_time2(datetime, "mdYHMS", tz = "America/Los_Angeles"))

openair::timePlot(plot_data, pollutant = "MeasuredValue")






# ---------- SECOND DATA SET ---------
test_data2 <- readr::read_csv('./local_eli/AQView/community_Muscoy_small.csv')
names(test_data2)
#  [1] "County"               "Community"            "DataProvider"         "Site"                 "Latitude"             "Longitude"           
# [7] "Elevation"            "Instrument"           "MonitorId"            "ParameterId"          "Parameter"            "MeasurementStartTime"
# [13] "MeasuredValue"        "AdjustedValue"        "Units"                "AdjustmentDesc"       "DataProviderFlag"     "LowerLimitCheck"     
# [19] "UpperLimitCheck"      "RepeatingValueCheck"  "SpikeCheck"           "PreliminaryQCResult"  "VerifiedByProvider"   "LastUpdateDate"  

unique(test_data2$Longitude)
# [1] -117.2741

# Only one location. perfect!

# Missing countryCode, stateCode, stateCode, timezone
test_data2$countryCode <- "US"
test_data2$stateCode <- "CA"
test_data2$timezone <- "America/Los_Angeles"

nameMapping2 <- list(Latitude = "latitude", Longitude = "longitude", MeasurementStartTime = "datetime", MonitorId = "deviceID")

test_data2_sts <- sts_fromTidyDF(test_data2, nameMapping2)

test_data2_sts %>% sts_extractMeta()
#   deviceDeploymentID  deviceID locationID siteName longitude latitude elevation countryCode stateCode            timezone         County
#   fb9152649f4a1f1a AE33-SNBO       <NA>     <NA> -117.2741  34.1067      <NA>          US        CA America/Los_Angeles San Bernardino
# Community     DataProvider           Site Instrument               Parameter AdjustedValue        Units AdjustmentDesc DataProviderFlag
# Muscoy, San Bernardino South Coast AQMD San Bernardino Magee AE33 Black Carbon PM2.5 (BC)            NA ng/m3 (25 C)             NA               NA
# LowerLimitCheck UpperLimitCheck RepeatingValueCheck SpikeCheck PreliminaryQCResult VerifiedByProvider LastUpdateDate
#            Pass            Pass                Pass       Pass   Passed all checks                 No             NA

test_data2_sts %>% sts_extractData() %>% nrow()
# 650

test_data2_sts %>% sts_extractData() %>% names()
# [1] "Elevation"     "ParameterId"   "datetime"      "MeasuredValue"

# ---------- THIRD DATA SET ---------
test_data3 <- readr::read_csv('./local_eli/AQView/county_LA_all.csv')
unique(test_data3$Parameter)
#  [1] "Carbon Monoxide (CO)"     "Nitric Oxide (NO)"        "Nitrogen Dioxide (NO2)"   "Oxides of Nitrogen (NOx)" "Ozone (O3)"              
# [6] "PM2.5 - Local Conditions" "PM10 - Local Conditions"  "Sulfur Dioxide (SO2)"     "Black Carbon PM2.5 (BC)"  "Total Particle Count"    
# [11] "Total NMOC"               "Methane (CH4)"       

# ------- MY NOTES ----------

# Some columns are going to the data df when they should be going to meta.
# For example, Elevation or ParameterId are numeric (so they automatically go to data)
# but are the same for each measurement so they should probably go to meta instead.


# In the third dataset, there are a bunch of parameters. Since that column is 
# of characters, it will be forced into meta but since it varies from measurement
# to measurement, it should probably go to data.