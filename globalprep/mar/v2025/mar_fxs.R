mar_split <- function(m) {
  ### Deal with special cases of countries, specific to MAR: Netherlands Antilles reported multiple ways, including 'Bonaire/S.Eustatius/Saba' 
  ### - FAO reports 'Antilles' as one region, but OHI considers as four 
  ###   reported regions; break up and distribute values 
  
  m_ant <- m %>%
    filter(country == 'Netherlands Antilles [former]') %>%  # Conch was cultivated for restoration purposes in a joint programme across these 3 countries
    mutate(value = (value/3),  
           'Aruba' = value,
           'Bonaire' = value,
           'Curacao' = value) %>%
    select(-c(value, country)) %>%
    pivot_longer(cols = c("Aruba", "Bonaire", "Curacao"),
                 names_to = "country",
                 values_to = "value") %>%
    mutate(country = as.character(country),
           value = as.numeric(value)) %>% 
    select(c(country, fao, environment, species, year, Taxon_code, family, value))
  
  m <- m %>%
    filter(country != 'Netherlands Antilles [former]') %>%
    bind_rows(m_ant) %>%  
    arrange(country, fao, environment, species, year, value) 
  
  # 2024 update
  m_ant2_new <- m %>%
    filter(country == "Bonaire, Sint Eustatius and Saba") %>%  # update in 2024 for new name string
    mutate(
      value = (value/3),
      'Bonaire' = value,
      'Saba' = value,
      'Sint Eustatius' = value) %>%
    select(-c(value, country)) %>%
    pivot_longer(cols = c("Bonaire", "Saba", "Sint Eustatius"),
                 names_to = "country",
                 values_to = "value") %>% 
    mutate(country = as.character(country),
           value = as.numeric(value)) %>% 
    select(c(country, fao, environment, species, year, Taxon_code, family, value))
  
  m <- m %>%
    filter(!country %in% c("Bonaire, Sint Eustatius and Saba")) %>%
    bind_rows(m_ant2_new) %>% 
    arrange(country, fao, environment, species, year, value)
  
  m_ant2 <- m %>%
    filter(country == 'Bonaire/S.Eustatius/Saba') %>%  # Cobia was probably mostly in Curacao, but can't find evidence for it
    mutate(
      value = (value/3),
      'Bonaire' = value,
      'Saba' = value,
      'Sint Eustatius' = value) %>%
    select(-c(value, country)) %>%
    pivot_longer(cols = c("Bonaire", "Saba", "Sint Eustatius"),
                 names_to = "country",
                 values_to = "value") %>% 
    mutate(country = as.character(country),
           value = as.numeric(value)) %>% 
    select(c(country, fao, environment, species, year, Taxon_code, family, value))
  
  m <- m %>%
    filter(country != 'Bonaire/S.Eustatius/Saba') %>%
    bind_rows(m_ant2) %>% 
    arrange(country, fao, environment, species, year, value) 
  
  m_ant3 <- m %>%
    filter(country == 'Channel Islands') %>%
    mutate(
      value = (value/2),
      'Guernsey' = value,
      'Jersey' = value) %>%
    select(-c(value, country)) %>%
    pivot_longer(cols = c("Guernsey", "Jersey"),
                 names_to = "country",
                 values_to = "value") %>%
    mutate(country = as.character(country),
           value = as.numeric(value)) %>% 
    select(c(country, fao, environment, species, year, Taxon_code, family, value))
  
  m <- m %>%
    filter(country != "Channel Islands") %>%
    bind_rows(m_ant3) %>%  
    arrange(country, fao, environment, species, year, value) 
  
  # 2025 update
  m_ant4 <- m %>%
    filter(country == 'Union of Soviet Socialist Republics [former]') %>%  
    mutate(value = (value/6),
           'Russian Federation' = value,
           'Lithuania' = value,
           'Latvia' = value,
           'Estonia' = value,
           'Ukraine' = value,
           'Georgia' = value) %>%
    select(-c(value, country)) %>%
    pivot_longer(cols = c("Russian Federation", "Ukraine", "Georgia", "Lithuania", 
                          "Latvia", "Estonia"),
                 names_to = "country",
                 values_to = "value") %>%
    mutate(country = as.character(country),
           value = as.numeric(value)) %>%
    select(c(country, fao, environment, species, year, Taxon_code, family, value))

  m <- m %>%
    filter(country != 'Union of Soviet Socialist Republics [former]') %>%
    bind_rows(m_ant4) %>%
    arrange(country, fao, environment, species, year, value)
  
   m_ant5 <- m %>%
    filter(country == 'Serbia and Montenegro [former]') %>%  
    mutate(value = value,
           'Montenegro' = value) %>%
    select(-c(value, country)) %>%
    pivot_longer(cols = c("Montenegro"),
                 names_to = "country",
                 values_to = "value") %>%
    mutate(country = as.character(country),
           value = as.numeric(value)) %>%
    select(c(country, fao, environment, species, year, Taxon_code, family, value))
  
  m <- m %>%
    filter(country != 'Serbia and Montenegro [former]') %>%
    bind_rows(m_ant5) %>%
    arrange(country, fao, environment, species, year, value)
  
  
  return(m)
}

