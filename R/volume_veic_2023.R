library(dplyr)
library(ggplot2)
library(arrow)
library(openxlsx)
library(readr)


rodovias_2023 <- read_parquet("data/ANTT.parquet") |>
  filter(ano == 2023 & concessionaria %in% c("AUTOPISTA FERNÃO DIAS", "AUTOPISTA FLUMINENSE",  
                                             "AUTOPISTA LITORAL SUL", "AUTOPISTA PLANALTO SUL",
                                             "AUTOPISTA REGIS BITTENCOURT", "CONCER", "CONCEBRA",
                                             "ECOSUL", "ECO101","ECOVIAS DO ARAGUAIA", 
                                             "ECOVIAS DO CERRADO", "ECO050", "VIA BAHIA",
                                             "VIA 040", "VIA BRASIL")) |>
  mutate(
    concessionaria = str_to_title(concessionaria),
    praca = str_to_title(str_remove_all(praca, "[()]")),
    volume_total = as.numeric(gsub(",", ".", volume_total)))|>
  group_by(concessionaria, praca, dia, mes) |>
  summarise(total_veic = sum(volume_total, na.rm = T))
  
  
sheet_conc <- createWorkbook()
concessionarias <- unique(rodovias_2023$concessionaria)

for (conc in concessionarias) {
  df <- rodovias_2023 |> filter(concessionaria == conc)
  addWorksheet(sheet_conc , conc) 
  writeData(sheet_conc , conc, df) }

saveWorkbook(sheet_conc, "data/rodovias_2023.xlsx", overwrite = TRUE)