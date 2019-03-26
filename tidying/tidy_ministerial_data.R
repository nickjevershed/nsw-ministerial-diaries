#' cleans up nsw ministerial diary data from nick everhshed and writes to compressed csv
#' 
#' https://github.com/nickjevershed/nsw-ministerial-diaries
#' 


# Libraries ---------------------------------------------------------------

library(tidyverse) 
library(janitor)
library(lubridate)
library(padr)

# Gather ------------------------------------------------------------------

# read from nick's github repo
nsw_data_raw_tbl <- read_csv("https://raw.githubusercontent.com/nickjevershed/nsw-ministerial-diaries/master/diaries-cleaned.csv")

# Condition ---------------------------------------------------------------


#nsw_data_clean_tbl <- nsw_data_raw_tbl %>%
conditioned_tbl <- nsw_data_raw_tbl %>%
  
  # clean variable names
  clean_names() %>%
  
  # there's a record with "policy" in the date and I cannot interpretate it so it's being dropped 
  filter(
    date != "Policy"
  ) %>%
  
  # manually clean up the dates which won't parse via lubridate::dmy()
  mutate(
    date = case_when (
      date == "/08/2017" ~ "01/08/2017",
      date == "0/11/2016" ~ "01/11/2016",
      date == "16/5/17 & \n19/6/19 & \n23/6/17" ~ "16/5/2017",
      date == "18/05/2017 \n18/05/2017" ~ "18/05/2017",
      date == "2\n5/10/2017" ~ "05/10/2017",
      TRUE ~ date
    )
  ) %>%
  
  # now condition the main set of data 
  
  # cast to date format
  mutate(
    date= dmy(date)
  ) %>%
  
  # remove null dates
  drop_na(date) %>%
  
  # tidy minister
  mutate(
    minister = str_remove(minister, "-Disclosure-Summaryyt"),
    minister = str_remove(minister, "-Disclosure-Summary"),
    minister = str_remove(minister, "ile$"),
    minister = str_remove(minister, "ch$"),
    minister = str_remove(minister, "^\\d+-"),
    minister = str_remove(minister, "-\\d+$"),
    minister = str_remove(minister, "oberember$"), 
    minister = str_remove(minister, "uary$"),
    minister = str_remove(minister, "ytember$"),
    minister = str_remove(minister, "-1il-30e$"),
    minister = str_remove(minister, "itime"),
    minister = str_remove(minister, "_Jan"),
    minister = str_remove(minister, "oberember_2017$"),
    minister = str_remove(minister, "oberember_2017-v2$"),
    minister = str_remove(minister, "_Jul$"),
    minister = str_remove(minister, "-July-2018-September$"),
    minister = str_remove(minister, "sober-Dcember$"),
    minister = str_remove(minister, "ile-v2$"),
    minister = str_remove(minister, "yt$"),
    minister = str_remove(minister, "-$"),
    minister = str_remove(minister, "-1$"),
    minister = str_remove(minister, "-1y-30t$"),
    minister = str_replace(minister, "Resear$", "Research"),
    minister = str_replace(minister, "Foresty", "Forestry"),
    minister = str_replace(minister, "Service$", "Services"),
    minister = str_replace(minister, "and-and", "and")
  ) %>%
  
  # strip out unneccesary "-and-" 
  mutate(
    minister = str_replace_all(minister, "-and-", "-")
  ) %>%
  
  # replace analagous terms 
  mutate(
    minister = case_when (
      minister == "Minister-for-Early-Childhood-Education-Aboriginal-Affairs-Assistant-Minister-for-education" ~ "Minister-for-Early-Childhood-Education-Aboriginal-Affairs-Assistant-Minister-for-Education",
      minister == "Minister-for-FaCS-Social-Housing-the-Prevention-of-Domestic-Violence-Sexual-Assault" ~ "Minister-for-Family-Community-Services-Minister-for-Social-Housing-Minister-for-Prevention-of-Domestic-Violence-Sexual-Assault",
      minister == "Minister-for-Finances-Services" ~ "Minister-for-Finance-Services",
      minister == "Minister-for-Police-Emeregency-Services" ~ "Minister-for-Police-Emergency-Services" ,
      minister == "Minister-for-the-Enivronment" ~ "Minister-for-the-Environment" ,
      minister == "Minister-for-Primary-Industries-Land-Water"  ~ "Minister-for-Primary-Industries-Lands-Water",
      minister == "Minister-for-Mental-health-Women-Ageing" ~ "Minister-for-Mental-Health-Women-Ageing",
      minister == "Minister-for-Police-Emeregency-Services" ~ "Minister-for-Police-Emergency-Services",
      minister == "Minister-for-the-Enivronment-Heritage-Assistant-Minister-for-Planning"  ~ "Minister-for-the-Environment-Heritage-Assistant-Minister-for-Planning"  ,
      minister == "Minister-for-Family-Community-Services-Minister-for-Social-Housing-Minister-for-Prevention-of-DV-SA" ~ "Minister-for-Family-Community-Services-Minister-for-Social-Housing-Minister-for-Prevention-of-Domestic-Violence-Sexual-Assault",
      TRUE ~ minister
    )
  ) %>%

  # augment time series
  mutate(
    year = year(date),
    month_name = month(date, label=TRUE, abbr = FALSE),
    month = month(date),
    week = week(date),
    day = day(date),
    day_name = wday(date, label = TRUE, abbr=FALSE),
    quarter = quarter(date)
  )  


# save to csv
write_csv(conditioned_tbl, "tidying/diaries-tidied.csv.gz")


