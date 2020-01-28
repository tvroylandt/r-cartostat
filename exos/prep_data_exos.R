# ---------------------------- #
# Préparation des données exos #
# ---------------------------- #

library(tidyverse)
library(sf)

# Import ------------------------------------------------------------------
# Fichiers accidents
carac18 <- read_csv("data/dataset/exo_init/caracteristiques-2018.csv")
usagers18 <- read_csv("data/dataset/exo_init/usagers-2018.csv")

# Population Insee
pop17_dep <- readxl::read_xls("data/dataset/exo_init/ensemble.xls", sheet = "Départements",
                          skip = 7)

pop17_com <- readxl::read_xls("data/dataset/exo_init/ensemble.xls", sheet = "Communes",
                              skip = 7)


# Recodage ----------------------------------------------------------------
# Caractéristiques
carac18_r <- carac18 %>%
  select(Num_Acc, mois, dep, com, lum, agg) %>%
  rename(id_accident = Num_Acc) %>%
  mutate(
    dep = fct_recode(dep, 
                     "2A0" = "201",
                     "2B0" = "202"),
    code_com = paste0(str_sub(dep, 1, 2), com),
    code_dep = if_else(str_sub(dep, 1, 2) != "97", str_sub(dep, 1, 2), as.character(dep)),
    luminosite = fct_collapse(
      as.character(lum),
      "Jour" = "1",
      "Aube/Crépuscule" = "2",
      "Nuit sans éclairage" = c("3", "4"),
      "Nuit avec éclairage" = "5"
    ),
    agglo = fct_recode(
      as.character(agg),
      "En agglomération" = "2",
      "Hors agglomération" = "1"
    )
  ) %>%
  select(id_accident, mois, code_dep, code_com, luminosite, agglo)

# Usagers
usagers18_r <- usagers18 %>% 
  group_by(Num_Acc, grav) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(grav = fct_recode(as.character(grav),
                           "nb_tues" = "2",
                           "nb_indemnes" = "1",
                           "nb_blesses_legers" = "4",
                           "nb_blesses_hospi" = "3")) %>% 
  pivot_wider(names_from = grav,
              values_from = n,
              values_fill = list(n = 0)) %>% 
  mutate(nb_impliques = nb_indemnes + nb_tues + nb_blesses_hospi + nb_blesses_legers)

# Population
pop17_dep_r <- pop17_dep %>% 
  rename(code_dep = `Code département`,
         pop_tot = `Population totale`) %>% 
  select(code_dep, pop_tot)

pop17_com_r <- pop17_com %>%
  mutate(code_com = if_else(
    str_sub(`Code département`, 1, 2) == "97",
    paste0(str_sub(`Code département`, 1, 2), `Code commune`),
    paste0(`Code département`, `Code commune`)
  )) %>%
  rename(pop_tot = `Population totale`) %>%
  select(code_com, pop_tot)

# Jointure ----------------------------------------------------------------
accidents18 <- carac18_r %>% 
  left_join(usagers18_r, by = c("id_accident" = "Num_Acc")) %>% 
  mutate(id_accident = as.character(id_accident))

# Export ------------------------------------------------------------------
write_csv2(accidents18, "data/dataset/exo/accidents18_exo.csv")

write_csv2(pop17_dep_r, "data/dataset/exo/pop_dep17.csv")
writexl::write_xlsx(pop17_com_r, "data/dataset/exo/pop_com17.xlsx")
