import pdfplumber
import re
import os
import sys

def usage():
    print("Usage: python pdf_to_md.py <PDF_PATH> <MD_PATH>")
    print("Example: python pdf_to_md.py ./import/edgesec-radius.pdf ./import/edgesec-radius.md")
    sys.exit(1)

def format_line(line):
    line = line.strip()
    # Bold headings: lines in ALL CAPS and longer than 5 chars
    if line.isupper() and len(line) > 5:
        return f"**{line}**\n"
    # Bullet points: lines starting with '-', '•', or '*'
    if re.match(r"^[-•*]\s+", line):
        return f"- {line[2:]}\n"
    return line + "\n"

def pdf_to_markdown(pdf_path, md_path):
    with pdfplumber.open(pdf_path) as pdf, open(md_path, "w", encoding="utf-8") as md_file:
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                for line in text.split("\n"):
                    md_file.write(format_line(line))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        usage()
    PDF_PATH = sys.argv[1]
    MD_PATH = sys.argv[2]
    if not os.path.exists(PDF_PATH):
        print(f"PDF not found: {PDF_PATH}")
        sys.exit(1)
    pdf_to_markdown(PDF_PATH, MD_PATH)
    print(f"Markdown saved to {MD_PATH}")
