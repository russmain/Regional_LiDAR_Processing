import os
import shutil
import time
import argparse
from datetime import datetime

def get_current_timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def move_files(source_dir, destination_dir, exclude_list):
    sleep_time = 3600  # 1 hour
    max_attempts = 10

    def move_subdirectory(path):
        if not os.path.exists(path):
            print(f"Path '{path}' does not exist or may have been moved already. Skipping...\n")
            return

        directory_name = os.path.split(path)[-1]
        source_subdir_path = path
        destination_subdir_path = os.path.join(destination_dir, directory_name)

        if os.path.exists(destination_subdir_path):
            print(f"'{directory_name}' Already moved to destination '{destination_dir}'. Skipping...\n")
            return

        for attempt in range(max_attempts):
            try:
                shutil.move(source_subdir_path, os.path.join(destination_dir, directory_name))
                moving_timestamp = get_current_timestamp()
                print(
                    f"{moving_timestamp}: Moved '{os.path.split(path)[-1]}' to '{os.path.join(destination_dir, 
                                                                                              directory_name)}'\n")
                break
            except PermissionError as e:
                if attempt < max_attempts - 1:
                    moving_timestamp = get_current_timestamp()
                    print(f"{moving_timestamp}: PermissionError: {e}. Retrying after 5 minutes...\n")
                    time.sleep(sleep_time)
                else:
                    moving_timestamp = get_current_timestamp()
                    print(f"{moving_timestamp}: Max attempts reached. Unable to move directory.\n")
                    break

    def move_everything():
        for root, dirs, files in os.walk(source_dir):
            for directory in dirs:
                dir_path = os.path.join(root, directory)
                if not os.path.exists(dir_path):
                    print(f"Path '{dir_path}' does not exist. Skipping...\n")
                    continue

                if directory not in exclude_list:
                    move_subdirectory(dir_path)

            for file_name in files:
                file_path = os.path.join(root, file_name)
                if not os.path.exists(file_path):
                    print(f"Path '{file_path}' does not exist. Skipping...\n")
                    continue

                if file_name not in exclude_list:
                    source_file_path = file_path
                    destination_file_path = os.path.join(destination_dir, os.path.relpath(file_path, source_dir))

                    for attempt in range(max_attempts):
                        try:
                            shutil.move(source_file_path, destination_file_path)
                            moving_timestamp = get_current_timestamp()
                            print(f"{moving_timestamp}: Moved file '{file_name}' to '{destination_dir}'\n")
                            break  # Move successful, exit loop
                        except PermissionError as e:
                            if attempt < max_attempts - 1:
                                moving_timestamp = get_current_timestamp()
                                print(f"{moving_timestamp}: PermissionError: {e}. Retrying after 5 minutes...\n")
                                time.sleep(sleep_time)
                            else:
                                moving_timestamp = get_current_timestamp()
                                print(f"{moving_timestamp}: Max attempts reached. Unable to move file.\n")
                                break

    sentinel_file = os.path.join(source_dir, "sentinel.txt")
    while not os.path.exists(sentinel_file):
        if os.path.exists(os.path.join(source_dir, "completed.txt")):
            with open(os.path.join(source_dir, "completed.txt"), 'r') as file:
                link = file.readline().strip()
                if link and link not in exclude_list:
                    move_subdirectory(link)

        time.sleep(sleep_time)

    move_everything()

    # Remove the sentinel file from the destination directory
    sentinel_file = os.path.join(destination_dir, "sentinel.txt")
    if os.path.exists(sentinel_file):
        os.remove(sentinel_file)

    closing_timestamp = get_current_timestamp()
    closing_message = f"""THE WINDOW CAN NOW BE CLOSED SAFELY.\n{closing_timestamp}: All files moved.\n"""
    print(closing_message)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Periodically move files from source to destination directory")
    parser.add_argument("source_directory", type=str, help="Path to the source directory")
    parser.add_argument("destination_directory", type=str, help="Path to the destination directory")
    parser.add_argument("--exclude_list", nargs="+", default=[], help="Directories to exclude from moving")
    args = parser.parse_args()

    opening_timestamp = get_current_timestamp()
    opening_message = f"""DO NOT CLOSE THIS WINDOW.\n{opening_timestamp}: Moving intermediate results initiated.
This process periodically moves files from the source directory to the specified destination.
It will continue moving files until the point cloud processing is completed.\n"""
    print(opening_message)

    move_files(args.source_directory, args.destination_directory, args.exclude_list)
