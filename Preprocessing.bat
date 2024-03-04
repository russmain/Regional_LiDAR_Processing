:: =============================================================================
:: Purpose:
:: This is a multi-core batch script for pre-processing LiDAR file(s).
:: Steps:
:: User has the flexibilty to choose the pre-processing steps that needs to be
:: peformed. The list of tasks available includes tiling, ground classifying, 
:: isolating ground points, noise filtering, ground normalizing and cleaning 
:: extremes outside the specified range and spatial indexing inputs and results. 
:: Base scripts of LAStools adopted from 
:: "https://github.com/LAStools/LAStools/tree/master/example_batch_scripts" 
:: Author:
:: S. Jayathunga (sadeepa.jayathunga@scionresearch.com)©
:: Last updated and tested: 
:: 01, March 2024 10:50
:: =============================================================================

:: This is run to turn off the echoing of commands. So, the script itself will 
:: not display each command before executing it, making the script output 
:: cleaner and reducing the unnecessary information displayed to the user.
echo off

:: This enables delayed variable expansion, thus the variables are expanded at 
:: runtime rather than when the lines of code are parsed. It is useful as this
:: script contains loops or blocks of code, where the updated values of 
:: variables are accessed within the loop or block.
setlocal EnableDelayedExpansion

:: Requirement1- Adding LAStools in PATH enables the user to run the script 
:: from anywhere. However, this lines needs to be run ONLY when the path is not 
:: set in Environment variables. To ensure this, get the path to LAStools on your 
:: computer before running this line, check if it is correctly incuded in the 
:: "Path" section of the "System Emvironment Variable". Then the user should 
:: add (if path already exists) or remove (when you need to add path) 
:: REM as required.
rem setx PATH=%PATH%;C:\Software\LAStools\bin

:: Requirement2- This script depends on two python scripts; one to summarise
:: LAS INFO of all tiles to a spreadsheet and the other to move intermediate 
:: results to a defined destination to free up space. Therefore, user must set
:: python environment for running this smoothly.
:: Also the user must install the python modules that these two scripts use.
rem set PYTHON_EXE="C:\Users\AppData\Local\Programs\Python\Python312\python.exe"
rem setx PATH "%PYTHON_EXE%;%PATH%" /m
rem pip install pandas re

:: Requirement3- Set inpath and outpath. 
echo.
color 0F
set /P PATHNAME_IN="Enter path to the input LiDAR directory: "
set /P PATHNAME_OUT="Enter path to the output directory: "
set /P SITE="Site: "

:restart
echo.
set /P MOVE="Move intermediate results (Y/N): "
if %MOVE%==Y (
    set /P PATHNAME_MOVE="Enter path to the destination directory: "
)

echo.
set /P TILE="Tile input LAS? (Y/N): " 
set /P TILE_INFO="Create tile info for LAS? (Y/N): " 
set /P DENOISE="Denoise LAS? (Y/N): "
set /P GROUND="Ground classify LAS? (Y/N): "
set /P GROUND_PT="Isolate ground points from LAS? (Y/N): "
set /P NORM="Ground normalize LAS? (Y/N): "
set /P THIN="Thin LAS to a manageable size? (Y/N): "

