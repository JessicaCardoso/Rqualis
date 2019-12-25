
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

# Pegamos o valor retornado e colocamos na busca
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
```

[Clique aqui](), caso você tenha interesse em fazer buscas mais
detalhadas.
