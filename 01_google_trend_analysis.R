---
title: "Google Trend Analysis"
output: html_notebook
---
  
#GOOGLE TRENDS AUTOMATION

#Skills: Reporting, Google Trends API, Cron Task Automation, Email SMTP

#1.0 LIBRARIES


#1.0 LIBRARIES

#Google Trends API
install.packages("gtrendsR")
library(gtrendsR)

#Core
install.packages("tidyverse")
#devtools::install_github("tidyverse/tidyverse")
install.packages("lubridate")
install.packages("tidyquant")
install.packages("magrittr")
install.packages("zeallot")
install.packages("maps")
install.packages("stringr")
install.packages("mapproj")
install.packages("DataExplorer")
install.packages("sjmisc")
library(DataExplorer)
library(mapproj)
library(stringr)
library(maps)
library(dplyr)
library(zeallot)
library(magrittr)
library(sjmisc)
require(magrittr)
library(tidyverse)
library(lubridate)
library(tidyquant)
library(forcats)

#File System
install.packages("fs")
library(fs)

# 2.0 GOOGLE TRENDS API

#Set up Search Terms


?gtrendsR::gtrends()

search_terms <- c(
  
  "aws",
  "azure",
  "google cloud"
  
)

#Read Search Terms

gtrends_lst <- search_terms %>%
    gtrends(geo = "US", time = "all")

# 3.0 Inspect Trends

gtrends_lst %>% names()

# 3.1 Search Interest Over Time

gtrends_lst %>%
    purrr::pluck("interest_over_time") %>%
    dplyr::mutate(hits = as.numeric(hits)) %>%
    as_tibble() %>%
    ggplot(aes(date, hits, color = keyword)) +
    geom_line() +
    geom_smooth(span = 0.3, se = FALSE) +
    theme_tq() +
    scale_color_tq() +
    labs(title = "Keyword Trends - US - Over Time")

# 3.2 Trends by Geography

gtrends_lst %>%
   purrr::pluck("interest_by_region") %>%
   as_tibble()


states_tbl <- map_data("state") %>%
    as_tibble() %>%
    dplyr::mutate(region = str_to_title(region))
states_tbl

state_trends_tbl <- gtrends_lst %>%
   purrr::pluck("interest_by_region") %>%
   left_join(states_tbl, by = c("location" = "region")) %>%
   as_tibble()

state_trends_tbl %>%
  
    ggplot(aes(long, lat)) +
    geom_polygon(aes(group = group, fill = hits)) +
    coord_map("albers", at0 = 45.5, latl = 29.5) +
    scale_fill_viridis_c() +
    theme_tq() +
    facet_wrap(~ keyword, nrow =1) +
    labs(title = "Keyword Trends - US")


gtrends_lst %>% names()
gtrends_lst %>% purrr::pluck("interest_by_dma") %>% as_tibble() %>% View()
gtrends_lst %>% purrr::pluck("related_queries") %>% as_tibble() %>% View()


# 3.3 Related Queries

gtrends_lst %>% purrr::pluck("related_queries") %>% DataExplorer::plot_bar()

n_terms <- 10

top_n_related_searches_tbl <- gtrends_lst %>%
    purrr::pluck("related_queries") %>%
    as_tibble() %>%
    dplyr::filter(related_queries == "top") %>%
    dplyr::mutate(interest = as.numeric(subject)) %>%
  
    dplyr::select(keyword, value, interest) %>%
    dplyr::group_by(keyword) %>%
    dplyr::arrange(desc(interest)) %>%
    dplyr::slice(1:n_terms) %>%
    dplyr::ungroup() %>%
  
    dplyr::mutate(value = haven::as_factor(value) %>% fct_reorder(interest))


top_n_related_searches_tbl %>%
    ggplot(aes(value, interest, color = keyword)) +
    geom_segment(aes(xend = value, yend = 0)) +
    geom_point() +
    coord_flip() +
    facet_wrap(~ keyword, nrow = 1, scales = "free_y") +
    theme_tq() +
    scale_color_tq()



