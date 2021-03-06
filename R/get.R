#' Download, read and format STATS19 data in one function.
#'
#' @section Details:
#' This function utilizes `dl_stats19` and `read_*` functions and retuns a
#' tibble, a sf object or a ppp object (according to the output_format
#' parameter). The file downloaded would be for a specific year (e.g 2017).
#'
#' As this function uses `dl_stats19` function, it can download
#' many MB of data so ensure you have a sufficient disk space.
#'
#' If `output_format = "sf"` or `output_format = "ppp"` then the output data is
#' transformed into an sf or ppp object using the format_sf()] or [format_ppp]
#' functions. See examples.
#'
#' @seealso [dl_stats19()]
#' @seealso [read_accidents()]
#' @inheritParams dl_stats19
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param output_format The default value is "tibble". Other possible values are
#'   \code{\link[sf]{st_as_sf}} object or \code{\link[spatstat]{ppp}} object.
#'   See details and examples
#' @param ... Other arguments that should be passed to [format_sf()] or
#'   [format_ppp()] functions. Read and run the examples.
#'
#' @export
#' @examples
#' \donttest{
#' # default tibble output
#' x = get_stats19(2009)
#' x = get_stats19(2017)
#'
#' # sf output
#' x_sf <- get_stats19(2017, output_format = "sf")
#'
#' # sf output with lonlat coordinates
#' x_sf = get_stats19(2017, output_format = "sf", lonlat = TRUE)
#' sf::st_crs(x_sf)
#'
#' if (requireNamespace("spatstat", quietly = TRUE)) {
#' # ppp output
#' x_ppp = get_stats19(2017, output_format = "ppp")
#' spatstat::plot.ppp(x_ppp, use.marks = FALSE)
#'
#' # We can use the window parameter of format_ppp function to filter only the
#' # events occurred in a specific area. For example we can create a new bbox
#' # of 5km around the city center of Leeds
#'
#' leeds_window <- spatstat::owin(
#' xrange = c(425046.1, 435046.1),
#' yrange = c(428577.2, 438577.2)
#' )
#'
#' leeds_ppp <- get_stats19(2017, output_format = "ppp", window = leeds_window)
#' spatstat::plot.ppp(leeds_ppp, use.marks = FALSE, clipwin = leeds_window)
#'
#' # or even more fancy examples where we subset all the events occurred in a
#' # pre-defined polygon area
#'
#' if (requireNamespace("osmdata", quietly = TRUE)) {
#' # greater_london_sf_polygon = osmdata::getbb(
#' # "Greater London, UK",
#' # format_out = "sf_polygon"
#' # )
#' # spatstat works only with planar coordinates
#' # greater_london_sf_polygon = sf::st_transform(greater_london_sf_polygon, 27700)
#' # then we extract the coordinates and create the window object.
#' # greater_london_polygon = sf::st_coordinates(greater_london_sf_polygon)[, c(1, 2)]
#' # greater_london_window <- spatstat::owin(poly = greater_london_polygon)
#'
#' # greater_london_ppp <- get_stats19(2017, output_format = "ppp", window = greater_london_window)
#' # spatstat::plot.ppp(greater_london_ppp, use.marks = FALSE, clipwin = greater_london_window)
#' }
#' }
#' }
get_stats19 = function(year = NULL,
                      type = "accidents",
                      data_dir = tempdir(),
                      file_name = NULL,
                      format = TRUE,
                      ask = FALSE,
                      output_format = "tibble",
                      ...) {
  if(!exists("type")) {
    stop("Type is required", call. = FALSE)
  }
  # download what the user wanted
  dl_stats19(year = year,
             type = type,
             data_dir = data_dir,
             file_name = file_name,
             ask = ask)
  read_in = NULL
  # what did the user want?
  if(grepl(type, "vehicles",  ignore.case = TRUE)){
    read_in = read_vehicles(
      year = year,
      data_dir = data_dir,
      format = format)
  } else if(grepl(type, "casualties", ignore.case = TRUE)) {
    read_in = read_casualties(
      year = year,
      data_dir = data_dir,
      format = format)
  } else { # inline with type = "accidents" by default
    read_in = read_accidents(
      year = year,
      data_dir = data_dir,
      format = format)
  }

  # transform read_in into the desired format
  if (output_format != "tibble") {
    read_in = switch(
      output_format,
      "sf" = format_sf(read_in, ...),
      "ppp" = format_ppp(read_in, ...)
    )
  }

  read_in
}




