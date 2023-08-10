# The following code merges 25 disparate data frames
# Each data frame corresponds to a psychological scale administered to patients (e.g., Becks Anxiety Inventory)
# Each patient was administered at least one psychological scale
# Goal: merge into one file with only relevant variables, one row per patient
# Sub-goals: get rid of duplicate or complex records (due to technical error), shorten variable names for MPlus.

# clear work space
rm(list = ls(all.names = TRUE))
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# load data frames (psychological scale data; stored in folder titled "files")
wd = getwd()
files = list.files(path=paste0(wd,'/files'),pattern='*.xlsx',full.names=TRUE)
DF.list = lapply(files,read_excel)

# scale names
scale_names = gsub("/your_path/files/","",files)
scale_names = gsub(".xlsx","",scale_names)

variables = read_excel("Extract Variables.xlsx")
keep_variables = variables$full_name
delete_demographic_variables = c("GUID","CLINIC","RACE_OTHX","TESTDATE","VISITNUM","VISITNAME","FORMSTATUS")

for(i in 1:length(DF.list)){
  DF.list[[i]]$TESTDATE = as.Date(DF.list[[i]]$TESTDATE)
  DF.list[[i]] = DF.list[[i]][, !(colnames(DF.list[[i]]) %in% delete_demographic_variables)] # remove above variables in each file
}

# combine data frames by demographic information (e.g., patient id, age, etc.)
DF = DF.list[[1]]
for(i in 2:length(DF.list)){
  DF = merge(DF,DF.list[[i]],by=c("PATIENTID","AGE","OLDERTHAN90","SEX","RACE","ETHNICITY"),all=TRUE)
}

length(unique(DF$PATIENTID)) # number of unique PTID's

DF = DF[keep_variables]  # keep only required variables
DF = dplyr::distinct(DF) # keep only distinct rows (occasional accidental repeats)

n_occur = data.frame(table(DF$PATIENTID))
complex_repeats = n_occur[n_occur$Freq > 1,]  # patients who had multiple records due to technical error (e.g., had to restart)
colnames(complex_repeats) = c("PTID","nrows") # for patients w/ multiple records, log number of records

DF = DF[!DF$PATIENTID %in% complex_repeats$PTID,] # remove patient records with above [complex] records 
length(unique(DF$PATIENTID))

colnames(DF) = variables$short_name # shorten variable names for MPlus

write_xlsx(DF,'data.xlsx')


