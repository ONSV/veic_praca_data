library(tidyverse)
library(arrow)
library(lubridate)


read_ANTT <- function(file) {
  temp <- paste0("docs/", basename(file)) 
  
  if (!file.exists(temp)) {
    download.file(file, destfile = temp)
  }

  
  data <- read.csv(temp, sep = ";", fileEncoding = "latin1") |>
    mutate(
      mes_ano = as.character(mes_ano),
      data_inversa = dmy(mes_ano),  
      ano = year(data_inversa),     
      mes = month(data_inversa),    
      dia = day(data_inversa),
      concessionaria = toupper(concessionaria))|>
    select(concessionaria, data_inversa, dia, mes, ano, everything(), -mes_ano)
  
  return(data)
}

link_list <- read.csv("docs/links_ANTT.csv")$link

files <- lapply(link_list, read_ANTT)

ANTT <- bind_rows(files)

write_parquet(ANTT, sink = "data/ANTT.parquet")