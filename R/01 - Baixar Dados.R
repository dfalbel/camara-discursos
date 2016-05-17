url <- "http://www.camara.gov.br/internet/sitaqweb/resultadoPesquisaDiscursos.asp"

get_ano(url, 1990)

for (ano in 2006)
  get_ano(url, ano)