#' @export
#'
#' @name sts_isValid
#' @title Test \emph{sts} object for correct structure
#'
#' @param sts \emph{sts} object
#'
#' @description The \code{sts} is checked for the presence of core
#' \code{meta} and \code{data} columns.
#'
#' Core \code{meta} columns include:
#'
#' \itemize{
#'   \item{\code{deviceDeploymentID} -- unique identifier (see \pkg{MazmaLocationUtils})}
#'   \item{\code{deviceID} -- device identifier}
#'   \item{\code{locationID} -- location identifier (see \pkg{MazmaLocationUtils})}
#'   \item{\code{siteName} -- English language name}
#'   \item{\code{longitude} -- decimal degrees E}
#'   \item{\code{latitude} -- decimal degrees N}
#'   \item{\code{elevation} -- elevation of station in m}
#'   \item{\code{countryCode} -- ISO 3166-1 alpha-2}
#'   \item{\code{stateCode} -- ISO 3166-2 alpha-2}
#'   \item{\code{timezone} -- Olson time zone}
#' }
#'
#' Core \code{data} columns include:
#'
#' \itemize{
#'   \item{\code{datetime} -- measurement time (UTC)}
#' }
#'
#' @return \code{TRUE} if \code{sts} has the correct structure,
#' \code{FALSE} otherwise.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' sts_isValid(example_sts)
#'
sts_isValid <- function(
  sts = NULL
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(sts)

  # TODO:  Include class name check when this won't break AirSensor or RAWSmet
  # if ( !("sts" %in% class(sts)) ) return(FALSE)

  if ( !("meta" %in% names(sts)) ) return(FALSE)
  if ( !("data.frame" %in% class(sts$meta)) ) return(FALSE)

  if ( !("data" %in% names(sts)) ) return(FALSE)
  if ( !("data.frame" %in% class(sts$data)) ) return(FALSE)

  requiredNamesMeta <- c(
    'deviceDeploymentID', 'deviceID', 'locationID', 'siteName',
    'longitude', 'latitude', 'elevation',
    'countryCode', 'stateCode', 'timezone'
  )

  if ( !all(requiredNamesMeta %in% names(sts$meta)) ) {
    missingColumns <- setdiff(requiredNamesMeta, names(sts$meta))
    stop(sprintf(
      "sts$meta must contain columns for '%s'",
      paste(missingColumns, collapse = ", ")
    ))
  }

  requiredNamesData <- c(
    'datetime'
  )

  if ( !all(requiredNamesData %in% names(sts$data)) ) {
    missingColumns <- setdiff(requiredNamesData, names(sts$data))
    stop(sprintf(
      "sts$data must contain columns for '%s'",
      paste(missingColumns, collapse = ", ")
    ))
  }

  if ( !("POSIXct" %in% class(sts$data$datetime)) )
    stop("sts$data$datetime is not of class 'POSIXct'")

  if ( any(duplicated(sts$data$datetime)) )
    warning("Duplicate timesteps found in 'sts' object.")

  # Nothing failed so return TRUE
  return(TRUE)

}


#' @export
#'
#' @title Test for an empty \emph{sts} object
#'
#' @param sts \emph{sts} object
#' @return \code{TRUE} if no data exist in \code{sts}, \code{FALSE} otherwise.
#' @description Convenience function for \code{nrow(sts$data) == 0}.
#' This makes for more readable code in functions that need to test for this.
#' @examples
#' library(MazamaTimeSeries)
#'
#' sts_isEmpty(example_sts)
#'
sts_isEmpty <- function(sts) {

  MazamaCoreUtils::stopIfNull(sts)
  # NOTE:  Use minimal validation for improved speed
  if ( !'data' %in% names(sts) || !'data.frame' %in% class(sts$data) )
    stop("Not a valid 'sts' object.")

  return( nrow(sts$data) == 0 )

}


#' @importFrom rlang .data
#' @export
#'
#' @title Retain only distinct data records in sts$data
#'
#' @param sts \emph{sts} object
#'
#' @return A \emph{sts} object with no duplicated data records.
#'
#' @description Three successive steps are used to guarantee that the
#' \code{datetime} axis contains no repeated values:
#'
#' \enumerate{
#' \item{remove any duplicate records}
#' \item{guarantee that rows are in \code{datetime} order}
#' \item{average together fields for any remaining records that share the same
#' \code{datetime}}
#' }
#'
sts_distinct <- function(sts) {

  # NOTE:  Use minimal validation for improved speed
  if ( !'data' %in% names(sts) || !'data.frame' %in% class(sts$data) )
    stop("Not a valid 'sts' object.")

  sts$data <-
    sts$data %>%
    dplyr::distinct() %>%
    dplyr::arrange(.data$datetime) %>%
    .replaceRecordsWithDuplicateTimestamps()

  return( sts )

}


#' @title Extract dataframes from \emph{sts} objects
#'
#' @description
#' These functions are convenient wrappers for extracting the dataframes that
#' comprise a \emph{sts} object. These functions are designed to be useful when
#' manipulating data in a pipeline chain using \code{\%>\%}.
#'
#' Below is a table showing equivalent operations for each function.
#'
#' \tabular{ll}{
#'   \strong{Function} \tab \strong{Equivalent Operation}\cr
#'   \code{sts_extractData(sts)} \tab \code{sts$data}\cr
#'   \code{sts_extractMeta(sts)} \tab \code{sts$meta}
#' }
#'
#' @param sts \emph{sts} object to extract dataframe from.
#'
#' @return A dataframe from the given \emph{sts} object
#'
#' @name sts_extractDataFrame
#' @aliases sts_extractData sts_extractMeta
#'
NULL


#' @export
#' @rdname sts_extractDataFrame
#'
sts_extractData <- function(sts) {

  # NOTE:  Use minimal validation for improved speed
  if ( !'data' %in% names(sts) || !'data.frame' %in% class(sts$data) )
    stop("Not a valid 'sts' object.")

  return(sts$data)

}


#' @export
#' @rdname sts_extractDataFrame
#'
sts_extractMeta <- function(sts) {

  # NOTE:  Use minimal validation for improved speed
  if ( !'meta' %in% names(sts) || !'data.frame' %in% class(sts$meta) )
    stop("Not a valid 'sts' object.")

  return(sts$meta)

}


# ===== INTERNAL FUNCTIONS =====================================================

.replaceRecordsWithDuplicateTimestamps <- function(df) {

  # NOTE:  Some time series datasets can have multiple records with the same
  # NOTE:  'datetime'. This might occur when times are forced to the nearest
  # NOTE:  second, minute or hour. This assumes that the incoming df is
  # NOTE:  arranged by datetime and averages together all records that share the
  # NOTE:  same 'datetime'.
  if ( any(duplicated(df$datetime)) ) {

    # Find duplicate records
    duplicateIndices <- which(duplicated(df$datetime))
    for ( index in duplicateIndices ) {

      # Record immediately prior will be the other record with this timestamp
      replacementRecord <-
        dplyr::slice(df, (index-1):index) %>%
        dplyr::summarise_all(mean, na.rm = TRUE)

      # Replace the original record with the mean record
      df[(index-1),] <- replacementRecord

    }

    # Kep all the non-duplicate timestamp records
    df <- df[!duplicated(df$datetime),]

  }

  return(df)

}

