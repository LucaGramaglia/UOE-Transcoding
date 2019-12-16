# Purpose
This GitHub repository contains a script to transcode UOE questionnaire files between different DSD versions. The script takes a CSV file structured according to a source DSD version (2017 or 2019) UOE DSDs and transcodes it to a target DSD version. It provides both a CSV and an SDMX-ML Compact output.

# Requirements
In order to run the programme, you will need:
*An installation of R on your PC (version 3.3.1 or above).
*Downloading and installing the external XML package for R

# Description of the contents of the programme
The programme downloaded contains the following elements:
* _Splitting_script.R script_: this is the file containing the R script which splits the input files structured according to the REGWEB DSD into separate files for the Transport Information System.
* _Parameters folder_: this folder contains a couple of files where certain parameters used by the script can be set.
* _Input folder_: this folder contains the input CSV files strcutured according to the REGWEB DSD. The GitHub repository contains a sample input file.
* _Output folder_: this folder if the place where the R script will generate the files split by regional transport indicator, as expected by the Transport Information System. The GitHub repository contains some sample output files.

# Configuring the programme to run correctly on your computer
Once you have downloaded and unzipped the contents of this GitHub repository on your own computer, you must tell the R script where you have unzipped the programme so that it knows where it can find the different input / output folders it expects.

To do this, open the *Splitting_script.R* script with any text editor. At the beginning of the script, you will find a variable called *path ← "....."* (see screenshot below). Replace the default value of path with the path to the working directory you have unzipped the programme in and save the file.

![alt text](https://github.com/LucaGramaglia/REGWEB-Scripts/blob/master/Images/path_screenshot.jpg "Path screenshot")

The *Parameters* folder also contains some files that can be used to change certain configurations:
* In the *params.csv* file, the user can indicate which column contains the indicator codes in the input file.
* The *Mapping.csv* file maps the indicator codes to the corresponding EDAMIS dataset names.

These parameter files will however not require tweaking unless changes are made to the REGWEB DSD or to EDAMIS dataset names.

# How to use the programme
To use the programme, the user simply needs to drop one or more files strcutured according to the REGWEB DSD in the *Input* folder. You can then run the *Splitting_script.R* script. In order to do this, open your R application and type the source command: *source(yourpath/Splitting_script.R)*. See screenshot below.

![alt text](https://github.com/LucaGramaglia/REGWEB-Scripts/blob/master/Images/path_R.jpg "R screenshot")

The script will generate the files split according to the needs of the Transport Information System in the *Output* folder. 

# Potential improvements
One possible improvement is the use of a yaml file rather than a CSV file for the parameters. This would however add a dependency on the external yaml package for R.

Error messages and validation of the input parameters could also be improved.

