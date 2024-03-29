library(devtools)
library(httr2)
library(jsonlite)
library(tibble)
library(purrr)
library(tidygeocoder)
library(usethis)
library(roxygen2)
library(usethis)
library(lubridate)
library(ggplot2)


#' Obtenir les prévisions météorologiques actualisées à partir de l'API.
#' Cette fonction récupère les prévisions météorologiques les plus récentes en utilisant les coordonnées GPS (latitude, longitude) spécifiées en entrée.
#'
#' @param latitude La latitude (numeric).
#' @param longitude La longitude (numeric).
#'
#' @return Un tibble contenant les prévisions météorologiques.
#'
#' @export
perform_request <- function(lat, lon) {
  url <- "https://api.open-meteo.com/v1/forecast"
  request(url) |>
    req_url_query(latitude=lat,longitude=lon, hourly= c("temperature_2m","apparent_temperature","precipitation_probability","precipitation"), .multi = "comma"
    ) |>
    req_perform() |>
    resp_body_json() |>
    as_tibble ()
}

#' Remodeler la tibble obtenue de la requête pour correspondre à une structure donnée.Cette fonction prend en entrée la tibble résultant de la requête et la transforme pour générer une nouvelle tibble contenant les données requises.
#'
#' @param extraction La méthode d'extraction à utiliser pour extraire les différentes colonnes de la liste de données.
#'
#' @return Une tibble remodelée selon la structure spécifiée.
#'
#' @export
unnest_response <- function(extraction){
  hourly_data <- extraction$hourly
  if (length(hourly_data) == 0) {
    stop("Aucune donnée dans la colonne 'hourly'.")
  }
  output_tibble <- tibble(
    "date_heure" = ymd_hm(unlist(hourly_data[[1]])),
    "temperature_celsius" = unlist(hourly_data[[2]]),
    "temperature_ressentie_celsius" = unlist(hourly_data[[3]]),
    "precipitation_proba" = unlist(hourly_data[[4]]),
    "precipitation" = unlist(hourly_data[[5]])
  )
}

#' Convertit une adresse en coordonnées GPS.
#'
#' @param adresse Une adresse sous forme de texte.
#'
#' @return Un vecteur numérique de taille 2 avec les coordonnées GPS (latitude, longitude).
#'
#' @export
address_to_gps <- function(adresse) {
  df_adresse <- data.frame("nom" = character(), addr = character(), stringsAsFactors = FALSE)

  df_adresse <- rbind(df_adresse, data.frame(addr = adresse), stringsAsFactors = FALSE)

  resultat_geocodage <- df_adresse |>
    geocode(addr, method = 'arcgis')

  df_adresse <- resultat_geocodage
}

#' Récupère les coordonnées GPS pour une adresse donnée.
#'
#' @param address Une adresse sous forme de texte.
#'
#' @return Un vecteur numérique de taille 2 avec les coordonnées GPS (latitude, longitude).
#'
#' @export
get_gps_coordinate <- function(address) {
  coord_df <- address_to_gps(address)
  latitude <- coord_df$lat
  longitude <- coord_df$long
  coordinates <- c(latitude[1], longitude[1])
}

#' Obtient les prévisions météo en fonction des coordonnées GPS.
#' @param xy Un vecteur numérique de taille 2 représentant les coordonnées GPS.
#'
#' @return Un tibble avec les prévisions météo.
#'
#' @seealso \code{\link{perform_request}}, \code{\link{unnest_response}}
#'
#' @export
get_forecast.numeric <- function(xy) {
  if (!is.numeric(xy) || length(xy) != 2) {
    stop("L'argument xy doit être un vecteur numérique de taille 2 (latitude, longitude).")
  }
  response_table <- perform_request(xy[1], xy[2])
  unnested_table <- unnest_response(response_table)
}

#' Obtient les prévisions météo en fonction d'une adresse. Cette fonction prend en entrée une adresse, utilise la fonction address_to_gps
#' pour obtenir les coordonnées GPS, puis appelle la fonction get_forecast.numeric.
#'
#' @param address Une adresse sous forme de texte.
#'
#' @return Un tibble avec les prévisions météo.
#'
#' @seealso \code{\link{address_to_gps}}, \code{\link{get_forecast.numeric}}
#'
#' @export
get_forecast.character <- function(address) {
  if (!is.character(address) || length(address) != 1) {
    stop("L'argument address doit être de type character et de taille 1.")
  }
  coordinates <- get_gps_coordinate(address)
  response_table <- perform_request(coordinates[1],coordinates[2])
  unnested_table <- unnest_response(response_table)
}

#' Obtient les prévisions météo en fonction des coordonnées GPS ou de l'adresse. Cette fonction est générique et permet d'obtenir les prévisions météo en fonction des coordonnées GPS
#' (latitude, longitude) ou d'une adresse spécifiée.
#'
#' @param x Un vecteur numérique de taille 2 représentant les coordonnées GPS (latitude, longitude).
#' @param address Une adresse spécifiée en tant que caractère.
#'
#' @return Une tibble contenant les prévisions météo, comprenant la date, l'heure UTC, la température, la
#' température ressentie, la probabilité de précipitation, et la quantité de précipitation.
#'
#' @seealso \code{\link{get_forecast.numeric}} et \code{\link{get_forecast.character}}
#'
#' @examples
#' # Obtenir les prévisions météo pour des coordonnées GPS
#' xy_coordinates <- c(48.85, 2.35)
#' forecast_result <- get_forecast(xy_coordinates)
#' print(forecast_result)
#'
#' # Obtenir les prévisions météo pour une adresse
#' address_result <- get_forecast("9 Quai Henri Barbusse, Nantes, 44000, FRANCE")
#' print(address_result)
#'
#' @export
#' @param x Un vecteur numérique de taille 2 représentant les coordonnées GPS (latitude, longitude) ou une adresse spécifiée en tant que caractère.
#' @return Une tibble contenant les prévisions météo.
get_forecast <- function(x) {
  if (is.numeric(x)) {
    result <- get_forecast.numeric(x)
  } else if (is.character(x)) {
    result <- get_forecast.character(x)
  } else {
    stop("L'un des arguments 'x' ou 'address' doit être spécifié.")
  }

  print(graph_function(result))
  return(result)
}
#' Fonction pour tracer les prévisions météo.
#'
#' Cette fonction prend en entrée les prévisions météo sous forme de tibble et trace un graphique.
#'
#' @param result Une tibble contenant les prévisions météo.
#' @return Un graphique des prévisions météo.
#' @export
graph_function <- function(result) {
  # Code pour tracer les prévisions météo
  # Par exemple, en utilisant ggplot2
  ggplot(data = result, aes(x = date_heure, y = temperature_celsius)) +
    geom_line() +
    labs(title = "Prévisions météo",
         x = "Date et heure",
         y = "Température (°C)")
}
