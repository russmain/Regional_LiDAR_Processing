# Periodic File Mover Script
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Purpose
This Python script facilitates the periodic movement of files from a source directory to a specified destination directory. 
It is particularly useful for managing intermediate results during the point cloud preprocessing step.
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
os and shutil libraries (standard Python libraries)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Running the Script
1. Clone the Repository: Clone or download this repository to your local machine.
2. Navigate to the Directory: Open a terminal or command prompt window and navigate to the directory where the script is located.
3. Run the Script: Execute the script with the following command:	

	python periodic_file_mover.py [source_directory] [destination_directory] [--exclude_list EXCLUDE_LIST]

Replace [source_directory] with the path to the source directory containing the files you want to move periodically.
Replace [destination_directory] with the path to the destination directory where the files will be moved.
Optionally, you can specify directories to exclude from moving using the --exclude_list argument. Provide a list of directory names separated by spaces.

Example:
	python periodic_file_mover.py /path/to/source /path/to/destination --exclude_list dir1 dir2

Do Not Close the Window: Once the script starts executing, do not close the terminal or command prompt window. 
The script will continue moving files periodically until the point cloud processing is completed.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Script Details
The script periodically moves files from the source directory to the destination directory, ensuring that intermediate results are managed effectively.
It handles permission errors and retries moving files after a specified interval if necessary.
Excluded directories can be specified to prevent certain directories from being moved.
The script creates a sentinel file named sentinel.txt in the source directory to initiate the moving process. 
It continues moving files until the completed.txt file is detected in the source directory.
Upon completion, the sentinel file is removed from the destination directory.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------