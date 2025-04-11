import os
import pandas as pd

def txt_to_excel(folder_path):
    # Check if folder exists
    if not os.path.exists(folder_path):
        print(f"Folder does not exist: {folder_path}")
        return

    # List all .txt files in the folder
    txt_files = [f for f in os.listdir(folder_path) if f.lower().endswith('.txt')]

    if not txt_files:
        print("No .txt files found in the folder.")
        return

    for txt_file in txt_files:
        txt_path = os.path.join(folder_path, txt_file)
        excel_path = os.path.join(folder_path, os.path.splitext(txt_file)[0] + '.xlsx')

        try:
            # Read the TXT file assuming it's comma-separated
            df = pd.read_csv(txt_path, sep=',')
            # Save as Excel
            df.to_excel(excel_path, index=False, engine='openpyxl')
            print(f"Converted: {txt_file} -> {os.path.basename(excel_path)}")
        except Exception as e:
            print(f"Failed to convert {txt_file}: {e}")

# Example usage
folder = r'C:\path\to\your\folder'  # Update this path
txt_to_excel(folder)
