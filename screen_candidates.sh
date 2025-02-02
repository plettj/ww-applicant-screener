#!/bin/bash

# This script filters text files based on work term ratings, GPA, and keywords.

# It applies practical mechanisms to determine if a person qualifies based on predefined rules,
# such as requiring fewer than two non-top ratings, having a GPA average above 75%, and containing keywords.

# The results are written to a single file with clear indications of failures in work term ratings, GPA, or keywords.

echo "Starting the screening process based on work term ratings, GPA, and keywords."

# Define the folders and files
TEXT_FOLDER="./text_bundle"
RESULTS_FOLDER="./results"
PDF_FOLDER="./pdf_bundle"
SCREENED_PDFS_FOLDER="$RESULTS_FOLDER/screened_pdfs"
KEYWORDS_FILE="keywords.txt"
OUTPUT_FILE="$RESULTS_FOLDER/screened_candidates.txt"

# Function to print error message
function print_error {
  echo "***** ERROR: $1 - $2"
}

# Create results folder if it doesn't exist
mkdir -p "$RESULTS_FOLDER"
mkdir -p "$SCREENED_PDFS_FOLDER"

# Clear the output file if it exists
> "$OUTPUT_FILE"

# Read keywords from the file or command line arguments
if [[ -s "$KEYWORDS_FILE" ]]; then
  if ! keywords=$(<"$KEYWORDS_FILE"); then
    print_error "Failed to read from keywords.txt. Ensure it is properly formatted." "keywords.txt"
    exit 1
  fi
else
  if [ $# -eq 0 ]; then
    print_error "No keywords provided. Please provide keywords.txt or command line arguments." "keywords"
    exit 1
  else
    keywords="$*"
  fi
fi

# Function to calculate weighted average GPA
function calculate_weighted_gpa {
  local gpas=("$@")
  local total_weight=0
  local weighted_sum=0
  local weights=(0.33 0.28 0.22 0.17)
  local n=${#gpas[@]}

  if (( n < 4 )); then
    weights=()
    for (( i=0; i<n; i++ )); do
      weight=$(echo "scale=2; 1.0 / $n" | bc)
      weights+=("$weight")
    done
  fi

  for i in "${!gpas[@]}"; do
    weight=${weights[i]}
    weighted_sum=$(echo "$weighted_sum + ${gpas[i]} * $weight" | bc)
    total_weight=$(echo "$total_weight + $weight" | bc)
  done

  average=$(echo "$weighted_sum / $total_weight" | bc)
  echo "$average"
}

# Define the valid ratings
valid_ratings=("OUTSTANDING" "EXCELLENT" "GOOD" "SATISFACTORY" "MARGINAL" "UNSATISFACTORY")

total_candidates=0
passed_candidates=0

# Iterate over all text files in the folder
for text_file in "$TEXT_FOLDER"/*.txt; do

  base_name=$(basename "$text_file" .txt)
  total_candidates=$((total_candidates + 1))

  # Initialize variables
  work_term_ratings=()
  gpas=()
  work_term_failed=false
  gpa_failed=false
  keyword_failed=false
  error_occurred=false
  work_term_marginal=false
  total_count=0

  # Count occurrences of each rating in the text file
  rating_counts=()
  total_ratings=0

  for rating in "${valid_ratings[@]}"; do
    count=$(grep -o "\b$rating\b" "$text_file" | wc -l)
    rating_counts+=("$rating:$count")
    total_ratings=$((total_ratings + count))
  done

  # Evaluate work term ratings
  outstanding_count=0
  non_top_ratings_count=0
  for rating_count in "${rating_counts[@]}"; do
    rating=$(echo "$rating_count" | cut -d':' -f1)
    count=$(echo "$rating_count" | cut -d':' -f2)
    if [[ "$rating" == "OUTSTANDING" ]]; then
      outstanding_count=$((outstanding_count + count))
    elif [[ "$rating" != "EXCELLENT" ]]; then
      non_top_ratings_count=$((non_top_ratings_count + count))
    fi
    for ((i = 0; i < count; i++)); do
      work_term_ratings+=("$rating")
    done
  done

  if (( non_top_ratings_count >= 2 )); then
    if (( outstanding_count == 0 )); then
      work_term_failed=true
    else
      work_term_marginal=true
    fi
  fi

  work_term_summary="${#work_term_ratings[@]}"

  # Evaluate GPA
  valid_gpa_found=false
  weighted_gpa="N/A"
  while IFS= read -r line; do
    if [[ "$line" =~ ^Term\ Average:\  ]]; then
      gpa=$(echo "$line" | cut -d' ' -f3)
      if [[ "$gpa" != *"N/A"* ]]; then
        truncated_gpa="${gpa:0:2}"
        gpas+=("$truncated_gpa")
        valid_gpa_found=true
      fi
    fi
  done < "$text_file"

  if $valid_gpa_found; then
    if (( ${#gpas[@]} > 4 )); then
      gpas=("${gpas[@]: -4}")
    fi
    weighted_gpa=$(calculate_weighted_gpa "${gpas[@]}")
    if (( $(echo "$weighted_gpa < 74" | bc -l) )); then
      gpa_failed=true
    fi
  else
    print_error "No valid GPA found" "$base_name"
  fi

  # Count the occurrences of the keywords in the text file
  for keyword in $keywords; do
    count=$(grep -o -i "$keyword" "$text_file" | wc -l)
    total_count=$((total_count + count))
  done

  if [ $total_count -eq 0 ]; then
    keyword_failed=true
  fi

  # Create the output string
  output_line="$base_name - ${work_term_summary} - Avg: $weighted_gpa"

  # Add failure prefixes
  if [ "$keyword_failed" = true ]; then
    output_line="WORDX $output_line"
  fi
  if [ "$work_term_failed" = true ]; then
    output_line="WORKX $output_line"
  fi
  if [ "$gpa_failed" = true ]; then
    output_line="GRADEX $output_line"
  fi

  # Print work term ratings and GPAs in the console
  echo "$base_name --- Ratings: ${work_term_ratings[*]} --- GPAs: ${gpas[*]}"

  # Add 'marginal' if saved by an OUTSTANDING rating
  if [ "$work_term_marginal" = true ]; then
    output_line="$output_line - marginal work ratings"
  fi

  # Prefix failed candidates with "* "
  if [ "$work_term_failed" = true ] || [ "$gpa_failed" = true ] || [ "$keyword_failed" = true ]; then
    output_line="* $output_line"
  else
    passed_candidates=$((passed_candidates + 1))
  fi

  # Write the output line to the file
  echo "$output_line" >> "$OUTPUT_FILE"
done

echo "Completed screening process based on work term ratings, GPA, and keywords."
echo "$total_candidates candidates to start, and $passed_candidates candidates made it through screening."
