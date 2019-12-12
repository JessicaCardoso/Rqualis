#' @title Obter página para consultar qualis.
#'
#' Realiza GET na página  do \href{https://sucupira.capes.gov.br/sucupira/public/consultas/coleta/veiculoPublicacaoQualis/listaConsultaGeralPeriodicos.jsf}{Sucupira}
#'
#' @importFrom  httr GET
#' @return Retorna a a página de Qualis do site do sucupira.
#' @export
#' @examples
#' qualis_page <- get_sucupira_page()
#' print(qualis_page)
get_sucupira_page <- function(){
  url <- paste0("https://sucupira.capes.gov.br/",
               "sucupira/public/consultas/coleta/",
               "veiculoPublicacaoQualis/",
               "listaConsultaGeralPeriodicos.jsf")
  request <- httr::GET(url)
  qualis_page <-  xml2::read_html(request)
  return(qualis_page)
}

#' @title Obter opções dos fórmulários.
#'
#' @importFrom  xml2 read_html
#' @importFrom  tibble tibble
#' @importFrom  rvest html_nodes
#' @importFrom  glue glue
#' @importFrom  rvest html_attr
#' @importFrom  rvest html_text
#' @description Essa função permite que você obtenha uma tabela contendo os
#' valores de um campo específico.
#' @param sucupira_page Objeto gerado pela função \code{get_sucupira_page}
#' @param form Nome do campo do formulário.
#' @return Retorna um \code{tibble} contendo as opções do campo especificado.
#' @keywords opções
#' @export
#' @examples
#' request <- get_sucupira_page()
#' get_options(request)
get_options <- function(sucupira_page, form = "evento"){
  options <- rvest::html_nodes(sucupira_page, xpath = glue::glue("//*[@id=\"form:{form}\"]/option"))
  tibble::tibble(value = rvest::html_attr(options, "value"),
  name = rvest::html_text(options))[-1, ]
}


#' @title Obter tabela de periódicos.
#'
#'
#' @description Essa função permite que você obtenha uma tabela contendo os
#' valores de um campo específico.
#' @importFrom  xml2 read_html
#' @importFrom  rvest html_nodes
#' @importFrom  glue glue
#' @importFrom  rvest html_attr
#' @importFrom  rvest html_text
#' @importFrom  utils read.table
#' @importFrom  dplyr filter
#' @importFrom  readr read_file
#' @return Retorna um dataframe contendo o valor dos campos de opções do menu informado.
#' @param qualis_page refere-se o objeto gerado pela função \code{get_sucupira_page}
#' @param area refere-se a área que se deseja obter a tabela dos periódicos
#' @param event refere-se ao evento de classificação dos periódiocos se é do triênio
#' ou quadriênio
#' @export
#' @examples
#'
#' sucupira_pg <- get_sucupira_page()
#' tb <- get_qualis_table(sucupira_get = sucupira_pg)
#' print(head(tb))
#'
#'
get_qualis_table <- function(qualis_page, cod_event = "14", cod_area =""){

  url <- paste0("https://sucupira.capes.gov.br/",
                "sucupira/public/consultas/coleta/",
                "veiculoPublicacaoQualis/",
                "listaConsultaGeralPeriodicos.jsf")

  # Obter o ViewState
  viewstate <- rvest::html_node(qualis_page, xpath = "//*[@id=\"javax.faces.ViewState\"]")
  viewstate <- rvest::html_attr(viewstate, "value")

  # Preencher formulário para busca
  params <- list(
    'form' = 'form',
    'form:evento'= cod_event,
    'form:estrato' = 0,
    'form:consultar' = 'Consultar',
    'javax.faces.ViewState' = viewstate
  )


  if(cod_area != ""){
    params$`form:checkArea` <- "on"
    params$`form:area` <- cod_area
  }

  #Faz consulta no site do sucupira
  response <- httr::POST(url, body = params)

  # Obter formulário para download do arquivo xls
  download_input <-  xml2::read_html(response)
  download_input <- rvest::html_nodes(download_input, "a")
  download_input <- purrr::keep(download_input, grepl(".xls", download_input))
  download_input <- regmatches(download_input, regexpr("form:j_idt\\d+", download_input))

  params[download_input] <- download_input

  response2 <- httr::POST(response$url, body = params)

  xls_file <- httr::content(response2, 'text', encoding = "latin1")
  xls_file <- readr::read_file(xls_file)
  readr::read_tsv(xls_file)

}
