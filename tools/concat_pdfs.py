import os
from PyPDF2 import PdfMerger

# Define the folder containing the PDF files
pdf_folder = './results/screened_pdfs'
# Define the output file
output_file = './results/combined_output.pdf'

# Check if the PDF folder exists
if not os.path.isdir(pdf_folder):
    print(f"Error: PDF folder '{pdf_folder}' does not exist.")
    exit(1)

# List all PDF files in the folder
pdf_files = [f for f in os.listdir(pdf_folder) if f.endswith('.pdf')]

# Check if there are PDF files in the folder
if not pdf_files:
    print(f"Error: No PDF files found in '{pdf_folder}'.")
    exit(1)

# Create a PdfMerger object
merger = PdfMerger()

# Append each PDF file to the merger
for pdf_file in pdf_files:
    pdf_path = os.path.join(pdf_folder, pdf_file)
    merger.append(pdf_path)

# Write out the merged PDF to the output file
merger.write(output_file)
merger.close()

print(f"Combined PDF created: {output_file}")
