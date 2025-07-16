## Joshua Bugay
## July 16th, 2025
## Data fetching and processing functions


fetch_github_data <- function(repo_url, cache_dir = "data/cache") {
 cache_file <- file.path(cache_dir, "github_data.rds")
 
 # Check if cache exists and is recent
 if (file.exists(cache_file)) {
  cache_time <- file.info(cache_file)$mtime
  if (difftime(Sys.time(), cache_time, units = "secs") < CACHE_DURATION) {
   return(readRDS(cache_file))
  }
 }
 
 # Fetch fresh data from GitHub
 tryCatch({
  response <- GET(repo_url)
  if (status_code(response) == 200) {
   content <- content(response, "parsed")
   raw_data <- base64_decode(content$content)
   data <- read_csv(raw_data)
   
   # Cache the data
   dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
   saveRDS(data, cache_file)
   
   return(data)
  }
 }, error = function(e) {
  # Return cached data if available, otherwise NULL
  if (file.exists(cache_file)) {
   return(readRDS(cache_file))
  }
  return(NULL)
 })
}

transform_data <- function(raw_data, filter_params = NULL) {
 # Your tidyverse transformations here
 processed_data <- raw_data %>%
  filter(if (!is.null(filter_params$date_range)) {
   date >= filter_params$date_range[1] & date <= filter_params$date_range[2]
  } else TRUE) %>%
  mutate(
   # Your transformations
  ) %>%
  arrange(date)
 
 return(processed_data)
}