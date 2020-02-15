# Purpose
This GitHub repository contains a script to transcode UOE questionnaire files between different DSD versions. The script takes a CSV file structured according to a source DSD version (2017 or 2019) UOE DSDs and transcodes it to a target DSD version. It provides both a CSV and an SDMX-ML Compact output.

# Requirements
In order to run the programme, you will need:
* An installation of R on your PC (version 3.3.1 or above).
* Downloading and installing the external XML package for R

# Description of the contents of the programme
The programme downloaded contains the following elements:
* _Mapping Algorithm.R script_: this is the file containing the R script which transcodes the the input files structured according to a source DSD version into files strcutures according to a target DSD version.
* _params.csv file_: this file contains set of parameters needed by the script - the code of the questionnaire to be transcoded, the name of the DSD to be used, the source DSD version and the target DSD version.
* _Input folder_: this folder contains the input CSV files structured according to the source DSD. The GitHub repository contains a sample input file.
* _Output-CSV folder_: this folder is the place where the R script will generate the transcoded files in CSV format. The GitHub repository contains a sample output file.
* _Output-XML folder_: this folder is the place where the R script will generate the transcoded files in SDMX-ML Compact format. The GitHub repository contains a sample output file.
* _Maps and Template-XML folders_: these folders contain all the information needed by the script in order to apply the correct transcoding and generate correct SDMX-ML files.

# Configuring the programme to run correctly on your computer
Once you have downloaded and unzipped the contents of this GitHub repository on your own computer, you must tell the R script where you have unzipped the programme so that it knows where it can find the different input / output folders it expects.

To do this, open the *Mapping Algorithm.R* script with any text editor. At the beginning of the script, you will find a variable called *path ← "....."* (see screenshot below). Replace the default value of path with the path to the working directory you have unzipped the programme in and save the file.

![alt text](https://github.com/LucaGramaglia/UOE-Transcoding/blob/master/Images/path.jpg "Path screenshot")

The *params.csv* file also contains some parameters that need to be set prior to running the script:
* _DSD_: The ID of the DSD to be used must be provided. There are two possible values: UOE_NON_FINANCE and UOE_FINANCE.
* _datasetID_: The ID of the questionnaire must be provided. Possible values are ENRL, ENTR, PERS, DEM, CLASS, GRAD, and FIN.
* _SourceYear_: The year indicating the source DSD version to be used (i.e. the version of the DSD according to which the input files are structured). Possible values are 2017 and 2019.
* _TargetYear_: The year indicating the source DSD version to be used (i.e. the version of the DSD according to which the output files are structured). Possible values are 2017 and 2019.
* _CSVoutput (optional)_: Boolean value indicating whether the script should output the transcoded file in CSV format. The default value is TRUE.
* _XMLoutput (optional)_: Boolean value indicating whether the script should output the transcoded file in SDMX-ML format. The default value is TRUE.

# How to use the programme
To use the programme, the user simply needs to drop one or more files structured according to source DSD indicated in the _params.csv_ file in the *Input* folder. You can then run the *Mapping Algorithm.R* script. In order to do this, open your R application and type the source command: *source(yourpath/Mapping Algorithm.R)*. See screenshot below.

![alt text](https://github.com/LucaGramaglia/UOE-Transcoding/blob/master/Images/source.jpg "R screenshot")

The script will generate the transcoded files in CSV format in the _Output-CSV_ folder and in SDMX-ML Compact format in the _Output-XML_ folder. 

# Potential improvements
One possible improvement is the use of a yaml file rather than a CSV file for the parameters. This would however add a dependency on the external yaml package for R.

Error messages and validation of the input parameters could also be improved.

