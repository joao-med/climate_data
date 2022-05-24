require(tidyverse)
require(terra)
require(tmap)
library(raster)
require(purrr)

# Here you can add any shape file you desire
inshpfname <- "Shape_files/shape_brazil.shp"
inshp <- vect(inshpfname)

# Creating climate data dataset -------------------------------------------
# selecting files
files <- list.files("C:climate_CRU_data/", full.names = T) # To download data: https://github.com/joao-med/climate_data/blob/main/CRU_TS_download_data
types <- c("cld","dtr","frs","pet","pre","tmn","tmp","tmx","vap","wet") # here you can choose the type of data

for(i in types){
  incru_name <- files [files %>% str_detect(i)]
  tib <- tibble()
  for (x in incru_name){
    dates <- x %>% str_extract_all("(?<=\\.).*?(?=\\.)")
    date_1 <- dates[[1]][2] %>% as.integer()
    date_2 <- dates[[1]][3] %>% as.integer()
    incru <- rast(x, subds = i)
    crudata <- terra::extract(incru,inshp, fun = mean, na.rm = T)
    crudata$code <- inshp$code
    names(crudata)[2:121] <- terra::time(incru) %>% as.character()
    shp <- merge(inshp,crudata) %>% as.tibble()
    shp_t <- shp %>% subset(select = -ID)  %>%
      pivot_longer(!code, names_to = "date", values_to = paste0(i)) %>%
      mutate(year = date %>% lubridate::year(),
             month = date %>% lubridate::month())
    tib <- bind_rows(tib,shp_t)
  }
  write.csv(tib, paste0(i,".csv"),row.names = F) 
}
# Again, if you do not want all type of data, you can just delete the part you do not want
cld <- "dados_climaticos/cld.csv" %>% read.csv()
dtr <- "dados_climaticos/dtr.csv" %>% read.csv()
frs <- "dados_climaticos/frs.csv" %>% read.csv()
pet <- "dados_climaticos/pet.csv" %>% read.csv()
pre <- "dados_climaticos/pre.csv" %>% read.csv()
tmn <- "dados_climaticos/tmn.csv" %>% read.csv()
tmp <- "dados_climaticos/tmp.csv" %>% read.csv()
tmx <- "dados_climaticos/tmx.csv" %>% read.csv()
vap <- "dados_climaticos/vap.csv" %>% read.csv()
wet <- "dados_climaticos/wet.csv" %>% read.csv()

weather <- list(cld,dtr,frs,pet,pre,
                tmn,tmp,tmx,vap,wet) %>% 
  reduce(left_join)
weather <- weather %>% select(-X)
# Saving
write_rds(weather,
          "weather.rds")
