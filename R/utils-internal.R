
# ===== INTERNAL FUNCTIONS =====================================================

# NOTE:  Generally useful internal functions that are not associated with either
# NOTE:  'sts' or 'mts' objects.

# ----- .determineTimezone -----------------------------------------------------

.determineTimezone <- function(
  any_ts = NULL,
  startdate = NULL,
  timezone = NULL,
  verbose = TRUE
) {

  MazamaCoreUtils::stopIfNull(any_ts)

  # Timezone determination precedence assumes that if you are passing in
  # POSIXct times then you know what you are doing.
  #   1) get timezone from startdate if it is POSIXct
  #   2) use passed in timezone
  #   3) get timezone from any_ts

  if ( lubridate::is.POSIXt(startdate) ) {

    timezone <- lubridate::tz(startdate)

  } else if ( !is.null(timezone) ) {

    # Do nothing

  } else {

    # Handle multiple timezones in 'any_ts'
    timezoneCount <- length(unique(any_ts$meta$timezone))

    # Use table(timezone) to find the most common one
    if ( timezoneCount > 1 ) {
      timezoneTable <- sort(table(any_ts$meta$timezone), decreasing = TRUE)
      timezone <- names(timezoneTable)[1]
      if ( verbose ) {
        warning(sprintf(
          "Found %d timezones. Only %s will be used.",
          timezoneCount,
          timezone
        ))
      }
    } else {
      timezone <- any_ts$meta$timezone[1]
    }

  }

  if ( !timezone %in% OlsonNames() )
    stop(sprintf("timezone '%s' is not a valid Olson timezone", timezone))

  return(timezone)

}


