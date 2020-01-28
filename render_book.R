
# Render book
bookdown::render_book("index.Rmd", "bookdown::gitbook")

# Render exos
rmarkdown::render(
  "exos/feuille_exos.Rmd",
  output_dir = "docs",
  output_file = "feuille_exos",
  params = list(correction = FALSE)
)

rmarkdown::render(
  "exos/feuille_exos.Rmd",
  output_dir = "docs",
  output_file = "feuille_exos_correction",
  params = list(correction = TRUE)
)
