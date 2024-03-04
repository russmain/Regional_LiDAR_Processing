# Pre-processing Batch Script
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Purpose
This batch script is designed for pre-processing LiDAR point cloud data. 
It provides flexibility for users to choose from various pre-processing steps, including tiling, ground classification, noise filtering, normalization, and more.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Author
Author: S. Jayathunga  
Contact: sadeepa.jayathunga@scionresearch.com  
Last Updated: 01, March 2024 10:50
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Usage
1. Ensure that LAStools are added to the system PATH for easy access.
2. Set up Python environment and install required modules (`pandas`, `re`).
3. Set the input and output directories, and provide site information when prompted.
4. Choose the pre-processing steps you want to perform by answering the prompts.
5. Review and confirm the processing parameters.
6. The script will execute the chosen steps and generate log files to track progress.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Running the Script

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Requirements
- LAStools installed and added to system PATH.
- Python environment with required modules (`pandas`, `re`).
- LiDAR point cloud data in LAS or LAZ format.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Dependencies
This batch script depends on two Python scripts:

1. move_files.py: This script is responsible for moving intermediate results to a specified destination directory to free up space.
Installation: Ensure that Python environment is set up and pandas and re modules are installed.
Usage: Call move_files.py with appropriate arguments to move files as required.

2. tile_info_summary.py: This script summarizes LAS INFO of all tiles to a spreadsheet.
Installation: Ensure that Python environment is set up and pandas and re modules are installed.
Usage: Call tile_info_summary.py with input and output paths to generate the spreadsheet.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Notes
- Ensure that input and output directories are correctly specified to avoid errors.
- Monitor log files (`log_preprocessing_SITE.txt`) for processing progress and any errors encountered.
- Intermediate results may be moved to a specified destination directory if chosen by the user.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Acknowledgments
This script utilizes LAStools batch processing scripts available at: [LAStools GitHub](https://github.com/LAStools/LAStools/tree/master/example_batch_scripts)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

