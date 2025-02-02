# WW Applicant Screener

A set of tools for sifting through applicants on [WaterlooWorks](https://waterlooworks.uwaterloo.ca/home.htm), the [University of Waterloo](https://uwaterloo.ca/)'s internal job board.

## Table of Contents

1. Introduction
2. Usage and Download Instructions
3. Filtering Applicants
4. Downloading PDFs in Bulk
5. Extracting Plain Text from PDFs
6. Searching and Counting Keywords
7. Aggregating Your Findings
8. Additional Information

## Introduction

WW Applicant Screener is a toolset designed to help employers sift through applications on WaterlooWorks. It allows for efficient filtering, downloading, and text extraction from applicant PDFs, followed by keyword search and analysis.

For more in-depth text extraction, refer to the C++-based PDF text extraction tools (https://github.com/galkahana/pdf-text-extraction).

## Usage and Download Instructions

To use these tools, follow the steps below:

1. Ensure Git is Installed: Make sure you have Git installed on your system. You can download it from here (https://git-scm.com/downloads).

2. Clone the Repository: Download the repository from GitHub.

```bash
git clone https://github.com/Portage-Labs/WW-Applicant-Screener.git
```

3. Navigate to the Directory: Open your terminal or command prompt and navigate to the directory where you cloned the repository.

```bash
cd ww-applicant-screener
```

4. Run the Scripts: Follow the instructions for each step below to filter applicants, download PDFs, extract text, and analyze keywords.

## Filtering Applicants

Create a custom application bundle by following [these instructions](https://uwaterloo.ca/hire/waterlooworks-employer-help/view-and-screen-applications#:~:text=To%20download%20specific%20applications%3A). Filter by any metrics you'd like, but know that you can filter with keywords, by work term ratings (dynamically), and by GPA using the provided scripts in this repository.

## Downloading PDFs in Bulk

Download the bundle as individual PDFs by following [these instructions](https://uwaterloo.ca/hire/waterlooworks-employer-help/view-and-screen-applications#:~:text=Bundle%20as%20Individual%20PDFs) (or if you need them as 1 pdf, [these instructions](https://uwaterloo.ca/hire/waterlooworks-employer-help/view-and-screen-applications#specific)). Place them in the `pdf_bundle/` folder in this repository.

## Extracting Plain Text from PDFs

Use the `extract_text.sh` script provided in this repository to extract plain text from the downloaded PDFs. Run the following command in your terminal:

```bash
bash extract_text.sh
```

## Searching and Counting Keywords

Use the `screen_keywords.sh` script to search for and count specific keywords within the extracted text. This script takes keywords as parameters, or you can update the `keywords.txt` file with space-separated keywords all on the first line.

```bash
bash screen_keywords.sh keyword1 keyword2 keyword3 ...
# or if you updated `keywords.txt` with your keywords
bash screen_keywords.sh
```

## Filtering Candidates

Run the `screen_candidates.sh` script to filter candidates based on predefined rules such as work term ratings and GPA. The results will be saved in `./results/screened_candidates.txt`.

```bash
bash screen_candidates.sh
```

## Processing Screened Candidates

Run the `process_screen.sh` script to process the `screened_candidates.txt` file and copy the corresponding PDF files for candidates who passed the screening to `./results/screened_pdfs`.

```bash
bash process_screen.sh
```

If any PDF is not found, you can manually copy it over.

## Concatenating PDFs

Run the `concat_pdfs.py` script to concatenate the PDF files into a single file named `combined_output.pdf`.

```bash
python tools/concat_pdfs.py
```

## Create a Shortlist

While you look through the applications, create a `shortlist.txt` file, in the `results/` directory with content like so:

```text
Aaron Agarwal - Great candidate for x reasons
Ali Mohammed - Good at x tool, some red flags though
...
```

When it's finished, use the shortlist processing tool like so:

```bash
bash tools/process_shortlist.sh
```

## Additional Information

This repository is MIT-Licensed. It is developed by [Portage Labs](https://www.portagelabs.io/).

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.
