# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Author:   Andreas Halgreen Eiset, eiset@ph.au.dk
# Title:    Fetch and manipulate raw data for project "COVID19 in vulnerable pop in Aarhus"
# Licence:  GNU GPLv3
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

source("R/setup.R")

select <- dplyr::select

# create work data from 1 round of inclusion -------------------------

dta200422 <- read_rds(path = tmps$path_to_raw1) %>% #set path to raw data
  select(-c(record_id,
            date_inclusion,
            grep(".factor|data_entry_form", names(.)))) %>%
  mutate_at(c("born_dk", "fever", "cough_throat_pain",
              "other_symptoms", "prev_tested"),
            function(x) factor(x,
                               levels = c("0", "1"),
                               labels = c("no", "yes"))
  ) %>%
  mutate_at(vars("prev_tested_yes", "test_result"),
            function(x) factor(x,
                               levels = c("0", "1"),
                               labels = c("neg", "pos"))
  ) %>%
  mutate_if(is.factor, fct_explicit_na) %>%
  mutate(dob2 = parse_date_time2(dob, "dmy", cutoff_2000 = 40),
         age_int = interval(dob2, ymd("2020-04-12")),
         age = round(time_length(age_int, "year"), 3)) %>%
  select(-c(dob, dob2, age_int))

# create work data from second round of inclusion --------------------

dta200702 <- read_rds(path = tmps$path_to_raw2) %>%
  mutate(sex = if_else(is.na(sex_digit), NA_character_,
                       if_else(sex_digit %in% c(1, 3, 5, 7, 9), "male", "female")),
         sex_digit = NULL) %>%
  select(-c(record_id,
            grep("data_entry_form|_complete", names(.)))) %>%
  mutate(dob = parse_date_time2(dob, "dmy", cutoff_2000 = 40),
         age_int = interval(dob, ymd("2020-07-02")),
         age_true = round(time_length(age_int, "year"), 3),
         age_int_faked = interval(dob, ymd("2020-04-12")), #to get comparable age when joining the two datasets
         age_faked = round(time_length(age_int_faked, "year"), 3)) %>%
  select(-c(dob, dob2, age_int, age_int_faked))

# create data set with individuals with two or more tests ------------

dta200422_dupli <- dta200422 %>%
  group_by(sex, age, born_dk) %>%
  filter(n() >1)
###the above code works assuming there are no identical individuals given
###these three parametres. It has been manually checked

###if desired the same can be done for dat200702 i.e. work data from second
###round of inclusion

# Create data set with individuals with only one test ----------------

dta200422_uniqs <- dta200422 %>%
  distinct(sex, age, born_dk, .keep_all = TRUE)


# join the two work data sets --------------------------------------

dta_joind <- full_join(dta200422, dta200702,
                       by = c("sex",
                              "age" = "age_faked",
                              "born_dk" = "born_dk.factor")) %>%
  mutate(round_of_inc = if_else(is.na(age_true), "1", "2"))


# write working data to folder ---------------------------------------

write_rds(dta200422, path = "data/work_data_covid19_vuln_pop_aarhus200422.rds")
write_rds(dta200422_dubes, path = "data/work_data_covid19_vuln_pop_aarhus200422_dupli.rds")
write_rds(dta200422_uniqs, path = "data/work_data_covid19_vuln_pop_aarhus200422.rds")
write_rds(dta200702, path = "data/work_data2_covid19_vuln_pop_aarhus200706.rds")
write_rds(dta_joind, path = "data/work_data_full_covid19_vuln_pop_aarhus200706.rds")

