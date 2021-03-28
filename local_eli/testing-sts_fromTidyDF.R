library(MazamaTimeSeries)
library(readr)

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
test_data1$deviceID <- "temp id"
test_data1$countryCode <- "US"
test_data1$stateCode <- "CA"
test_data1$timezone <- "America/Los_Angeles"

nameMapping1 <- list(Latitude = "latitude", Longitude = "longitude", MeasurementStartTime = "datetime")

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
# Try a plot
library(openair)

# We have to parse the datetime first 
plot_data <- test_data1_sts %>% 
  sts_extractData() %>%
  dplyr::mutate(date = 
                  lubridate::parse_date_time2(datetime, "mdYHMS", tz = "America/Los_Angeles"))

openair::timePlot(plot_data, pollutant = "MeasuredValue")
