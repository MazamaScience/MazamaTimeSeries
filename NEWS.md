# MazamaTimeSeries 0.0.8

* Added `mts_collapse()`, `mts_distance()` and `mts_reorder()`.
* Renamed `mts_filter()` to `mts_filterData()` to be more explicit

# MazamaTimeSeries 0.0.7

* Added `timeInfo()` and supporting functions.
* Added `Carmel_Valley` example dataset.

# MazamaTimeSeries 0.0.6

* Added "location" utility functions.
* Removed dependency on **MazamaLocationUtils**
* Fixed bug in `~_filterDate()`.
* Removed `sts_from~()` functions.

# MazamaTimeSeries 0.0.5

* Added tests for all functions.
* Added `mts_combine()`.
* Adding `mts_filter~()` equivalents to `sts_filter~()` functions.
* Improved warning messages in `sts_isValid()` and `mts_isValid()`.

# MazamaTimeSeries 0.0.4

* Added functions for loading data into the `sts` format:
  - `sts_fromTidyDF()`
  - `sts_fromCSV()`

# MazamaTimeSeries 0.0.3

* Added basic unit tests for `sts` functions.
* Added the Developer Style Guide vignette

# MazamaTimeSeries 0.0.2

* Added basic utility functions for `sts` and `mts` objects.
* Added the following `sts` functions:
  - `sts_filter()`
  - `sts_filterDate()`
  - `sts_filterDatetime()`
  - `sts_join()`
  - `sts_toTidyDF()`
  - `sts_trimDate()`

# MazamaTimeSeries 0.0.1

* Initial setup.
