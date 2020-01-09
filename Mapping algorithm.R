library(XML)

path <- "//net1.cec.eu.int/ESTAT/B/5/B5_SHARED_DISK/SDMX/implementation/Projects/F5_Education/2019/Mapping algorithm/"
params.file.name <- "params.csv"
input.rel.path <- "Input/"
map.rel.path <- "Maps/"
templatexml.rel.path <- "Template-XML/"
output.csv.rel.path <- "Output-CSV/"
output.xml.rel.path <- "Output-XML/"

###
#Write XML function
###
#Function to write SDMX-ML file
###

write.xml <- function(input.frame, dimension.list, attribute.dataset.list, attribute.series.list, attribute.obs.list, header, opener, footer){

  input.frame[] <- lapply(input.frame, as.character)
  
  for(i in (1:ncol(input.frame))){
  
    rep.times <- nrow(input.frame[!is.na(input.frame[,i]),]) 
    input.frame[!is.na(input.frame[,i]),i] <- paste0(rep(paste0(colnames(input.frame)[i], "=", "\"") , rep.times), input.frame[!is.na(input.frame[,i]),i], rep("\"", rep.times))
    
    input.frame[is.na(input.frame[,i]),i] <- ""
    
    input.frame[,i] <- gsub("&", "&amp;", input.frame[,i])
  }
 
  attribute.dataset <- serialise(input.frame, attribute.dataset.list)
  dataset <- paste("<ns1:DataSet", attribute.dataset[1], ">", sep = " ")
  
  dataset.close <- "</ns1:DataSet>"
  
  dimensions <- serialise(input.frame, dimension.list)
  attribute.series <- serialise(input.frame, attribute.series.list)
  series <- paste("<ns1:Series", dimensions, attribute.series, ">", sep=" ")
  
  observation <- serialise(input.frame, c("TIME_PERIOD", "OBS_VALUE")) 
  attribute.obs <- serialise(input.frame, attribute.obs.list)
  obs <- paste("<ns1:Obs", observation, attribute.obs, "/></ns1:Series>", sep=" ")
  
  total <- paste0(paste0(opener, collapse = ""), paste0(header, collapse = ""), dataset, paste0(paste0(series, obs), collapse = ""), dataset.close, paste0(footer, collapse = ""))

  return(total)

}

###
#Utility function for writing XML files
###
#Utility function used by function write.xml
###

serialise <- function(input.frame, component.list) {
  
  if (length(component.list) > 1) return(apply (input.frame[, component.list], 1, paste0, collapse = " "))
  if (length(component.list) == 1) return(input.frame[, component.list])
  if (length(component.list) == 0) return("")
  
}

###
#LOAD parameters
###
#Loads the params sheet
###

print(paste("Loading parameters", Sys.time()))
      
params.file <- read.csv(paste0(path, params.file.name), sep = ";", header = FALSE, row.names = 1, na.strings = "", colClasses = "character")

DSD <- as.character(params.file[which(row.names(params.file)=="DSD"), 1])
datasetID <- as.character(params.file[which(row.names(params.file)=="datasetID"), 1])
source.year <- as.character(params.file[which(row.names(params.file)=="SourceYear"), 1])
target.year <- as.character(params.file[which(row.names(params.file)=="TargetYear"), 1])

###
#LOAD Target DSD
###
#Load target DSD and extract concept info for XML writer
###

print(paste("Loading target DSD", Sys.time()))

DSD.doc <- xmlInternalTreeParse(paste0(path, map.rel.path, DSD, "/", DSD, "_", target.year, ".xml"))

dimension.list <- xpathSApply(DSD.doc, "//structure:Dimension", xmlGetAttr, "conceptRef")
attribute.dataset.list <- xpathSApply(DSD.doc, "//structure:Attribute[@attachmentLevel = 'DataSet']", xmlGetAttr, "conceptRef")
attribute.series.list <- xpathSApply(DSD.doc, "//structure:Attribute[@attachmentLevel = 'Series']", xmlGetAttr, "conceptRef")
attribute.obs.list <- xpathSApply(DSD.doc, "//structure:Attribute[@attachmentLevel = 'Observation']", xmlGetAttr, "conceptRef")

###
#LOAD Opener&Footer
###
#Load the opener and footer for the XML files
###

print(paste("Loading XML openers and footers", Sys.time()))

con.opener <- file(paste0(path, templatexml.rel.path, "Opener.xml"), open='r')
opener <- readLines(con.opener)
close(con.opener)

con.footer <- file(paste0(path, templatexml.rel.path, "Footer.xml"), open='r')
footer <- readLines(con.footer)
close(con.footer)

###
#LOAD and edit header
###
#Load and edit the header of the XML file
###

print(paste("Loading header", Sys.time()))

header.doc <- xmlInternalTreeParse(paste0(path, templatexml.rel.path, "Header.xml"))

