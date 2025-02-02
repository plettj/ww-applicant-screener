#!/bin/bash

# Define the paths
PDF_FOLDER="./pdf_bundle"
SHORTLIST_FILE="./results/shortlist.txt"
RESULTS_FOLDER="./results/shortlist"

# Ensure the results folder exists
mkdir -p "$RESULTS_FOLDER"

# Function to print error message
function print_error {
  echo "Error: $1"
}

# Check if the shortlist file exists
if [[ ! -f "$SHORTLIST_FILE" ]]; then
  print_error "Shortlist file '$SHORTLIST_FILE' does not exist."
  exit 1
fi

# Read the shortlist file line by line
while IFS= read -r line; do
  # Extract the full name before the " - " string
  full_name=$(echo "$line" | cut -d ' ' -f 1 | xargs)
  
  # Find the matching PDF file
  pdf_file=$(find "$PDF_FOLDER" -type f -iname "$full_name*.pdf")

  # Check if the PDF file was found
  if [[ -z "$pdf_file" ]]; then
    print_error "No PDF found for '$full_name'."
    continue
  fi

  # Copy the PDF file to the results folder
  cp "$pdf_file" "$RESULTS_FOLDER/"
  echo "Copied: $pdf_file"

done < "$SHORTLIST_FILE"

echo "Processing completed."
