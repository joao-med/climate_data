require(tidyverse)
library(httr)
require(rvest)
# This file can download all the data from CRU TS. For more information: 
# https://catalogue.ceda.ac.uk/uuid/b6c783922d1ce68c4293d90caede5bb9 
# https://www.uea.ac.uk/groups-and-centres/climatic-research-unit 
# This data is the golden standard for gridded monthly data

# Here I use the original site where you can find the data, because the data can also be downloaded from
# CEDA Archive, but they ask for a complicaded process to download it

# downloading climate data --------------------------------------------------------

#scraping for filenames to download
url <- "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.05/cruts.2103051243.v4.05/"
types <- c("cld","dtr","frs","pet","pre","tmn","tmp","tmx","vap","wet") # here you can choose which kind of data you want to download 
urls <- paste0(url,types)
tx_types <- tibble() 
for (i in urls){
  r <- GET(i) %>% 
    content("text", encoding = "latin1") %>%
    xml2::read_html()
  r_tx <- r %>%
    html_nodes("a") %>%
    html_text('href') %>% as_tibble()
  r_tx <-  r_tx %>% 
    filter(r_tx$value %>% str_detect("dat.nc.gz")) # I'm extracting this type of file, if you would prefer another type check the available ones here
  tx_types <- bind_rows(tx_types, i = r_tx)        # https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.05/cruts.2103051243.v4.05/cld/
}

# selecting files to download
# selecting range of years >> The range of years can be found here https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.05/cruts.2103051243.v4.05/cld/
to_download <- tx_types %>% 
  filter(tx_types$value %>% 
           str_detect("1991|2001|2011")) # I selected the first year from each period available
#loop
for(x in types){
  link_base <- paste0("https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.05/cruts.2103051243.v4.05/",
                      x,"/")
  to_download_sel <- 
    to_download %>% 
    filter(to_download$value %>% str_detect(x))
  for (i in to_download_sel$value){
    download.file(paste0(link_base,i), 
                  paste0("dados_climaticos/separados/", i ))
  }}


