require(tidyverse)
require(terra)
require(tmap)
#### Getting Brazilian climate data by microregion

# establishing microregions
inshpfname <- "shapes/shape_brazil.shp"
inshp <- vect(inshpfname)
inshp$code <- as.character(inshp$code)

# outfolder
outfolder <- "tables/"

# Downloading data
# The Documents are large and may take a while to be downloaded
#devtools::install_github("agrdatasci/ag5Tools", build_vignettes = TRUE)
library(ag5Tools)
## Available data
# cloud_cover
# liquid_precipitation_duration_fraction
# snow_thickness_lwe
# solar_radiation_flux
# 2m_temperature
# 2m_dewpoint_temperature
# precipitation_flux
# solid_precipitation_duration_fraction
# snow_thickness
# vapour_pressure
# 10m_wind_speed
# 2m_relative_humidity
## Statistics: Specific statistics can be seen at: 
# 24_hour_maximum
# 24_hour_mean
# 24_hour_minimum
# day_time_maximum
# day_time_mean
# night_time_mean
# night_time_minimum

# Downloading
# Attention: Python must be installed in your computer and you must install 
# cdsapi
# In my case I had to use the CMD and pip install cdsapi and then use the terminal 
# here in R to pip install again. Only after that I was able to make it work
ag5_download(variable = "2m_temperature",
             statistic = "24_hour_maximum",
             day = "all",
             month = "all",
             year = 2015:2016,
             path = "")

# Introduce here the variable name
varname = "Temperature_Air_2m_Mean_24h"
years <- 2015 %>% as.character
#listing all files to be processed
for (year in years) {# span of years
  print(paste0("Loading ", year))
  outfname <- paste0(outfolder, "/", varname, year, ".rds")
  files <- list.files(year,
                      pattern = "Temperature-Air-2m-Max", 
                      full.names = T)
  tib <- tibble()
  for (file in files){
    
    print(paste0('loading ', file))
    inmat <- rast(file,subds = varname)
    intimes = time(inmat)
    cnames = paste0(varname,".",format(intimes, format = "%Y.%m.%d"))
    matdata <- terra::extract(inmat,inshp, fun = mean, na.rm = T)
    names(matdata)[-1] <- cnames
    matdata$code <- inshp$code
    matdata$ID <- NULL
    matdata <- matdata %>%
      pivot_longer(
        -code, 
        names_to = c("varname","year","month","day"),
        names_pattern = "(.*)\\.(.*)\\.(.*)\\.(.*)"
      )
    
    tib <- bind_rows(tib,matdata )
    paste0("File processed")
    
  }
  print(paste0("Saving ", year))
  write_rds(tib, paste0(outfolder,varname,"_",year))
}