xpathSApply(header.doc, "//message:Header/message:ID", `xmlValue<-`, value = paste0(datasetID, "_", source.year))
xpathSApply(header.doc, "//message:Header/message:KeyFamilyRef", `xmlValue<-`, value = DSD)
xpathSApply(header.doc, "//message:Header/message:DataSetID", `xmlValue<-`, value = DSD)

header <- toString.XMLNode(getNodeSet(header.doc, "//message:Header")[[1]])

###
#LOAD Code Maps
###
#Loads the code maps available for the tranformation. Code maps are built as follows:
# -First, the source combinations are loaded
# -Then, the target combinations are loaded
#The source and target combinations are then merged in the same dataframe. To be able to distinguish the source columns and target columns
#the string ".SOURCE" and ".TARGET" respectively is appended to the column names. 
###

print(paste("Loading code maps", Sys.time()))

code.map.list <- list.dirs(path = paste0(path, map.rel.path, DSD, "/Code_maps"), full.names = TRUE, recursive = FALSE)

code.map <- lapply(code.map.list, function(x){
  
  source.code <- read.csv(paste0(x,"/Code_",source.year,".csv"), sep = ";", na.strings = "", colClasses = "character")
  colnames(source.code) <- paste(colnames(source.code),"SOURCE", sep = ".")
  
  target.code <- read.csv(paste0(x,"/Code_",target.year,".csv"), sep = ";", na.strings = "", colClasses = "character")
  colnames(target.code) <- paste(colnames(target.code), "TARGET", sep = ".")
  
  return(cbind(source.code, target.code))
  
})

###
#LOAD Concept Maps
###
#The concept maps (i.e. where the concept names have changed but not the content) are loaded. The source column names are loaded first, followed
#by the corresponding target names. Both the source.concept and target.concept objects are a simple single column dataframe,
#with one concept name per row.
###

print(paste("Loading concept maps", Sys.time()))

source.concept <- read.csv(paste0(path, map.rel.path, DSD, "/Concept_Maps/Concepts_",source.year,".csv"), sep = ";", na.strings = "", colClasses = "character")
target.concept <- read.csv(paste0(path, map.rel.path, DSD, "/Concept_Maps/Concepts_",target.year,".csv"), sep = ";", na.strings = "", colClasses = "character")

###
#LOAD list of input files
###
#Loads the list of available input files and initialise loop
###

input.file.list <- list.files(paste0(path, input.rel.path), pattern = ".+(\\.csv)$")

for (j in (1:length(input.file.list))) {

###
#LOAD input data
###
# Loads the input data to be used in the transformation
###

print(paste("Loading file", input.file.list[j], Sys.time()))
  
input.file <- read.csv(paste0(path, input.rel.path, input.file.list[j]), sep = ";", na.strings = "", colClasses = "character")

###
#INITIALISE output file
###
#The output file is initialised by:
# -Copying the input file
# -Appending ".SOURCE" to the column names, to show that they refer to the source columns.
###

print(paste("Initialising output file", Sys.time()))

output.file <- input.file
colnames(output.file) <- paste(colnames(output.file),"SOURCE", sep = ".")

###
#APPLY Code Maps
###
#Code maps are applied by simply doing a left join on between the outptu file and the code maps. After each join, the source columns
#in the code map are removed from the output file.
#Once all code maps are applied, the ".SOURCE" and ".TARGET" affixes are removed.
###

print(paste("Applying code maps", Sys.time()))

for (i in 1:length(code.map)){
  output.file <- merge(output.file, code.map[[i]], all.x = TRUE)
  source.columns <- colnames(code.map[[i]])[grep(".SOURCE", colnames(code.map[[i]]))]
  output.file <- output.file[, - which(source.columns %in% colnames(output.file))]
}

colnames(output.file) <- gsub(".SOURCE", "", colnames(output.file))
colnames(output.file) <- gsub(".TARGET", "", colnames(output.file))

###
#APPLY Concept Map
###
#The concept map is applied by changing the source column names to the target column names
###

print(paste("Applying concept maps", Sys.time()))

for(i in 1:nrow(source.concept)) colnames(output.file) <- gsub(source.concept$Concept[i], target.concept$Concept[i], colnames(output.file))

###
#WRITE output csv
###
#Write the output file in CSV format
###

print(paste("Writing output CSV", Sys.time()))

write.table(output.file, file = paste0(path, output.csv.rel.path, input.file.list[j]), sep=";", row.names = FALSE, na = "")

###
#WRITE output xml
###
#Write the output file in XML format
###

print(paste("Formatting output XML", Sys.time()))

output.xml <- write.xml(output.file, dimension.list, attribute.dataset.list, attribute.series.list, attribute.obs.list, header, opener, footer)

print(paste("Writing output XML", Sys.time()))

cat(output.xml, file=paste0(path, output.xml.rel.path, gsub(".csv", ".xml", input.file.list[j])))

}
