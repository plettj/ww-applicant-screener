#!/bin/bash

# Define the folder containing the text files
TEXT_FOLDER="./text_bundle"
RESULTS_FOLDER="./results"

# Function to print error message and exit
function print_error_and_exit {
  echo "Error: $1"
  echo "Usage:"
  echo "  1. Ensure 'keywords.txt' contains keywords separated by spaces."
  echo "  2. Alternatively, provide keywords as command line arguments."
  echo "Example:"
  echo "  bash count_keywords.sh keyword1 keyword2"
  exit 1
}

# Check if keywords.txt file exists and is not empty
if [[ -s keywords.txt ]]; then
  # Read keywords from the file
  if ! keywords=$(<keywords.txt); then
    print_error_and_exit "Failed to read from keywords.txt. Ensure it is properly formatted."
  fi
else
  # Check if keywords are provided as command line arguments
  if [ $# -eq 0 ]; then
    print_error_and_exit "No keywords provided. Please provide keywords.txt or command line arguments."
  else
    # Read keywords from command line arguments
    keywords="$*"
  fi
fi

# Create results folder if it doesn't exist
mkdir -p "$RESULTS_FOLDER"

# Prepare the output file name
keywords_filename=$(echo "$keywords" | tr ' ' '-')
output_file="$RESULTS_FOLDER/screened_keywords_$keywords_filename.txt"

# Clear the output file if it exists
> "$output_file"

# Iterate over all text files in the folder
for text_file in "$TEXT_FOLDER"/*.txt; do
  # Get the base name of the text file (without path and extension)
  base_name=$(basename "$text_file" .txt)

  # Initialize total count
  total_count=0

  for keyword in $keywords; do
    # Count the occurrences of the keyword in the text file (case insensitive)
    count=$(grep -o -i "$keyword" "$text_file" | wc -l)
    total_count=$((total_count + count))
  done

  # Check if total count is zero
  if [ $total_count -eq 0 ]; then
    echo "* WORDX $base_name" >> "$output_file"
  else
    echo "$base_name" >> "$output_file"
  fi
done
