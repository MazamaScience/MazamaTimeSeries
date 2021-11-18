#' @export
#' @importFrom geodist geodist
#'
#' @title Calculate distances from \emph{mts} locations to a location of interest
#'
#' @param mts \emph{mts} object.
#' @param longitude Longitude of the location of interest.
#' @param latitude Latitude of the location of interest.
#' @param measure One of "haversine" "vincenty", "geodesic", or "cheap"
#'
#' @description
#' This function returns the distances (meters) between \code{mts} locations
#' and a location of interest. These distances can be used to create a
#' mask identifying monitors within a certain radius of the location of interest.
#'
#' @note The measure \code{"cheap"} may be used to speed things up depending on
#' the spatial scale being considered. Distances calculated with
#' \code{measure = "cheap"} will vary by a few meters compared with those
#' calculated using \code{measure = "geodesic"}.
#'
#' @return Vector of of distances (meters) named by \code{deviceDeploymentID}.
#'

mts_distance <- function(
  mts = NULL,
  longitude = NULL,
  latitude = NULL,
  measure = c("geodesic", "haversine", "vincenty", "cheap")
) {

  # ----- Validate parameters --------------------------------------------------

  if ( mts_isEmpty(mts) )
    stop("Parameter 'mts' has no data.")

  MazamaCoreUtils::validateLonLat(longitude, latitude)

  measure <- match.arg(measure)

  # ----- Calculate distances --------------------------------------------------

  distanceMatrix <-
    geodist::geodist(
      y = cbind(
        "x" = longitude,
        "y" = latitude
      ),
      x = cbind(
        "x" = mts$meta$longitude,
        "y" = mts$meta$latitude
      ),
      paired = FALSE,
      sequential = FALSE,
      pad = FALSE,
      measure = measure
    )

  # NOTE:  distanceMatrix is nrow(mts$meta) X 1

  distance <- distanceMatrix[,1]
  names(distance) <- mts$meta$monitorID

  # ----- Return ---------------------------------------------------------------

  return(distance)

}

# ===== DEBUG ==================================================================

if ( FALSE ) {

  library(MazamaTimeSeries)

  mts <- example_mts

  # Garfield Medical Center in LA
  longitude <- -118.12321
  latitude <- 34.06775

  measure <- "geodesic"

  mts_distance(
    mts = mts,
    longitude = longitude,
    latitude = latitude,
    measure = measure
  )

}
