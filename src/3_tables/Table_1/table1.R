# Code for creating Table 1 in MIMIC data
library(tidyverse)
library(table1)
library(flextable)

df <- read_csv('data/cohorts/merged_all.csv', show_col_types = FALSE)

df$los_icu_dead <- df$los_icu
df <- df %>% mutate(los_icu_dead = ifelse(mortality_in == 1, los_icu_dead, NA))

df$los_icu_survived <- df$los_icu
df <- df %>% mutate(los_icu_survived = ifelse(mortality_in == 0, los_icu_survived, NA))

df$sex_female <- factor(df$sex_female, levels=c(1,0), labels=c("Female", "Male"))
df$mortality_in <- factor(df$mortality_in, levels=c(1,0), labels=c("Died", "Survived"))
df$has_cancer <- factor(df$has_cancer, levels=c(1,0), labels=c("Cancer", "Non-Cancer"))

df$mv_elig <- factor(df$mv_elig, levels=c(1,0), labels=c("Received", "Not received"))
df$rrt_elig <- factor(df$rrt_elig, levels=c(1,0), labels=c("Received", "Did not receive"))
df$vp_elig <- factor(df$vp_elig, levels=c(1,0), labels=c("Received", "Not received"))

df$is_full_code_admission <- factor(df$is_full_code_admission, levels=c(0,1), labels=c("Not Full Code", "Full Code"))
df$is_full_code_discharge <- factor(df$is_full_code_discharge, levels=c(0,1), labels=c("Not Full Code", "Full Code"))

df$age_ranges <- df$anchor_age
df$age_ranges[df$anchor_age >= 18 & df$anchor_age <= 44] <- "18 - 44"
df$age_ranges[df$anchor_age >= 45 & df$anchor_age <= 64] <- "45 - 64"
df$age_ranges[df$anchor_age >= 65 & df$anchor_age <= 74] <- "65 - 74"
df$age_ranges[df$anchor_age >= 75 & df$anchor_age <= 84] <- "75 - 84"
df$age_ranges[df$anchor_age >= 85] <- "85 and higher"

# Cohort of Source
df <- df %>% mutate(source = ifelse(source == "mimic", 1, 0))

# Cancer Categories
df <- df %>% mutate(group_solid = ifelse(group_solid == 1, "Present", "Not Present"))
df <- df %>% mutate(group_hematological = ifelse(group_hematological == 1, "Present", "Not Present"))
df <- df %>% mutate(group_metastasized = ifelse(group_metastasized == 1, "Present", "Not Present"))

