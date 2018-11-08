#' ---
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     keep_md: TRUE
#' ---


#'install.packages(c("here", "RefManageR", "tidyverse", "googledrive"))
library(here)
library(RefManageR)
library(tidyverse)
library(googledrive)


#' First file
#' Retrieve bibtext file of selected papers from the Shared folder in GDrive
gdata_url <- "https://drive.google.com/open?id=1XgPt4uFNwOmxGNjILYsW8VKq9ifQdU7q"
gdata_path <- drive_get(as_id(gdata_url))

gdata_file <- drive_ls(path = gdata_path$name, pattern = "selected_papers.bib")

data_path <- here::here("data-raw", gdata_file$name) # local file
drive_download(file = as_id(gdata_file$id), path = data_path, overwrite = TRUE, verbose = TRUE)
drive_deauth()

# Import the local bibtex file and convert it to a tibble
papers_raw <- RefManageR::ReadBib(data_path, check = "warn", .Encoding = "UTF-8") %>%
  as.data.frame() %>% as_tibble()

# for the time being, turn rownames into a column
papers_raw <- rownames_to_column(papers_raw, "bibtextId")

papers_raw %>% str()

#' Get rid of vars I will not use, rename vars I keep
papers_raw <- papers_raw %>%
  select(type = bibtype, title, abstract, journal, author, year, keywords)

#' Get rid of curly brackets and extra quotation marks in titles
papers_raw$title <- stringr::str_replace_all(papers_raw$title, "[\"|{|}]", "")

papers_raw <- papers_raw %>%
  arrange(title)


#' Second file
#' Retrieve filenames from shared folder in Gdrive to get the "id"
#' credentials must be entered during first run, can be stored in file .httr-oauth
gdata_url <- "https://drive.google.com/open?id=1XqfD-JOrKLGdVtAq_wNIRYYUqSdamxo2"
gdata_path <- drive_get(as_id(gdata_url))
gdata_files <- drive_ls(path = gdata_path$name, type = "pdf")
drive_deauth()

papers_ids <- gdata_files %>%
  select(filename = name) %>%
  mutate(id = stringr::str_sub(filename, 1, 3))

#' Same order than the papers
papers_ids <-  papers_ids %>% arrange(filename)

#' Final file
#' merge two previous files into the final version of papers
papers <- bind_cols(papers_ids, papers_raw)


#' Force year to be Integer
papers <- papers %>%
  mutate(year = year %>% as.integer())

papers %>% str()

#' Save for now
file_name <- "papers.csv"
data_path <- here::here("data-raw", file_name)
write_csv(papers, data_path)
devtools::use_data(papers, overwrite = TRUE)  # To check!!!

# usethis::use_package_doc()
