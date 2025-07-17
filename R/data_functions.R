## Joshua Bugay
## July 16th, 2025
## Data fetching and processing functions


# Fetch a single file from public repo using raw URL
fetch_github_data_raw <- function(repo_url, file_name, cache_dir = "data/cache") {
 cache_file <- file.path(cache_dir, paste0(file_name, ".rds"))
 
 # Check cache first
 if (file.exists(cache_file)) {
  cache_time <- file.info(cache_file)$mtime
  if (difftime(Sys.time(), cache_time, units = "secs") < CACHE_DURATION) {
   cat("Loading", file_name, "from cache\n")
   return(readRDS(cache_file))
  }
 }
 
 # Fetch directly from raw URL
 cat("Fetching", file_name, "from GitHub raw URL\n")
 
 tryCatch({
  # Read CSV directly from raw GitHub URL
  data <- read_csv(repo_url, show_col_types = FALSE)
  
  # Cache the data
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  saveRDS(data, cache_file)
  
  cat("Successfully loaded", file_name, "with", nrow(data), "rows\n")
  return(data)
  
 }, error = function(e) {
  warning("Error fetching GitHub data for ", file_name, ": ", e$message)
  
  # Return cached data if available
  if (file.exists(cache_file)) {
   cat("Using cached version of", file_name, "\n")
   return(readRDS(cache_file))
  }
  
  return(NULL)
 })
}

# Fetch all files from your GITHUB_URLS list
fetch_all_github_data <- function() {
 all_data <- list()
 
 cat("Starting to fetch all GitHub data...\n")
 
 for (file_name in names(GITHUB_URLS)) {
  all_data[[file_name]] <- fetch_github_data_raw(GITHUB_URLS[[file_name]], file_name)
 }
 
 cat("Finished fetching all data\n")
 return(all_data)
}

# Transform data based on filters
transform_data <- function(all_data, filter_params = NULL) {
 # Check if primary data is available
 if (is.null(all_data$Wolf_observations)) {
  cat("No sales_data available for transformation\n")
  return(NULL)
 }
 
 # Start with your primary dataset
 processed_data <- all_data$Wolf_observations
 
 # Join with other datasets if available
 if (!is.null(all_data$Camera_locations) && "Camera_ID" %in% names(processed_data)) {
  processed_data <- processed_data |>
   left_join(all_data$Camera_locations, by = "Camera_ID")
 }
 
 # Apply filters if provided
 if (!is.null(filter_params)) {
  
  # Date range filter
  if (!is.null(filter_params$date_range) && "Date" %in% names(processed_data)) {
   processed_data <- processed_data |>
    filter(Date >= filter_params$date_range[1] & Date <= filter_params$date_range[2])
  }
 }
 
 # Sort by date if available
 if ("date" %in% names(processed_data)) {
  processed_data <- processed_data |>
   arrange(Date)
 }
 
 cat("Transformed data:", nrow(processed_data), "rows\n")
 return(processed_data)
}

# Utility function to check data freshness
check_data_freshness <- function(cache_dir = "data/cache") {
 cache_files <- file.path(cache_dir, paste0(names(GITHUB_URLS), ".rds"))
 
 freshness_info <- data.frame(
  file = names(GITHUB_URLS),
  cached = file.exists(cache_files),
  cache_time = sapply(cache_files, function(f) {
   if (file.exists(f)) {
    as.character(file.info(f)$mtime)
   } else {
    "No cache"
   }
  }),
  stringsAsFactors = FALSE
 )
 
 return(freshness_info)
}