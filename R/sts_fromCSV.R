#' @export
#' @importFrom readr read_csv
#'
#' @title Load a CSV file into a SingleTimeSeries object
#'
#' @param file path or URL to the CSV file to load
#' @param nameMapping List mapping columns in the CSV file to the required columns 
#' specified below
#'
#' @description Loads a CSV file containing metadata and data from a single 
#' device into a SingleTimeSeries object.
#' 
#' The required metadata columns in the provided CSV are as follows:
#' \itemize{
#'   \item{\code{deviceID} -- device identifier (character, non-numeric)}
#'   \item{\code{longitude} -- decimal degrees E}
#'   \item{\code{latitude} -- decimal degrees N}
#'   \item{\code{countryCode} -- ISO 3166-1 alpha-2}
#'   \item{\code{stateCode} -- ISO 3166-2 alpha-2}
#'   \item{\code{timezone} -- Olson time zone}
#' }
#' 
#' Data stored in these columns will be put in the meta dataframe of the resulting 
#' \emph{sts} object.
#' 
#' The required data columns are as follows:
#' \itemize{
#'   \item{\code{datetime} -- measurement time (UTC)}
#' }
#' 
#' These columns along with any other numeric columns in the tidy dataframe will be 
#' put in the data dataframe of the resulting \emph{sts} object.
#'
#' @return A \emph{sts} object containing data and metadata from the provided CSV
#'
#' @examples
#'
#' library(MazamaTimeSeries)
#'
#' # TODO: write example for sts_fromCSV()
#'

sts_fromCSV <- function(
  file = NULL,
  nameMapping = NULL
) {
  
  # ----- Validate parameters --------------------------------------------------
  
  if(is.null(file))
    stop("Parameter 'file' must be provided.")
  
  # ----- Load CSV and convert -------------------------------------------------
 
  rawData <- readr::read_csv(file, col_types = readr::cols())
  
  sts <- sts_fromTidyDF(rawData, nameMapping)
  
  # ----- Return ---------------------------------------------------------------
  
  return(sts)
  
}
