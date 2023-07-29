#!/bin/bash

# Step 1: Clone the repository
git clone https://github.com/rick001/Webshell-Detect.git
cd Webshell-Detect

# Step 2: Check if python3 is installed
if ! command -v python3 &> /dev/null; then
    # Step 3: Install python3 if it's not installed
    sudo apt update
    sudo apt install -y python3
fi

# Step 4: Run the python script
python3 webshell_detect.py

# Step 5: Read the generated csv file and print the detected files
csv_file="webshell_detection_results.csv"
if [ -f "$csv_file" ]; then
    echo "Detected Webshells:"

    # Read the CSV file line by line and prompt the user for each file
    tail -n +2 "$csv_file" | cut -d',' -f1 | while IFS= read -r file; do
        if [[ -z "${file// }" ]]; then
            continue
        fi

        echo "Found file: $file"
        echo "Do you want to delete and kill processes for this file? (y/n)"
        read -r response < /dev/tty
        if [[ $response =~ ^[Yy]$ ]]; then
            if [ -f "$file" ]; then
                # Delete the file if it exists
                rm "$file"
                echo "Deleted: $file"
            fi

            # Check if a process with the same name is running and terminate it
            process_name=$(basename "$file")
            pids=$(pgrep -f "$process_name")
            if [ -n "$pids" ]; then
                echo "Processes running for $file:"
                ps -p $pids
                echo "Do you want to terminate these processes? (y/n)"
                read -r kill_response < /dev/tty
                if [[ $kill_response =~ ^[Yy]$ ]]; then
                    kill $pids
                    echo "Terminated processes for $file"
                fi
            else
                echo "No running processes found for $file"
            fi
        fi
    done
else
    echo "No Webshell detected."
fi
