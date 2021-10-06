#' @export
#' @importFrom rlang .data
#'
#' @title Date filtering for \emph{mts} objects
#'
#' @param mts \emph{mts} object.
#' @param startdate Desired start datetime (ISO 8601).
#' @param enddate Desired end datetime (ISO 8601).
#' @param timezone Olson timezone used to interpret dates.
#' @param unit Units used to determine time at end-of-day.
#' @param ceilingStart Logical instruction to apply
#'   \code{\link[lubridate]{ceiling_date}} to the \code{startdate} rather than
#'   \code{\link[lubridate]{floor_date}}
#' @param ceilingEnd Logical instruction to apply
#'   \code{\link[lubridate]{ceiling_date}} to the \code{enddate} rather than
#'   \code{\link[lubridate]{floor_date}}
#'
#' @description Subsets a \emph{mts} object by date. This function
#' always filters to day-boundaries. For sub-day filtering, use
#' \code{mts_filterDatetime()}.
#'
#' Dates can be anything that is understood by \code{MazamaCoreUtils::parseDatetime()}
#' including either of the following recommended formats:
#'
#' \itemize{
#' \item{\code{"YYYYmmdd"}}
#' \item{\code{"YYYY-mm-dd"}}
#' }
#'
#' Timezone determination precedence assumes that if you are passing in
#' \code{POSIXct} values then you know what you are doing.
#'
#' \enumerate{
#' \item{get timezone from \code{startdate} if it is \code{POSIXct}}
#' \item{use passed in \code{timezone}}
#' \item{get timezone from \code{mts}}
#' }
#'
#' @note The returned data will run from the beginning of \code{startdate} until
#' the \strong{beginning} of \code{enddate} -- \emph{i.e.} no values associated
#' with \code{enddate} will be returned. The exception being when
#' \code{enddate} is less than 24 hours after \code{startdate}. In that case, a
#' single day is returned.
#'
#' @return A subset of the given \emph{mts} object.
#'
#' @seealso \link{mts_filter}
#' @seealso \link{mts_filterDatetime}
#' @seealso \link{mts_filterMeta}
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' example_mts %>%
#'   mts_filterDate(startdate = 20180808, enddate = 20180815) %>%
#'   mts_extractData() %>%
#'   head()
#'

mts_filterDate <- function(
  mts = NULL,
  startdate = NULL,
  enddate = NULL,
  timezone = NULL,
  unit = "sec",
  ceilingStart = FALSE,
  ceilingEnd = FALSE
) {

  # ----- Validate parameters --------------------------------------------------

  # A little involved to catch the case where the user forgets to pass in 'mts'

  result <- try({
    if ( !mts_isValid(mts) )
      stop("First argument is not a valid 'mts' object.")
  }, silent = TRUE)

  if ( class(result) %in% "try-error" ) {
    err_msg <- geterrmessage()
    if ( stringr::str_detect(err_msg, "object .* not found") ) {
      stop(paste0(err_msg, "\n(Did you forget to pass in the 'mts' object?)"))
    }
  }

  if ( mts_isEmpty(mts) )
    stop("Parameter 'mts' has no data.")

  # Remove any duplicate data records
  mts <- mts_distinct(mts)

  if ( is.null(startdate) && !is.null(enddate) )
    stop("At least one of 'startdate' or 'enddate' must be specified")

  # Timezone determination precedence assumes that if you are passing in
  # POSIXct times then you know what you are doing.
  #   1) get timezone from startdate if it is POSIXct
  #   2) use passed in timezone
  #   3) get timezone from mts

  if ( lubridate::is.POSIXt(startdate) ) {

    timezone <- lubridate::tz(startdate)

  } else if ( !is.null(timezone) ) {

    # Do nothing

  } else {

    # Handle multiple timezones in 'mts'
    timezoneCount <- length(unique(mts$meta$timezone))

    # Use table(timezone) to find the most common one
    if ( timezoneCount > 1 ) {
      timezoneTable <- sort(table(mts$meta$timezone), decreasing = TRUE)
      timezone <- names(timezoneTable)[1]
      warning(sprintf(
        "Found %d timezones. Only %s will be used.",
        timezoneCount,
        timezone
      ))
    } else {
      timezone <- mts$meta$timezone[1]
    }

  }

  if ( !timezone %in% OlsonNames() )
    stop(sprintf("timezone '%s' is not a valid Olson timezone", timezone))

  # ----- Get the start and end times ------------------------------------------

  dateRange <- MazamaCoreUtils::dateRange(
    startdate = startdate,
    enddate = enddate,
    timezone = timezone,
    unit = "sec",
    ceilingStart = ceilingStart,
    ceilingEnd = ceilingEnd,
  )

  # ----- Subset the 'mts' object ----------------------------------------------

  # NOTE:  When processing lots of data automatically, it is best not to stop()
  # NOTE:  when no data exist for a requested date range. Instead, return a
  # NOTE:  valid 'mts' object with zero rows of data.

  if (dateRange[1] > mts$data$datetime[length(mts$data$datetime)] |
      dateRange[2] < mts$data$datetime[1]) {

    message(sprintf(
      "mts (%s) does not contain requested date range",
      mts$meta$siteName
    ))

    data <- mts$data[0,]

  } else {

    data <-
      mts$data %>%
      dplyr::filter(.data$datetime >= dateRange[1]) %>%
      dplyr::filter(.data$datetime < dateRange[2])

  }

  mts$data <- data

  # ----- Return ---------------------------------------------------------------

  return(mts)

}
