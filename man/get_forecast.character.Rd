% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_weather_forecast.R
\name{get_forecast.character}
\alias{get_forecast.character}
\title{Obtient les prévisions météo en fonction d'une adresse. Cette fonction prend en entrée une adresse, utilise la fonction address_to_gps
pour obtenir les coordonnées GPS, puis appelle la fonction get_forecast.numeric.}
\usage{
get_forecast.character(address)
}
\arguments{
\item{address}{Une adresse sous forme de texte.}
}
\value{
Un tibble avec les prévisions météo.
}
\description{
Obtient les prévisions météo en fonction d'une adresse. Cette fonction prend en entrée une adresse, utilise la fonction address_to_gps
pour obtenir les coordonnées GPS, puis appelle la fonction get_forecast.numeric.
}
\seealso{
\code{\link{address_to_gps}}, \code{\link{get_forecast.numeric}}
}
