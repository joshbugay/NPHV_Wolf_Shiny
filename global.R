## Joshua Bugay
## July 16th, 2025
## Global variables and functions

# Load required libraries
library(shiny)
library(tidyverse)
library(magrittr)
library(httr)
library(jsonlite)

# Source custom functions
source("R/data_functions.R")
source("R/plot_functions.R")
source("R/utils.R")

# Global variables
CACHE_DURATION <- 3600  # Cache for 1 hour
GITHUB_URLS <- list(
 Camera_locations = "https://raw.githubusercontent.com/joshbugay/NPHV_Wolf_Shiny/refs/heads/main/data/Camera_locations.csv",
 Wolf_observations = "https://raw.githubusercontent.com/joshbugay/NPHV_Wolf_Shiny/refs/heads/main/data/Wolf_observations.csv")
