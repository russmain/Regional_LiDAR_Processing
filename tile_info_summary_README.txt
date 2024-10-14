## Russell Changes

blah blah


## Text File Data Extractor
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Purpose
This Python script is designed to extract specific information from text files and consolidate it into a structured CSV format. 
It's particularly useful for processing LAS INFO files and extracting relevant details such as ground points count, total number of points, and spatial extents.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Author
Author: S. Jayathunga  
Contact: sadeepa.jayathunga@scionresearch.com  
Last Updated: 01, March 2024 10:50
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Usage
Run with preprocessing.bat
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Requirements
Python 3.x
os, pandas, and argparse libraries (standard Python libraries)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Running the Script
1. Clone the Repository: Clone or download this repository to your local machine.
2. Navigate to the Directory: Open a terminal or command prompt window and navigate to the directory where the script is located.
3. Run the Script: Execute the script with the following command:

	python text_file_data_extractor.py [input_directory] [output_csv]

Replace [input_directory] with the path to the directory containing the text files from which you want to extract data.
Replace [output_csv] with the path to the output CSV file where the extracted data will be stored.

Example:

	python text_file_data_extractor.py /path/to/input/directory /path/to/output/output.csv

View the Extracted Data: Once the script finishes execution, open the generated CSV file to view the extracted data.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Script Details
The script extracts specific information from text files based on predefined target lines and their corresponding columns.
It supports the extraction of ground points count, total number of points, and spatial extents.
The extracted data is consolidated into a pandas DataFrame and then written to a CSV file.
Command-line arguments allow for customization of input and output paths.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Additional Notes
Ensure that the text files in the input directory follow the expected format for accurate extraction.
If no text files are found in the specified input directory, the script will not produce any output.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------