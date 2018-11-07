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


gdata_file <- drive_ls(path = gdata_path$name, pattern = "selected_papers.bib") #type = "application/x-bibtex")
drive_deauth()

data_path <- here::here("data-raw", gdata_file$name) # local file
drive_download(file = gdata_file$id, path = data_path, overwrite = TRUE, verbose = TRUE)


file_name = "selected_papers.bib";
data_path <- here::here("data-raw", file_name) # local file
# Import the local bibtex file and convert it to a tibble
papers_raw <- RefManageR::ReadBib(data_path, check = "warn", .Encoding = "UTF-8") %>%
  as.data.frame() %>% as_tibble()

# for the time being, turn rownames into a column
papers_raw <- rownames_to_column(papers_raw, "bibtextId")

papers_raw %>% str()

#' Get rid of vars I will not use, rename vars I keep
papers <- papers_raw %>%
  select(type = bibtype, title, abstract, journal, author, year, keywords)

#' Get rid of curly brackets and extra quotation marks in titles
papers$title <- stringr::str_replace_all(papers$title, "[\"|{|}]", "")

papers <- papers %>%
  arrange(title)


#' Second file
#' Retrieve filenames from shared folder in Gdrive to get the "id"
#' credentials must be entered during first run, can be stored in file .httr-oauth
gdata_url <- "https://drive.google.com/open?id=1XqfD-JOrKLGdVtAq_wNIRYYUqSdamxo2"
gdata_path <- drive_get(as_id(gdata_url))
gdata_files <- drive_ls(path = gdata_path$name, type = "pdf")
drive_deauth()

gdata_files <- gdata_files %>%
  select(filename = name) %>%
  mutate(id = stringr::str_sub(filename, 1, 3))

#' Same order than the papers
papers_ids <-  gdata_files %>% arrange(filename)

#' Final file
#' merge two previous files into the final version of papers
papers_final <- bind_cols(papers_ids, papers)


#' Force year to be Integer
papers_final <- papers_final %>%
  mutate(year = year %>% as.integer())

papers_final %>% str()

#' Save for now
file_name <- "papers.csv"
data_path <- here::here("data-raw", file_name)
write_csv(papers_final, data_path)
devtools::use_data(papers, overwrite = TRUE)

