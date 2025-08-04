---
title: "Softbottom Habitat Destruction"
output: html_document
date: "2025-08-01"
editor_options: 
  chunk_output_type: console
---

Trawl_bottom is the main form of destructive fishing in benthic habitats. Revise to include any others.



``` r
knitr::opts_chunk$set(echo = TRUE, eval=FALSE)
```


``` r
knitr::opts_chunk$set(fig.width = 6, fig.height = 4, fig.path = 'Figs/',
                      echo = TRUE, message = FALSE, warning = FALSE, eval = FALSE)
```


``` r
#install.packages("rredlist")
library(dplyr)
library(tidyr)
library(tidyverse)
library(here)
library(sf)

#source('https://raw.githubusercontent.com/oharac/src/master/R/common.R')
source(here('workflow/R/common.R'))

goal     <- 'hab_prs_hd_subtidal_soft_bottom'
scenario <- 'v2025'

dir_goal <- here('globalprep', goal, scenario)

### goal specific folders and info
dir_anx  <- file.path(dir_M, 'git-annex/globalprep')
dir_goal_anx <- file.path(dir_anx, goal, scenario, 'spp_risk_dists')
```

Download data here: https://data.mapping-global-fishing.cloud.edu.au/shiny/mapping_fishing_effort_app/



``` r
trawl_bottom_files <- list.files(file.path(dir_anx, "_raw_data", "global_fishing_effort"), pattern = ".csv", full.names = TRUE)

for (i in trawl_bottom_files) {
  
  # Read csv
  fishing_effort <- read_csv(trawl_bottom_files[i], show_col_types = FALSE)
  
  # Extract year
  year <- str_extract(trawl_bottom_files[i], "\\d{4}")
  
  # Group by lon, lat, eez_sovereign_iso3c, pixel_area_km2, and summarise eff_active_fishing_hours
  fishing_effort_summarized <- fishing_effort %>%
    group_by(lon, lat, eez_sovereign_iso3c, pixel_area_km2) %>%
    summarise(sum_eff_active_fishing_hours = sum(eff_active_fishing_hours, na.rm = TRUE))
  
  # Log pressure
  fishing_effort_logged <- fishing_effort_summarized %>%
    mutate(pressure = log(sum_eff_active_fishing_hours/pixel_area_km2 +1)) %>%
    filter(!eez_sovereign_iso3c == "High seas")
  
  #hist(fishing_effort_logged$pressure)
  quant_99 <- quantile(fishing_effort_logged$pressure, probs = 0.99)
  
  fishing_effort_sf <- fishing_effort_logged %>%
    # add lat and lon bin to preserve for merge 
    dplyr::mutate(lat_bin = lat, lon_bin = lon) %>%
    # import as WGS (unit = degrees)
    st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
    select(-c(pixel_area_km2, sum_eff_active_fishing_hours))
  
  fishing_effort_sf_year <- fishing_effort_sf %>%
    mutate(pressure_year = pressure/quant_99)
  
  fishing_effort_mean <- fishing_effort_sf_year %>%
    group_by(eez_sovereign_iso3c) %>%
    summarise(mean_pressure_year = mean(pressure_year))
  
  
  
}
```

Rasterize and rescale




