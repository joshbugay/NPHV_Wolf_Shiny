## Joshua Bugay
## July 16th, 2025
## Global variables and functions
## 

# Load required libraries
library(shiny)
library(tidyverse)
library(httr)
library(jsonlite)

# Source custom functions
source("R/data_functions.R")
source("R/plot_functions.R")
source("R/utils.R")

# Global variables
GITHUB_REPO_URL <- "https://api.github.com/repos/username/repo/contents/data.csv"
CACHE_DURATION <- 3600  # Cache for 1 hour