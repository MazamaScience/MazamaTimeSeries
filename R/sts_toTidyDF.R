#' @export
#' @importFrom utils object.size
#' @importFrom rlang .data
#'
#' @title Convert a SingleTimeSeries object to a tidy dataframe
#'
#' @param sts \emph{sts} object to convert.
#' @param metaColumns Spatial metadata to include in the tidy dataframe
#' @param sizeMax Maximum allowable size (in MB) for the resulting dataframe.
#'
#' @return Tidy dataframe containing data and metadata.
#'
#' @description Converts a \emph{sts} object to a single, tidy
#' dataframe containing all varaibles from \code{sts$data} along with
#' values from \code{sts$meta} as specified in \code{metaColumns}:
#'
#' Replicating time-invariant spatial metadata for every record greatly inflates
#' the size of the data but also makes it much more useful when working with the
#' \pkg{dplyr} and \code{ggplot2} packages.
#'
#' Tidy dataframes constructed in this manner be combined with
#' \code{dplyr::bind_rows()} and used to create multi-sensor plots.
#'
#' @examples
#' \dontrun{
#' library(MazamaTimeSeries)
#'
#' # A look at the 'sts' object
#' dplyr::glimpse(example_sts)
#'
#' # Now add default spatial metadata
#' tidyDF <- sts_toTidyDF(example_sts)
#' dplyr::glimpse(tidyDF)
#' }
#'

sts_toTidyDF <- function(
  sts = NULL,
  metaColumns = c('deviceDeploymentID', 'siteName', 'longitude', 'latitude'),
  sizeMax = 100
) {

  # ----- Validate parameters --------------------------------------------------

  MazamaCoreUtils::stopIfNull(sts)
  MazamaCoreUtils::stopIfNull(metaColumns)
  MazamaCoreUtils::stopIfNull(sizeMax)

  if ( !sts_isValid(sts) )
    stop("Parameter 'sts' is not a valid sts object.")

  if ( sts_isEmpty(sts) )
    stop("Parameter 'sts' is empty.")

  if ( !all(metaColumns %in% names(sts$meta)) ) {
    badColumns <- setdiff(metaColumns, sts$meta)
    stop(sprintf(
      "Columns in 'metaColumns' are not found in sts$meta: '%'",
      paste(badColumns, sep = ", ")
    ))
  }

  if ( !is.numeric(sizeMax) )
    stop("Parameter 'sizeMax' must be a numeric value.")

  # ----- Calculate size of added metadata -------------------------------------

  meta <- sts$meta[1, metaColumns]

  tidySize <-
    utils::object.size(meta) * nrow(sts$data) +
    utils::object.size(sts$data)

  if ( as.numeric(tidySize) > (sizeMax * 1e6) ) {
    stop(sprintf(
      "Resulting tidyDF will be %.1f MB.  Adjust 'metaColumns', 'sizeMax' or consider filtering by datetime.",
      (tidySize/1e6)
    ))
  }

  # ----- Create tidyDF --------------------------------------------------------

  tidyDF <- sts$data
  for ( column in metaColumns ) {
    tidyDF[[column]] <- sts$meta[[column]]
  }

  # ----- Return ---------------------------------------------------------------

  return(tidyDF)

}

