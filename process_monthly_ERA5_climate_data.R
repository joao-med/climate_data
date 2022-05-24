require(tidyverse)

# Processing climate data from ERA5

# ERA5 data was downloaded and extracted to .csv files for each month
# For temperature, vapor, and precipitation flux contact jpmgomes25@gmail.com as
# the data is to large for a github

# getting file list

files <- list.files("dados_climaticos/gabs", full.names = T)
types <- c("Min","Max","Vapour","Mean", "Flux")
infile <- tibble()
for(i in types){
  names_files <- files[str_detect(files, i)] 
  print(i)
  for (name_file in names_files){
    file <- read.csv(name_file) %>% 
      mutate(date = paste0(year,"-",month,"-",day) %>% lubridate::ymd(),
             varname = varname %>% str_replace_all("-","_"))
    file <- file %>% mutate(value = 
                              ifelse(file$varname %>% 
                                       str_detect("Temperature"), 
                                     file$value-273.15, 
                                     file$value))
    infile <-  bind_rows(infile, file)
  }
}
# infile %>% filter(varname == 'Vapour_Pressure_Mean') %>% view
infile %>% saveRDS("raw_era5.tds")
infile %>% summary
ERA5 <- pivot_wider(infile, names_from = varname,values_from = value)