# Cancer Types
df <- df %>% mutate(loc_colon_rectal = ifelse(loc_colon_rectal == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_liver_bd = ifelse(loc_liver_bd == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_pancreatic = ifelse(loc_pancreatic == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_lung_bronchus = ifelse(loc_lung_bronchus == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_melanoma = ifelse(loc_melanoma == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_breast = ifelse(loc_breast == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_endometrial = ifelse(loc_endometrial == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_prostate = ifelse(loc_prostate == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_kidney = ifelse(loc_kidney == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_bladder = ifelse(loc_bladder == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_thyroid = ifelse(loc_thyroid == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_nhl = ifelse(loc_nhl == 1, "Present", "Not Present"))
df <- df %>% mutate(loc_leukemia = ifelse(loc_leukemia == 1, "Present", "Not Present"))

# Get data into factor format
df$source <- factor(df$source, levels = c(1, 0), 
                        labels = c('MIMIC', 'eICU'))

df$hypertension_present <- factor(df$hypertension_present, levels = c(0, 1), 
                        labels = c('Hypertension absent', 'Hypertension present'))

df$heart_failure_present <- factor(df$heart_failure_present, levels = c(0, 1), 
                        labels = c('CHF absent', 'CHF present'))

df$copd_present <- factor(df$copd_present, levels = c(0, 1), 
                        labels = c('COPD absent', 'COPD present'))

df$asthma_present <- factor(df$asthma_present, levels = c(0, 1), 
                        labels = c('Asthma absent', 'Asthma present'))

df$ckd_stages <- factor(df$ckd_stages, levels = c(0, 1),
                        labels = c("CKD Absent", "CKD Present"))

df$cancer_type <- 0
df$cancer_type[df$group_solid == "Present"] <- 1
df$cancer_type[df$group_metastasized == "Present"] <- 2
df$cancer_type[df$group_hematological == "Present"] <- 3

df$cancer_type <- factor(df$cancer_type, levels = c(1, 2, 3), 
                        labels = c('Solid cancer', 'Metastasized cancer', 'Hematological cancer'))

# Factorize and label variables
label(df$age_ranges) <- "Age by group"
units(df$age_ranges) <- "years"

label(df$anchor_age) <- "Age overall"
units(df$anchor_age) <- "years"

label(df$sex_female) <- "Sex"
label(df$SOFA) <- "SOFA continuous"

label(df$los_icu_dead) <- "Length of stay if died"
units(df$los_icu_dead) <- "days"
label(df$los_icu_survived) <- "Length of stay if survived"
units(df$los_icu_survived) <- "days"

label(df$has_cancer) <- "Cancer Present"

label(df$charlson_cont) <- "Charlson Comorbidity Index"

label(df$mv_elig) <- "Mechanic Ventilation"
label(df$rrt_elig) <- "Renal Replacement Therapy"
label(df$vp_elig) <- "Vasopressor(s)"

label(df$mortality_in) <- "In-hospital Mortality"
label(df$source) <- "Database"

label(df$group_solid) <- "Solid Cancer"
label(df$group_hematological) <- "Hematological Cancer"
label(df$group_metastasized) <- "Metastasized Cancer"

label(df$loc_breast) <- "Breast"
label(df$loc_prostate) <- "Prostate"
label(df$loc_lung_bronchus) <- "Lung (including bronchus)"
label(df$loc_colon_rectal) <- "Colon and Rectal (combined)"
label(df$loc_melanoma) <- "Melanoma"
label(df$loc_bladder) <- "Bladder"
label(df$loc_kidney) <- "Kidney"
label(df$loc_nhl) <- "NHL"
label(df$loc_endometrial) <- "Endometrial"
label(df$loc_leukemia) <- "Leukemia"
label(df$loc_pancreatic) <- "Pancreatic"
label(df$loc_thyroid) <- "Thyroid"
label(df$loc_liver_bd) <- "Liver and intrahepatic BD"

label(df$hypertension_present) <- "Hypertension"
label(df$heart_failure_present) <- "Heart Failure"
label(df$copd_present) <- "COPD"
label(df$asthma_present) <- "Asthma"
label(df$ckd_stages) <- "CKD"

label(df$is_full_code_admission) <- "Full Code upon Admission"
label(df$is_full_code_discharge) <- "Full Code upon Discharge"

label(df$race_group) <- "Race"

render.categorical <- function(x, ...) {
  c("", sapply(stats.apply.rounding(stats.default(x)), function(y) with(y,
  sprintf("%s (%s%%)", prettyNum(FREQ, big.mark=","), PCT))))
}

render.strat <- function (label, n, ...) {
  sprintf("<span class='stratlabel'>%s<br><span class='stratn'>(N=%s)</span></span>", 
          label, prettyNum(n, big.mark=","))
}

# Create Table1 Object
tbl1 <- table1(~ mortality_in + los_icu_dead + los_icu_survived +
               mv_elig + rrt_elig + vp_elig + source +
               age_ranges + anchor_age + sex_female + race_group + 
               SOFA + charlson_cont +
               is_full_code_admission + is_full_code_discharge +
               hypertension_present + heart_failure_present +
               asthma_present + copd_present + ckd_stages + 
               group_solid + group_hematological + group_metastasized +
               loc_colon_rectal + loc_liver_bd + loc_pancreatic +
               loc_lung_bronchus + loc_melanoma + loc_breast +
               loc_endometrial + loc_prostate + loc_kidney +
               loc_bladder + loc_thyroid + loc_nhl + loc_leukemia
               | has_cancer,
               data=df,
               render.missing=NULL,
               topclass="Rtable1-grid Rtable1-shade Rtable1-times",
               render.categorical=render.categorical,
               render.strat=render.strat,
               render.continuous=c(.="Mean (SD)", .="Median (Q1, Q3)")
              )


# Convert to flextable
t1flex(tbl1) %>% save_as_docx(path="results/table1/1A_by_cancer.docx")

# Create Table1 Object
tbl1 <- table1(~ mortality_in + los_icu_dead + los_icu_survived +
               mv_elig + rrt_elig + vp_elig + has_cancer +
               age_ranges + anchor_age + sex_female + race_group + 
               SOFA + charlson_cont +
               is_full_code_admission + is_full_code_discharge +
               hypertension_present + heart_failure_present +
               asthma_present + copd_present + ckd_stages + 
               group_solid + group_hematological + group_metastasized +
               loc_colon_rectal + loc_liver_bd + loc_pancreatic +
               loc_lung_bronchus + loc_melanoma + loc_breast +
               loc_endometrial + loc_prostate + loc_kidney +
               loc_bladder + loc_thyroid + loc_nhl + loc_leukemia
               | source,
               data=df,
               render.missing=NULL,
               topclass="Rtable1-grid Rtable1-shade Rtable1-times",
               render.categorical=render.categorical,
               render.strat=render.strat,
               render.continuous=c(.="Mean (SD)", .="Median (Q1, Q3)")
              )

# Convert to flextable
t1flex(tbl1) %>% save_as_docx(path="results/table1/1B_by_database.docx")



