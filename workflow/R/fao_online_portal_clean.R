#function for cleaning the fao data in the format available from the Statistical Query Panel (2023)

#' fao_online_portal_clean
#'
#' @param fao FAO dataset downloaded from Statistical Query Panel
#' @param sub_N value to substitute for rows that have the flag of N
#'
#' @return returns a cleaned version of the FAO data
fao_online_portal_clean <- function(fao, sub_N = 0.1) {
  
  fao <- fao %>% 
    dplyr::rename(country = "Country (Name)",
                  asfis_species = "ASFIS species (Name)",
                  area = "FAO major fishing area (Name)",
                  unit_name = "Unit (Name)") %>%
    # remove brackets from years
    dplyr::rename_with(~ base::gsub("\\[", "", .)) %>% 
    dplyr::rename_with(~ base::gsub("\\]", "", .)) %>% 
    mutate(row_id = row_number(),
           # Remove brackets from some species names
           asfis_species = str_replace_all(asfis_species, "\\[|\\]", ""))
  
# fao <- fao %>% 
#   mutate(row_id = row_number())

# Find column names that are 4-digit numbers
year_cols <- grep("^\\d{4}$", names(fao), value = TRUE)

# Convert those names to numeric
years <- as.numeric(year_cols)

initial_data_year <- min(years)
last_data_year <- max(years)

#N is a flag used by FAO to indicate not significant (negligible)
#we replace this with 0.1, both for tonnes and value in thousands

s_cols <- names(fao)[startsWith(names(fao), "S...")]
# Create a sequence of new names for flag cols
new_names <- paste0(initial_data_year:last_data_year, " Flag")
# Rename them in the data frame
names(fao)[names(fao) %in% s_cols] <- new_names

#pivot all of the year/value columns 
fao_values <- fao %>% 
  # Remove flag columns
  dplyr::select(-c(contains("Flag"))) %>% 
  pivot_longer(cols = paste0(initial_data_year:last_data_year),
               names_to = "year",
               values_to = "value")

#pivot all of the flag columns   
fao_flags <- fao %>%
  select(-matches("^\\d{4}$")) %>% 
  pivot_longer(cols = paste(initial_data_year:last_data_year, "Flag"),
               names_to = "flag_year",
               values_to = "flag") %>% 
  mutate(year = str_remove(flag_year, " Flag")) %>% 
  select(year, flag, row_id) 

#combine flag and row id 
fao_new <- fao_values %>%
  left_join(fao_flags, by = c("row_id", "year"))

#replace 
fao_new <- fao_new%>% 
  mutate(value = case_when((str_detect(flag, "N") & value == 0) ~ sub_N,
                           TRUE ~ value)) %>% #replace values that are 0 and have the flag N with sub_N
  select(-c(row_id, flag))


return(fao_new)
}