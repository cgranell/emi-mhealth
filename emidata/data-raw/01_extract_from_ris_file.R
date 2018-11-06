#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---


library(here)
library(RefManageR)
library(tidyverse)
library(googledrive)


file_name <- "selected_papers.bib"
data_path <- here::here("data-raw", file_name)

# Import the bibtex file and convert to data.frame
papers <- RefManageR::ReadBib(data_path, check = "warn", .Encoding = "UTF-8") %>% as.data.frame()


papers_tbl <- as_tibble(papers)
papers_tbl <- rownames_to_column(papers_tbl, "bibtextId")

papers_tbl %>% str()

#' Get rid of vars I will not use, rename vars I keep
papers_raw <- papers_tbl %>%
  select(type = bibtype, title, abstract, journal, author, year, keywords)

#' Get rid of curly brackets and extra " in titles
papers_raw$title <- stringr::str_replace_all(papers_raw$title, "[\"|{|}]", "")

papers_raw <- papers_raw %>%
  arrange(title)


#' Retrieve filenames from shared folder in Gdrive to get the "id"
#' credentials must be entered during first run, can be stored in file .httr-oauth
gdata_url <- "https://drive.google.com/open?id=1XqfD-JOrKLGdVtAq_wNIRYYUqSdamxo2"
gdata_path <- drive_get(as_id(gdata_url))
gdata_files <- drive_ls(path = gdata_path$name, type = "pdf")
drive_deauth()

gdata_files <- gdata_files %>%
  select(filename = name) %>%
  mutate(id = stringr::str_sub(filename, 1, 3))

#' Same order than the papers_raw
gdata_files <-  gdata_files %>% arrange(filename)

#' merge
papers_raw <- bind_cols(gdata_files, papers_raw)


#' Force year to be Date
papers_raw <- papers_raw %>%
  mutate(year = year %>% as.integer())

papers_raw %>% str()

#' Save for now
file_name <- "papers.csv"
data_path <- here::here("data-raw", file_name)
#'write_csv(papers, data_path)
#'devtools::use_data(papers, overwrite = TRUE)
