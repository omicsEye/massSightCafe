#' Launch massSightCafe Shiny App
#'
#' This function starts the massSightCafe Shiny application.
#' @export
brew_massSight <- function() {
  shiny::shinyAppDir(
    appDir = system.file("shinyapp", package = "massSightCafe"),
    options = list(launch.browser = TRUE)
  )
}
