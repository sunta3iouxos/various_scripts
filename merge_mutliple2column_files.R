#the first line will read the directories in the working directory

for (path in list.dirs("./")[grep("GSE", list.dirs("./"))]){
# in one pipeline:
merged_file <- path %>% 
  # get csvs full paths. (?i) is for case insentitive if needed : "(?i)\\.csv$", 
#full.names = T is nescessary so that the read.table will know where to get the files from
  list.files(pattern = "\\.txt$", full.names = TRUE) %>% 
  # create a named vector: you need it to assign ids in the next step.
  # and remove file extection to get clean colnames, very nice function this one: tools::file_path_sans_ext()
  magrittr::set_names(tools::file_path_sans_ext(basename(.))) %>% 
  # read file one by one, bind them in one df and create id column 
  purrr::map_dfr(read.table, col.names = c("GeneID", "V2"), .id = "colname") %>%
  # pivot to create one column for each .id
  tidyr::pivot_wider(names_from = colname, values_from = V2)
write.table(merged_file,file.path(path,paste0(path,"_merged.txt")), sep = "\t")
}
#was found here:
#https://stackoverflow.com/questions/68397122/how-to-merge-files-in-a-directory-with-r
