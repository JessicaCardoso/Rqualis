
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rqualis <img src='man/figures/logo.png' align="right" height="120" />

<!-- badges: start -->

<!-- badges: end -->

O pacote Rqualis foi desenvolvido com o objetivo de permitir realizar
consultas das notas de qualis-periódicos. A página do Sucupira referente
a consulta de Qualis pode ser acessada ao clicar na imagem a seguir.

<a href="https://sucupira.capes.gov.br/sucupira/public/index.xhtml">
<img src='https://sucupira.capes.gov.br/sucupira/images/logo-sucupira.png' align="center"/>
</a>

## Instalação

Você pode instalar a versão do Rqualis disponível no Github através do
seguinte comando:

``` r
#install.packages("remotes")
remotes::install_github("JessicaSousa/Rqualis")
```

## Exemplo

A segui mostramos como utilizar a biblioteca para recuperar os
periódicos de uma área específica referente a avaliação do triênio
2010-2012:

``` r
library(Rqualis)

# Obter página do sucupira
page <- get_sucupira_page()

# Obter a tabela de evento para saber qual código do triênio 2010-2012 
op_event <- get_options(page, form = "evento")
print(op_event)
#> # A tibble: 2 x 2
#>   value name                                             
#>   <chr> <chr>                                            
#> 1 156   CLASSIFICAÇÕES DE PERIÓDICOS QUADRIÊNIO 2013-2016
#> 2 14    CLASSIFICAÇÕES DE PERIÓDICOS TRIÊNIO 2010-2012

# Descobrir qual código corresponde a área de computação 
op_area <- get_options(page, form = "area")
print(op_area)
#> # A tibble: 49 x 2
#>    value name                                                               
#>    <chr> <chr>                                                              
#>  1 27    "ADMINISTRAÇÃO PÚBLICA E DE EMPRESAS, CIÊNCIAS CONTÁBEIS E TURISMO"
#>  2 35    "ANTROPOLOGIA / ARQUEOLOGIA                        "               
#>  3 29    "ARQUITETURA, URBANISMO E DESIGN"                                  
#>  4 11    "ARTES"                                                            
#>  5 3     "ASTRONOMIA / FÍSICA                               "               
#>  6 7     "BIODIVERSIDADE"                                                   
#>  7 48    "BIOTECNOLOGIA                                     "               
#>  8 2     "CIÊNCIA DA COMPUTAÇÃO                             "               
#>  9 25    "CIÊNCIA DE ALIMENTOS                              "               
#> 10 39    "CIÊNCIA POLÍTICA E RELAÇÕES INTERNACIONAIS        "               
#> # … with 39 more rows

tb <- get_qualis_table(page, cod_event="14", cod_area = "2")
print(head(tb))
#> # A tibble: 6 x 3
#>   ISSN      Título                                      Estrato
#>   <chr>     <chr>                                       <chr>  
#> 1 2316-9451 Abakós                                      C      
#> 2 1076-6332 Academic Radiology                          B2     
#> 3 1519-7859 Ação Ergonômica                             C      
#> 4 0360-0300 ACM Computing Surveys                       A1     
#> 5 2153-2184 ACM Inroads                                 B4     
#> 6 1936-1955 ACM Journal of Data and Information Quality B4

# Pegamos o valor retornado e colocamos na busca
```

Caso você esteja interessado em fazer buscas mais detalhes sobre Qualis
no site do Sucupira, você pode fazer isso através das bibliotecas
`rvest` e `httr`, ambas disponíves no
[CRAN](https://cran.r-project.org/).

``` r
install.packages(c('rvest', 'httr'))
```

Após instalar ambas bibliotecas, para efetuar consultas na página de
periódico é necessário obter o nome dos campos dos formulários da
página. No exemplo abaixo estou usando o operador pipe (`%>%`)
disponível na biblioteca `magrittr`.

``` r
library(magrittr)
library(tibble)

#Obter a região do html correspondente ao formulário de busca
# formulário está marcado com a classe form-group
qualis_form <- page %>% rvest::html_nodes('.form-group')
          

df_form <- tibble(label = rvest::html_nodes(qualis_form, 'label') %>% 
                          rvest::html_text(),
                  name = qualis_form %>%
                         rvest::html_nodes('.form-control') %>% 
                         rvest::html_attr('name')
                  )
print(df_form)
#> # A tibble: 5 x 2
#>   label                                                 name          
#>   <chr>                                                 <chr>         
#> 1 "Evento de\n                          Classificação:" form:evento   
#> 2 "Área de Avaliação:"                                  form:area     
#> 3 "ISSN:"                                               form:issn:issn
#> 4 "Título:"                                             form:j_idt60  
#> 5 "Classificação:"                                      form:estrato
```

Agora vamos refinar busca de periódicos de computação do triênio
2010-2012, para filtrar de acordo com a classificação. Utilizando a
mesma função `get_options` vamos obter a lista de classificações.

``` r
op_estrato <- get_options(page, form = "estrato")
print(op_estrato)
#> # A tibble: 8 x 2
#>   value name 
#>   <chr> <chr>
#> 1 21    "A1" 
#> 2 22    "A2" 
#> 3 23    "B1" 
#> 4 24    "B2" 
#> 5 25    "B3" 
#> 6 26    "B4" 
#> 7 27    "B5" 
#> 8 28    "C "
```

Escolhemos filtrar os periódicos com classificação A1, para isso
inserimos o valor 21 no campo específico ao estrato.

``` r

url <- "https://sucupira.capes.gov.br/sucupira/public/consultas/coleta/veiculoPublicacaoQualis/listaConsultaGeralPeriodicos.xhtml"

#Obter ViewState da Página do Sucupira
viewstate <- page %>%
  rvest::html_node(xpath = "//*[@id=\"javax.faces.ViewState\"]") %>%
  rvest::html_attr("value")

parametros <- list(
  'form' = 'form',
  'form:evento'= "14",
  'form:area' = '2',
  "form:checkArea" =    "on",
  'form:estrato' = '21',
  "form:checkEstrato" = "on",
  'form:consultar' = 'Consultar',
  'javax.faces.ViewState' = viewstate
)

resultado <- httr::POST(url, body = parametros)
pagina <- resultado %>% httr::content('text') %>% xml2::read_html() 
tabela <- pagina %>% rvest::html_table() %>% .[[1]]
head(tabela)
#>        ISSN                                           Título
#> 1 0360-0300                            ACM COMPUTING SURVEYS
#> 2 0730-0301                     ACM TRANSACTIONS ON GRAPHICS
#> 3 1748-7188                 ALGORITHMS FOR MOLECULAR BIOLOGY
#> 4 1134-3060 ARCHIVES OF COMPUTATIONAL METHODS IN ENGINEERING
#> 5 0004-3702            ARTIFICIAL INTELLIGENCE (GENERAL ED.)
#> 6 0005-1098                              AUTOMATICA (OXFORD)
#>       Área de Avaliação Classificação
#> 1 CIÊNCIA DA COMPUTAÇÃO            A1
#> 2 CIÊNCIA DA COMPUTAÇÃO            A1
#> 3 CIÊNCIA DA COMPUTAÇÃO            A1
#> 4 CIÊNCIA DA COMPUTAÇÃO            A1
#> 5 CIÊNCIA DA COMPUTAÇÃO            A1
#> 6 CIÊNCIA DA COMPUTAÇÃO            A1
```
