import os
import pandas as pd
import argparse


def extract_ground_count(line):
    if 'ground' in line:
        count = line.strip().split()[0]  # Extract the count of ground points
        return count
    return None


def extract_numeric_values(line):
    components = line.strip().split(': ')[-1].split()
    return components


def extract_file_specs(text_file_path, lines_to_extract):
    data = {'File Name': os.path.splitext(os.path.basename(text_file_path))[0]}

    with open(text_file_path, 'r') as file:
        for line in file:
            for target_line, columns in lines_to_extract.items():
                if target_line in line:
                    if 'ground' in target_line:
                        count = extract_ground_count(line)
                        if count:
                            data['ground_count'] = count
                    else:
                        numeric_values = extract_numeric_values(line)
                        if len(numeric_values) == len(columns):
                            for col, val in zip(columns, numeric_values):
                                data[col] = val
                    break  # Stop searching for other lines once found

    return data


def process_files(input_directory, output_csv):
    # Define the lines to extract along with their corresponding columns
    lines_to_extract = {
        "extended number of point records:": ["total_num_of_points"],
        "min x y z:": ["minX", "minY", "minZ"],
        "max x y z:": ["maxX", "maxY", "maxZ"],
        "ground": [],
    }

    # Create an empty list to store extracted data
    extracted_data = []

    # Iterate through each file in the input directory
    for file_name in os.listdir(input_directory):
        if file_name.endswith('.txt'):
            file_path = os.path.join(input_directory, file_name)
            # Extract lines containing the specified strings from the current file
            extracted_data.append(extract_file_specs(file_path, lines_to_extract))

    # Create a DataFrame from the extracted data list
    df_combined = pd.DataFrame(extracted_data)

    # Write the DataFrame to a CSV file
    df_combined.to_csv(output_csv, index=False)

    # Print the closing message
    closing_message = f"""THE WINDOW CAN NOW BE CLOSED SAFELY.
    Specified details extracted from LAS INFO files in '{input_directory}' 
    have been added to '{output_csv}'.
    Extraction process completed.\n"""
    print(closing_message)


if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Extract lines containing specific strings  to a CSV file.')
    parser.add_argument('input_directory', type=str, help='Path to the directory containing text files.')
    parser.add_argument('output_csv', type=str, help='Path to the output CSV file.')

    # Parse arguments
    args = parser.parse_args()

    # Process files
    process_files(args.input_directory, args.output_csv)
