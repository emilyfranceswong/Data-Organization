# The following code merges multiple data frames
# Each data frame corresponds to a psychological scale administered to patients (e.g., Becks Anxiety Inventory)
# Each patient was administered at least one psychological scale
# Goal: merge into one file with only relevant variables, one row per patient

rm(list = ls(all.names = TRUE))
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# libraries
library(readxl)
library(writexl)

# read data
file.list = list.files(path=paste0(getwd(),"/Data"), pattern='*.xlsx')
df.list <- lapply(paste0(getwd(),"/Data/",file.list), read_excel)

# read variable list
variables = read_excel("Extract Variables.xlsx")
demographics = variables[1:6,]
scales = substr(file.list,1,nchar(file.list)-5) # remove ".xlsx"

# extract relevant variables
df.list2 = list()
for(i in 1:length(scales)){
  df = df.list[[i]]
  vars = variables[variables$scale==scales[[i]],] # relevant variables for scale[i]
  df = subset(df, select=c(demographics$full_name,vars$full_name))
  names(df) = c(demographics$short_name,vars$short_name)
  df.list2[[i]] = df
}

# combine into one file, match by demographic information and id
DF = Reduce(function(dtf1, dtf2) merge(dtf1, dtf2, by = demographics$short_name, all.x = TRUE),
             df.list2)
write_xlsx(DF,"data.xlsx")


