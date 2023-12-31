library(tidyverse)
library(table1)
library(dplyr)
library(flextable)
library(magrittr)

df <- read_csv('data/cohorts/merged_cancer.csv', show_col_types = FALSE)

df$mortality_in <- factor(df$mortality_in, levels=c(1,0), labels=c("Died", "Survived"))

df$mech_vent <- factor(df$mech_vent, levels=c(1,0), labels=c("Received", "Not received"))
df$rrt <- factor(df$rrt, levels=c(1,0), labels=c("Received", "Not received"))
df$vasopressor <- factor(df$vasopressor, levels=c(1,0), labels=c("Received", "Not received"))

sub_df <- df[, c("group_solid", "group_hematological", "group_metastasized")]

df$cancer_type <- names(sub_df)[max.col(sub_df)]
df$cancer_type <- factor(df$cancer_type,
                         levels=c('group_solid', 'group_hematological', 'group_metastasized'),
                         labels=c('Solid', 'Hematological', 'Metastasized'))

label(df$cancer_type) <- "Cancer Type"

label(df$mech_vent) <- "Mechanical Ventilation"
label(df$rrt) <- "Renal Replacement Therapy"
label(df$vasopressor) <- "Vasopressor(s)"


label(df$mortality_in) <- "In-hospital Mortality"

render.categorical <- function(x, ...) {
  c("", sapply(stats.apply.rounding(stats.default(x)), function(y) with(y,
  sprintf("%s (%s%%)", prettyNum(FREQ, big.mark=","), PCT))))
}

render.strat <- function (label, n, ...) {
  sprintf("<span class='stratlabel'>%s<br><span class='stratn'>(N=%s)</span></span>", 
          label, prettyNum(n, big.mark=","))
}

tbl_pos <- table1(~ mech_vent + rrt + vasopressor 
                  | mortality_in*cancer_type, 
                  data=df, 
                  row_wise = TRUE,
                  render.missing=NULL, 
                  topclass="Rtable1-grid Rtable1-shade Rtable1-times",
                  render.categorical=render.categorical, 
                  render.strat=render.strat)

# Convert to flextable
t1flex(tbl_pos) %>% save_as_docx(path="results/positivity/5C_mort.docx")

