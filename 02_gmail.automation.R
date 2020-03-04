##-GOOGLE TRENDS AUTOMATION--

#CRON JOB

#1.0 LIBRARIES

#GMAIL API
install.packages("gmailr")
library(gmailr)

#Report Automation
install.packages("rmarkdown")
library(rmarkdown)

#Core

library(tidyverse)
library(lubridate)

#File System
library(fs)

# 2.0 KEY PARAMETERS

# 2.1 Report Parameters

search_terms <- c("aws", "azure", "google cloud")

#search_terms <- c("docker", "git")

# 2.2 Email Parameters

to      <- "aremif03@gmail.com"
subject <- "Google Trends"
body    <- str_glue("
Hey Remi,

Find below detailed report on Google Trends Keywords: {str_c(search_terms, collapse = ', ')}


Best Regards

Ade")


# 3.0 REPORT AUTOMATION
install.packages("devtools")
library(devtools)
install_version("rmarkdown", version = "1.8", repos = "http://cran.us.r-project.org")
library(rmarkdown)
devtools::install_github("tinytex")
library(tinytex)

file_path <- now() %>%
  str_replace_all("[[:punct:]]", "_") %>%
  str_replace(" ", "T") %>%
  str_c("_trends_report.pdf")

#params = list("etfnumber" = c(1:5))
#attr(params, 'class') = "knit_param_list"

rmarkdown::render(
  input            = "C:/Users/Remi_Adefioye/Documents/google_trends/google_trends_report_template.Rmd",
  output_format    = "pdf_document",
  output_file      = file_path,
  output_dir       = "reports",
  knit_root_dir    = NULL,
  params           = list(search_terms = "search_terms"),  
  envir            = parent.frame(),
  run_pandoc       = TRUE, 
  quiet            = FALSE, 
  encoding         = getOption("encoding")
)


# 4.0 GMAIL API AUTOMATION
# Must register an app with the Google Developers consule
#gmailr Instructions: https://github.com/r-lib/gmailr
#  - Make an App: https://developers.google.com/gmail/api/quickstart/python
#  - Run remotely: https://gargle.r-lib.org/articles/non-interactive-auth.html


# Download Gmail App Credentials & Configure App
gm_auth_configure(path = "C:/Users/Remi_Adefioye/google_trends/credentials.json") #Replace path to app credentials

#Authorize your gmail account
gm_auth(email = "aremif03@gmail.com") # Replace email account


# Create email
email <- gm_mime() %>%
  gm_to(to) %>%
  gm_from("aremif03@gmail.com") %>%
  gm_cc("") %>%
  gm_subject(subject)  %>%
  gm_text_body(body) %>%
  gm_attach_file(str_c("reports/"), file_path)

gm_send_message(email, user_id = "me")

