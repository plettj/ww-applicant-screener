#!/bin/bash

# Define the necessary folders
RESULTS_FOLDER="./results"
PDF_FOLDER="./pdf_bundle"
SCREENED_PDFS_FOLDER="$RESULTS_FOLDER/screened_pdfs"
SCREENED_CANDIDATES_FILE="$RESULTS_FOLDER/screened_candidates.txt"

# Create the screened_pdfs folder if it doesn't exist
mkdir -p "$SCREENED_PDFS_FOLDER"

# Process the screened_candidates.txt file
while IFS= read -r line; do
  # Check if the line does not start with *
  if [[ "$line" != \** ]]; then
    # Extract the name from the line
    name=$(echo "$line" | cut -d' ' -f1)
    
    # Find the associated PDF in the pdf_bundle folder
    pdf_file=$(find "$PDF_FOLDER" -type f -name "$name*.pdf")
    
    # Check if the PDF file exists
    if [[ -f "$pdf_file" ]]; then
      # Copy the PDF to the screened_pdfs folder
      cp "$pdf_file" "$SCREENED_PDFS_FOLDER"
    else
      echo "***** ERROR: PDF not found for $name"
    fi
  fi
done < "$SCREENED_CANDIDATES_FILE"

echo "Completed processing PDFs for screened candidates."
