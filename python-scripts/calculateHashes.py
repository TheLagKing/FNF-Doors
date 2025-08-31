import os
import hashlib
import json
import csv
import PRIVATE_glasshatData as glasshat

def calculate_hash_of_json_files():
    # Get the current working directory
    current_directory = os.path.join("./assets/preload/data", "")

    # Prepare the list for storing file names and their hashes
    file_hashes = []

    # Walk through all subdirectories and files
    for root, dirs, files in os.walk(current_directory):
        for file_name in files:
            # Check if the file is a JSON file and starts with the directory name prefix
            if file_name.endswith('.json') and file_name.startswith(root.split("\\")[-1]):

                if "hell" in file_name and "hell" in root:
                    continue

                file_path = os.path.join(root, file_name)
                
                # Calculate the hash of the JSON file using MD5
                with open(file_path, 'a') as json_file:
                    json_file.write(glasshat.chartHashPepper)

                with open(file_path, 'rb') as json_file:
                    file_content = json_file.read()
                    while not file_content.endswith(b"}"):
                        file_content = file_content[:-1]
                    file_hash = hashlib.md5(file_content).hexdigest()

                    diff = file_name.split("-")[-1].split(".")[0]
                    if(diff != "easy" and diff != "hard" and diff != "hell"): diff = "normal"
                    if(root.split("\\")[-1] == ""): continue
                    file_hashes.append((root.split("\\")[-1], diff, file_hash))
                    
                with open(file_path, 'r') as json_file:
                    lines = json_file.readlines()
                    lines[-1] = "}"
                
                with open(file_path, 'w') as json_file:
                    json_file.writelines(lines)

    # Export the file names and their hashes to a CSV file

    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_file_path = os.path.join(script_dir, 'OUTPUT', 'file_hashes.csv')
    with open(csv_file_path, 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(['Song name', 'Song diff', 'Hash'])
        csv_writer.writerows(file_hashes)

    print(f"Hashes have been calculated and exported to {csv_file_path}")

calculate_hash_of_json_files()