:: Requirement4- Create a main directory (if doesn't exist) and subdirectories  
:: in the output location to store the outputs from each step.  
if not exist %PATHNAME_OUT%\Preprocessed_pointclouds (
    mkdir !PATHNAME_OUT!\Preprocessed_pointclouds
)

:: Set working directory to the output directory. 
cd /D %PATHNAME_OUT%\Preprocessed_pointclouds\

echo List of user defined input parameters > .\parameters_preprocessing_%SITE%.txt
echo. >> .\parameters_preprocessing_%SITE%.txt
echo Created on %DATE% %TIME% >> .\parameters_preprocessing_%SITE%.txt
echo. >> .\parameters_preprocessing_%SITE%.txt

:: Requirement5- Specify the parameters. 
echo.
echo Specify the processing parameters.
echo Default values are assigned to the parameters. Press Enter to use default values. 
echo It is recommended to optimise them to suit the specifications of the input datasets.

echo.
set /P IN_LAS_EXT="File extension of input data (las or laz): " || ^
set "IN_LAS_EXT=laz"
set /P OUT_LAS_EXT="File extension of output data (las or laz): " || ^
set "OUT_LAS_EXT=laz"

echo. 
echo Input file extension is %IN_LAS_EXT%.
echo Output file extension is %OUT_LAS_EXT%.

echo Input extension LAS:%IN_LAS_EXT% >> .\parameters_preprocessing_%SITE%.txt
echo Output extension LAS:%OUT_LAS_EXT% >> .\parameters_preprocessing_%SITE%.txt
echo. >> .\parameters_preprocessing_%SITE%.txt
    
if %TILE%==Y (
    echo. 
    set /P TILE_SIZE="Tile size [m] (20): " || set "TILE_SIZE=20"
    set /P BUFFER_SIZE="Tile overlap [m] (0): " || set "BUFFER_SIZE=0"

    echo. 
    echo File will be split into !TILE_SIZE!m * !TILE_SIZE!m tiles with a buffer of !BUFFER_SIZE!m attached to each tile.

    echo Tiling was requested and following parameters were used. >> .\parameters_preprocessing_!SITE!.txt
    echo Tile size:!TILE_SIZE!m >> .\parameters_preprocessing_!SITE!.txt
    echo Buffer size:!BUFFER_SIZE!m >> .\parameters_preprocessing_!SITE!.txt
    echo Min tile size expected:!MIN_TILE_SIZE!m >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
) else (
    echo Tiling was not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %TILE_INFO%==Y  (
    echo LAS INFO files were requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
) else (
    echo LAS INFO files were not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %DENOISE%==Y (
    echo. 
    set /P GRID_RES="Grid resolution for denoising [m] (1): " || set "GRID_RES=1"
    set /P POINT_LIMIT="Minimum number of surrounding points for denoising (3):" || set "POINT_LIMIT=3"

    echo. 
    echo Points having less than !POINT_LIMIT! neighbour points within !GRID_RES!m distance will be removed from further analysis.

    echo Denoising was requested and following parameters were used. >> .\parameters_preprocessing_!SITE!.txt
    echo Grid resolution for denoising:!GRID_RES!m >> .\parameters_preprocessing_!SITE!.txt
    echo Minimum number of surrounding points:!POINT_LIMIT! >>.\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_!SITE!.txt
) else (
    echo Denoising was not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %GROUND%==Y (
    echo. 
    set /P GR_RES="Resolution for ground classification [m] (1): " || set "GR_RES=1"
    set /P GR_TYPE="Type of AOI [wilderness/nature] (wilderness): " || set "GR_TYPE=wilderness"
    set /P GR_DETAIL="Ground details [fine/extra_fine/ultra_fine/hyper_fine] (extra_fine): " || set "GR_DETAIL=extra_fine"

    echo. 
    echo Ground points will be classified at !GR_RES!m resolution with !GR_DETAIL! level details using !GR_TYPE! settings.
    
    echo Ground classification was requested and following parameters were used. >> .\parameters_preprocessing_!SITE!.txt
    echo Step size for ground classification:!GR_RES!m >> .\parameters_preprocessing_!SITE!.txt
    echo Ground type:!GR_TYPE! >> \parameters_preprocessing_!SITE!.txt
    echo Ground detail:!GR_DETAIL! >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_!SITE!.txt
) else (
    echo Ground classification was not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %GROUND_PT%==Y  (
    echo Ground point isolation was requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
) else (
    echo Ground point isolations was not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %NORM%==Y (
    echo. 
    set /P MINH="Minimum canopy height [m] (0): " || set "MINH=0"
    set /P MAXH="Maximum canopy height [m] (60): " || set "MAXH= 60"
    set /P GRID_RES_NORM="Grid resolution for removing isolated points/clusters [m] (1): " || set "GRID_RES_NORM=1"
    set /P POINT_LIMIT_NORM="Minimum number of surrounding points (3):" || set "POINT_LIMIT_NORM=3"

    echo. 
    echo Points below !MINH!m and above !MAXH!m will be removed from norm tiles.

    echo Height normalization and extreme removal was requested and following parameters were used. >> .\parameters_preprocessing_!SITE!.txt
    echo Minimum height of norm points:!MINH!m >> .\parameters_preprocessing_!SITE!.txt
    echo Maximum height of norm points:!MAXH!m >> .\parameters_preprocessing_!SITE!.txt
    echo Grid resolution for removing isolated points/clusters in normalized pointcloud:!GRID_RES!m >> .\parameters_preprocessing_!SITE!.txt
    echo Minimum number of surrounding points in normalised pointcloud:!POINT_LIMIT! >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_!SITE!.txt
) else (
    echo Height normalization was not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %THIN%==Y  (
    echo Data thinning was requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
) else (
    echo Data thinning was not crequested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

if %MOVE%==Y (
    echo Moving outputs was requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
) else (
    echo Moving outputs was not requested. >> .\parameters_preprocessing_!SITE!.txt
    echo. >> .\parameters_preprocessing_%SITE%.txt
)

echo.
set /P NUM_CORES="Number of cores to be used for processing (total cores -1L or -2L): " || ^
set "NUM_CORES= %NUMBER_OF_PROCESSORS%"

echo. 
echo %NUM_CORES% cores will be used for processing.

echo Number of cores used:%NUM_CORES% >> .\parameters_preprocessing_%SITE%.txt

:: Requirement6- Check if the user is happy with the input/default parameter 
:: values assigned and restart if needs re-assigning.
echo. 
color 0C
echo Press "Y" if you're happy with the parameters or "N" to re-assign values.

set /P PR="Proceed? (Y/N): " 
if %PR%==N (
    goto restart
)
echo.
color 0F

:: Requirement7- Create an empty log.txt file to record processing progress. 
echo Log file > .\log_preprocessing_%SITE%.txt
echo. >> .\log_preprocessing_%SITE%.txt
echo %DATE% %TIME%: Pre-processing pointclouds started. >> .\log_preprocessing_%SITE%.txt
echo. >> .\log_preprocessing_%SITE%.txt
echo Number of files in the input directory: >> .\log_preprocessing_%SITE%.txt
dir /a:-d /s /b %PATHNAME_IN% | find /c ":" >> .\log_preprocessing_%SITE%.txt
echo. >> .\log_preprocessing_%SITE%.txt

:: Core processing.  
:: Initiate moving files.
if %MOVE%==Y (
    :: Check if the destination directory exists, if not, create it.
    if not exist "!PATHNAME_MOVE!\Preprocessed_pointclouds" (
        mkdir "!PATHNAME_MOVE!\Preprocessed_pointclouds"
    )

    :: Set the source directory.
    set "SOURCE_DIR=!PATHNAME_OUT!\Preprocessed_pointclouds"
    set "MOVE_DIR=!PATHNAME_MOVE!\Preprocessed_pointclouds"

    :: Call the Python script to run file_move script.
    :: This is launched in a seperate cmd window and runs independtly of this 
    :: batch script.
    start cmd /k python "%~dp0\move_files.py" "!SOURCE_DIR!" "!MOVE_DIR!"
)

:: Tiling the input.
if %TILE%== Y (
    mkdir !PATHNAME_IN!\Tiles

    echo. 
    echo Tiling the input file.
    echo !DATE! !TIME!: Tiling started. >> .\log_preprocessing_!SITE!.txt

    lastile -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
            -tile_size !TILE_SIZE! -buffer !BUFFER_SIZE! ^
            -odir !PATHNAME_IN!\Tiles -odix "_tile" -o!IN_LAS_EXT!

        if errorlevel 1 (
            echo !DATE! !TIME!: Tiling terminated. >> .\log_preprocessing_!SITE!.txt
            goto error
        ) else (
            echo !DATE! !TIME!: Tiling completed. >> .\log_preprocessing_!SITE!.txt
            echo Number of tiles, including spatial index files: >> .\log_preprocessing_!SITE!.txt
            dir /a:-d /s /b !PATHNAME_IN!\Tiles | find /c ":" >> .\log_preprocessing_!SITE!.txt
            echo. >> .\log_preprocessing_!SITE!.txt
        )

    :: Create a file to track progress in file moving.
    echo !PATHNAME_IN! > .\completed.txt

    :: Re-set input path and input file extension.
    set "PATHNAME_IN=!PATHNAME_IN!\Tiles"
    set IN_LAS_EXT=!OUT_LAS_EXT!
)

:: Spatial index LAS tiles.
lasindex -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
         -cores !NUM_CORES!

:: Create a las info file with histograms.
if %TILE_INFO%== Y (
    echo. 
    echo Creating las info files.
    echo !DATE! !TIME!: Creating LAS INFO started. >> .\log_preprocessing_!SITE!.txt

    lasinfo -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
            -odir !PATHNAME_IN! -odix "_info" -otxt ^
            -histo z 5 -histo classification 1 ^
            -cores !NUM_CORES!

        if errorlevel 1 (
            echo !DATE! !TIME!: LAS INFO terminated. >> .\log_preprocessing_!SITE!.txt
            goto error
        ) else (
            echo !DATE! !TIME!: LAS INFO completed. >> .\log_preprocessing_!SITE!.txt
            echo. >> .\log_preprocessing_!SITE!.txt
        )

    :: Set output spreadsheet path.
    set "OUT_SPREADSHEET=!PATHNAME_OUT!\Preprocessed_pointclouds\Tile_info_summary.csv"

    :: Extract specific detailts from las info files to a spreadsheet.
    :: This is launched in a seperate cmd window and runs independtly of this 
    :: batch script.
    start cmd /k python "%~dp0\tile_info_summary.py" "!PATHNAME_IN!" "!OUT_SPREADSHEET!"
)

:: Remove noise points
if %DENOISE%== Y (
    mkdir .\1_Denoised 

    echo. 
    echo Denoising the tiles.
    echo !DATE! !TIME!: Denoising started. >> .\log_preprocessing_!SITE!.txt

    lasnoise -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
             -drop_classification 18 -drop_classification 7 ^
             -buffered 20 -step_xy !GRID_RES! -step_z !GRID_RES! ^
             -remove_noise -isolated !POINT_LIMIT! -epsg 2193 ^
             -odir .\1_Denoised -odix "_dn" -o!OUT_LAS_EXT! ^
             -cores !NUM_CORES!

    lasindex -i .\1_Denoised\*.!IN_LAS_EXT! ^
             -cores !NUM_CORES!

            if errorlevel 1 (
                echo !DATE! !TIME!: Denoising terminated. >> .\log_preprocessing_!SITE!.txt
                goto error
            ) else (
                echo !DATE! !TIME!: Denoising completed. >> .\log_preprocessing_!SITE!.txt
                echo Number of tiles denoised, including spatial index files: >> .\log_preprocessing_!SITE!.txt
                dir /a:-d /s /b .\1_Denoised | find /c ":" >> .\log_preprocessing_!SITE!.txt
                echo. >> .\log_preprocessing_!SITE!.txt
            )

    :: Create a file to track progress in file moving.
    echo !PATHNAME_IN! > .\completed.txt

    :: Re-set input path and input file extension.
    set "PATHNAME_IN=!PATHNAME_OUT!\Preprocessed_pointclouds\1_Denoised"
    set IN_LAS_EXT=!OUT_LAS_EXT!
)

:: Classify ground points 
if %GROUND%== Y (
    mkdir .\2_GroundC  

    echo. 
    echo Ground classifying the tiles.
    echo !DATE! !TIME!: Ground classification started. >> .\log_preprocessing_!SITE!.txt

    lasground_new -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
                  -buffered 20 -!GR_TYPE! -!GR_DETAIL! -epsg 2193 ^
                  -odir .\2_GroundC -odix "_gC" -o!OUT_LAS_EXT! ^
                  -cores !NUM_CORES! 

    lasindex -i .\2_GroundC\*.!IN_LAS_EXT! ^
             -cores !NUM_CORES!

                if errorlevel 1 (
                    echo !DATE! !TIME!: Ground classification terminated. >> .\log_preprocessing_!SITE!.txt
                    goto error
                ) else (
                    echo !DATE! !TIME!: Ground classification completed. >> .\log_preprocessing_!SITE!.txt
                    echo Number of tiles ground classified, including spatial index files: >> .\log_preprocessing_!SITE!.txt
                    dir /a:-d /s /b .\2_GroundC | find /c ":" >> .\log_preprocessing_!SITE!.txt
                    echo. >> .\log_preprocessing_!SITE!.txt
                )  

    :: Create a file to track progress in file moving.
    echo !PATHNAME_IN! > .\completed.txt

    :: Re-set input path and input file extension.
    set "PATHNAME_IN=!PATHNAME_OUT!\Preprocessed_pointclouds\2_GroundC"  
    set IN_LAS_EXT=!OUT_LAS_EXT!
)  

:: Split ground points.
if %GROUND_PT%== Y (
    mkdir .\3_GroundP

    echo. 
    echo Isolating ground points.
    echo !DATE! !TIME!: Isolating round points started. >> .\log_preprocessing_!SITE!.txt

    las2las -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
            -keep_classification 2 -epsg 2193 ^
            -odir .\3_GroundP -odix "" -o!OUT_LAS_EXT! ^
            -cores !NUM_CORES! 

    lasindex -i .\3_GroundP\*.!IN_LAS_EXT! ^
            -cores !NUM_CORES!

            if errorlevel 1 (
                echo !DATE! !TIME!: Isolating ground points terminated. >> .\log_preprocessing_!SITE!.txt
                goto error
            ) else (
                echo !DATE! !TIME!: Isolating ground points completed. >> .\log_preprocessing_!SITE!.txt
                echo Number of ground point tiles, including spatial index files: >> .\log_preprocessing_!SITE!.txt
                dir /a:-d /s /b .\3_GroundP | find /c ":" >> .\log_preprocessing_!SITE!.txt
                echo. >> .\log_preprocessing_!SITE!.txt
            )

    :: Create a file to track progress in file moving.
    echo !PATHNAME_OUT!\Preprocessed_pointclouds\3_GroundP > .\completed.txt
) 

:: Ground normalize tiles and replace z with normalized height 
if %NORM%== Y (
    mkdir .\4_NormHt
    mkdir .\4_NormHt\temp

    echo. 
    echo Ground normalizing the tiles.
    echo !DATE! !TIME!: Ground normalizing started. >> .\log_preprocessing_!SITE!.txt

    lasheight -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
              -buffered 20 -replace_z -epsg 2193 ^
              -odir .\4_NormHt\temp -odix "_norm" -o!OUT_LAS_EXT! ^
              -cores !NUM_CORES!

    :: Back up processing for de-buffering tiles in case LasTools exhibited a
    :: weird behaviout by retaining the buffers from the previous steps. 
    :: Note: THis only occurs in some datasets.
    rem mkdir .\4_NormHt\temp\temp
    rem lastile -i .\4_NormHt\temp\temp\*.!IN_LAS_EXT! ^
	rem -remove_buffer ^
	rem -odir .\4_NormHt\temp -o!OUT_LAS_EXT! ^
    rem -cores !NUM_CORES!

    :: Create a file to track progress in file moving.
    echo !PATHNAME_IN! > .\completed.txt

    lasnoise -i .\4_NormHt\temp\*.!IN_LAS_EXT!^
             -buffered 20 -step_xy !GRID_RES_NORM! -step_z !GRID_RES_NORM! ^
             -isolated !POINT_LIMIT_NORM! -remove_noise -epsg 2193 ^
             -drop_z_below !MINH! -drop_z_above !MAXH! ^
             -odir .\4_NormHt -o!OUT_LAS_EXT! ^
             -cores !NUM_CORES!

    lasindex -i .\4_NormHt\*.!IN_LAS_EXT! ^
             -cores !NUM_CORES!

    :: Remove intermediate results created in height normalisation process.
    rmdir /s /q .\4_NormHt\temp

            if errorlevel 1 (
                echo !DATE! !TIME!: Ground normalizing terminated. >> .\log_preprocessing_!SITE!.txt
                goto error
            ) else (
                echo !DATE! !TIME!: Ground normalizing completed. >> .\log_preprocessing_!SITE!.txt
                echo Number of tiles normalized, including spatial index files: >> .\log_preprocessing_!SITE!.txt
                dir /a:-d /s /b .\4_NormHt | find /c ":" >> .\log_preprocessing_!SITE!.txt
                echo. >> .\log_preprocessing_!SITE!.txt
            )

    :: Re-set input path and input file extension.
    set "PATHNAME_IN=!PATHNAME_OUT!\Preprocessed_pointclouds\4_NormHt"
    set IN_LAS_EXT=!OUT_LAS_EXT!
)

:: Thin tiles.
:: Perform this step only if tiles needs to  be decimated to a manageable size.
:: This step is unnecessary if not using pointclouds for treetop detection or 
:: when point density is extremely low.

if %THIN%== Y (

    mkdir .\5_Thinned

    echo. 
    echo Thinning tiles.
    echo !DATE! !TIME!: Thinning started. >> .\log_preprocessing_!SITE!.txt

    lasthin -i !PATHNAME_IN!\*.!IN_LAS_EXT! ^
            -step !GRID_RES! -percentile 99 -epsg 2193 ^
            -odir .\5_Thinned -odix "_th" -o!OUT_LAS_EXT! ^
            -cores !NUM_CORES!

    lasindex -i .\5_Thinned\*.!IN_LAS_EXT! ^
            -cores !NUM_CORES!

            if errorlevel 1 (
                echo !DATE! !TIME!:: Thinning terminated. >> .\log_preprocessing_!SITE!.txt
                goto error
            ) else (
                echo !DATE! !TIME!: Thinning completed. >> .\log_preprocessing_!SITE!.txt
                echo Number of tiles thinned, including spatial index files: >> .\log_preprocessing_!SITE!.txt
                dir /a:-d /s /b .\5_Thinned | find /c ":" >> .\log_preprocessing_!SITE!.txt
                echo. >> .\log_preprocessing_!SITE!.txt
            )
)

:: Print closing message.
echo %DATE% %TIME%: Preprocessing pointclouds completed. >> .\log_preprocessing_%SITE%.txt

:: Rename the file created to track progress to "sentinel" to stop moving files.
ren "%PATHNAME_out%\Preprocessed_pointclouds\completed.txt" "sentinel.txt"
goto end

 :error
color 0C
echo Processing terminated.
echo.

 :end
color 0A
echo Preprocessed_pointclouds completed.
echo.
cd /D %~dp0

:: =============================================================================
:: End of script
:: =============================================================================
