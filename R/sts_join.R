#' @export
#' @importFrom rlang .data
#'
#' @title Join SingleTimeSeries objects along the time axis
#'
#' @param ... Any number of valid SingleTimeSeries \emph{sts} objects.
#'
#' @return A SingleTimeSeries \emph{sts} object.
#'
#' @description Create a merged timeseries using of any number of \emph{sts}
#' objects for a single sensor. If \emph{sts} objects are non-contiguous, the
#' resulting \emph{sts} will have gaps.
#'
#' @note An error is generated if the incoming \emph{sts} objects have
#' non-identical metadata.
#'
#' @examples
#' library(MazamaTimeSeries)
#'
#' aug01_08 <-
#'   example_sts %>%
#'   sts_filterDate(20180801, 20180808)
#'
#' aug15_22 <-
#'   example_sts %>%
#'   sts_filterDate(20180815, 20180822)
#'
#' aug01_22 <- sts_join(aug01_08, aug15_22)
#'
#' plot(aug01_22$data$datetime)

sts_join <- function(
  ...
) {

  # Accept any number of sts objects
  stsList <- list(...)

  # ----- Validate parameters --------------------------------------------------

  # ----- Join (concatenate) timeseries ----------------------------------------

  # NOTE:  If the first element is just a plain "list" of length 1, assume we are
  # NOTE:  being handed a list of sts objects rather than separate sts objects.
  if ( length(class(stsList[[1]])) == 1 && class(stsList[[1]]) == "list" ) {
    stsList <- stsList[[1]]
  }

  # Initialize empty lists
  dataList <- list()
  metaList <- list()

  stsCount <- length(stsList)

  for( i in seq_along(stsList) ) {

    # Guarantee proper 'datetime' ordering
    stsList[[i]]$data <-
      stsList[[i]]$data %>%
      dplyr::arrange(.data$datetime)

    # Check parameters
    if( !sts_isValid(stsList[[i]]) )
      stop("arguments contain a non-'sts' object")

    if( sts_isEmpty(stsList[[i]]) )
      stop("arguments contain an empty 'sts' object")

    metaList[[i]] <- stsList[[i]]$meta

    # NOTE:  Saved monthly sts objects have an extra UTC day at the beginning
    # NOTE:  and end to guarantee that we always have a complete month in the
    # NOTE:  local timezone. We trim things here so that we don't have
    # NOTE:  overlapping timesteps:

    if ( i == stsCount ) {
      # use stsList[[i]] end
      endtime <- range(stsList[[i]]$data$datetime, na.rm = TRUE)[2]
    } else {
      # use stsList[[i+1]] start and find the previous timestep
      endtime <- stsList[[i+1]]$data$datetime[1]
      index <- which(stsList[[i]]$data$datetime == endtime)
      if ( length(index) > 0 && index > 2 ) {
        endtime <- stsList[[i]]$data$datetime[index - 1]
      }
    }

    dataList[[i]] <-
      stsList[[i]]$data %>%
      dplyr::filter(.data$datetime <= endtime)

  } # END of loop over stsList

  # Check that meta matches
  if( length(unique(metaList)) != 1 )
    stop("'sts' object metadata are not identical")

  meta <- stsList[[1]]$meta
  data <- do.call(rbind, dataList) # duplicates removed below in sts_distinct()

  # ----- Create the MazamaSingleTimeseries (sts) object -----------------------

  sts <- list(meta = meta, data = data)
  class(sts) <- c("sts", class(sts))

  # ----- Return ---------------------------------------------------------------

  # Remove any duplicate data records
  sts <- sts_distinct(sts)

  return(invisible(sts))

}
