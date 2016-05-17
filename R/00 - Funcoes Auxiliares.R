# GET
# Essa função é equivalente ao GET do httr, mas 
# não para o a execução quando dá erro.
library(httr)
library(stringr)
library(rvest)

criar_nome_arq_periodo <- function(ano, pag, dir){
  sprintf("%s/%d-%04d.html", dir, ano, pag)
}

# criar_nome_arq_periodo(1997, 26)

get_last_page <- function(arq){
  l <- read_html(arq) %>%
    html_node(".listingBar") %>%
    html_nodes("a") %>%
    html_attr("href")
  l[1] %>%
    str_extract("CurrentPage=[0-9]+") %>%
    str_extract("[0-9]+") %>%
    as.numeric()
}

get_periodo <- dplyr::failwith(NULL, function(url, arq, dtInicio, dtFim, pag){
  n <- GET(url,
      query = list(
        CurrentPage = pag,
        dtInicio = dtInicio,
        dtFim = dtFim,
        basePesq = "plenario",
        CampoOrdenacao = "dtSessao",
        PageSize = "1000",
        TipoOrdenacao = "ASC",
        btnPesq = "Pesquisar"
      ), write_disk(arq))
})

get_ano <- function(url, ano, dir = "data-raw/listas/", sleep = 1){
  dtInicio <- sprintf("01/01/%d", ano)
  dtFim <- sprintf("31/12/%d", ano)
  
  arq <- criar_nome_arq_periodo(ano, pag = 1, dir = dir)
  n <- get_periodo(url, arq, dtInicio, dtFim, pag = 1)
  total_pag <- get_last_page(arq)
  
  for (i in 2:total_pag) {
    arq <- criar_nome_arq_periodo(ano, pag = i, dir = dir)
    n <- get_periodo(url, arq, dtInicio, dtFim, pag = i)
    Sys.sleep(sleep)
  }
}
