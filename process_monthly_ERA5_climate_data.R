require(tidyverse)

# Processing climate data from ERA5. Brazilian microregions

# ERA5 data was downloaded and extracted to .csv files for each month
# For temperature, vapor, and precipitation flux contact jpmgomes25@gmail.com as
# the data is to large for a github

# getting file list

files <- list.files("dados_climaticos/gabs", full.names = T)
# Selecting type of data to be merged
types <- c("Min","Max","Vapour","2m-Mean", "Flux")
# creating file to be pivoted
infile <- tibble()
# binding all rows
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
# saving raw data/
infile %>% saveRDS("rds_salvos/raw_era5.rds")
infile %>% summary

# There is some NA in the the data, they belong to Fernando de Noronha Island
NA_infile <- infile %>% filter(value %>% is.na())
NA_infile %>% summary
# Lets remove them
infile <- infile %>% filter(code != 26019)
# pivoting data from one col to a col to each varname 
ERA5 <- pivot_wider(infile, names_from = varname,values_from = value)
# checking 
ERA5 %>% summary()
# saving the data
saveRDS(ERA5, "rds_salvos/ERA5.rds")
