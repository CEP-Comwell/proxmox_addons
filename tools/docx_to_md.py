import pypandoc
import os
from datetime import datetime
import sys

# Usage: python docx_to_md.py <input_docx_file>

def main():
    if len(sys.argv) != 2:
        print("Usage: python docx_to_md.py <input_docx_file>")
        sys.exit(1)

    input_docx = sys.argv[1]
    if not os.path.isfile(input_docx):
        print(f"File not found: {input_docx}")
        sys.exit(1)

    output_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'docs', 'concepts')
    os.makedirs(output_dir, exist_ok=True)

    timestamp = datetime.now().strftime('%Y%m%d-%H%M')
    base_name = os.path.splitext(os.path.basename(input_docx))[0]
    output_md = f"{base_name}_imported_{timestamp}.md"
    output_path = os.path.join(output_dir, output_md)

    pypandoc.convert_file(input_docx, 'md', outputfile=output_path)
    print(f"Exported to {output_path}")

if __name__ == "__main__":
    main()
