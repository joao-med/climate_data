require(tidyverse)
library(httr)
require(rvest)


# downloading climate data --------------------------------------------------------

#scraping for filenames to download
url <- "https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.05/cruts.2103051243.v4.05/"
types <- c("cld","dtr","frs","pet","pre","tmn","tmp","tmx","vap","wet")
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
    filter(r_tx$value %>% str_detect("dat.nc.gz"))
  tx_types <- bind_rows(tx_types, i = r_tx)
}

# selecting files to download
#selectong range of years
to_download <- tx_types %>% 
  filter(tx_types$value %>% 
           str_detect("1991|2001|2011"))
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


