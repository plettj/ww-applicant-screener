#!/bin/bash

# Define the folder containing the PDF resumes
PDF_FOLDER="./pdf_bundle"
# Define the output folder for the text files
OUTPUT_FOLDER="./text_bundle"

# Function to print error message and exit
function print_error_and_exit {
  echo "********* Error: $1"
  echo "Ensure that the PDF folder exists and contains PDF files."
  echo "You can change the PDF folder by modifying the 'PDF_FOLDER' variable in the script."
  exit 1
}

# Check if the PDF folder exists
if [[ ! -d "$PDF_FOLDER" ]]; then
  print_error_and_exit "PDF folder '$PDF_FOLDER' does not exist."
fi

# Check if there are PDF files in the folder
if [[ -z $(ls "$PDF_FOLDER"/*.pdf 2>/dev/null) ]]; then
  print_error_and_exit "No PDF files found in '$PDF_FOLDER'."
fi

# Create the output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Iterate over all PDF files in the folder
for pdf_file in "$PDF_FOLDER"/*.pdf; do
  # Get the base name of the PDF file (without path and extension)
  base_name=$(basename "$pdf_file" .pdf)
  
  # Define the output text file path
  output_file="$OUTPUT_FOLDER/$base_name.txt"
  
  # Run the text extraction command
  if ! ./tools/pdftotext.exe "$pdf_file" "$output_file"; then
    echo "********* Failed to process: $pdf_file"
    continue
  fi
  
  # Check if the output file exists
  if [[ ! -f "$output_file" ]]; then
    echo "********* Error: Output file '$output_file' was not created."
    continue
  fi
  
  # Handle renaming if the base name contains "-2"
  if [[ "$base_name" == *-2* ]]; then
    new_base_name="${base_name%-2*}"
    new_output_file="$OUTPUT_FOLDER/$new_base_name.txt"
    mv "$output_file" "$new_output_file"
    echo "Processed and renamed: $pdf_file -> $new_output_file"
  else
    echo "********* Only Processed: $pdf_file -> $output_file"
  fi
done
