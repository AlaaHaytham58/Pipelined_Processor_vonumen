#!/usr/bin/env python3
"""
run.py

Runner script for the 32-bit assembler.
Allows user to choose which .txt assembly file to assemble.
"""

import os
import sys
from assembler import Assembler


def main():
    print("32-bit Assembly to Memory Formatter")
    print("===========================")

    current_dir = os.path.dirname(os.path.abspath(__file__))

    # Find all .txt files
    txt_files = sorted([f for f in os.listdir(current_dir) if f.endswith('.txt')])

    if not txt_files:
        print("Error: No .txt assembly files found.")
        return 1

    # Single file → auto-select
    if len(txt_files) == 1:
        input_file = txt_files[0]
        print(f"Found file: {input_file}")

    # Multiple files → user chooses
    else:
        print("Available assembly files:")
        for i, f in enumerate(txt_files, start=1):
            print(f"  {i}. {f}")

        try:
            choice = int(input("\nSelect file number to assemble: "))
            input_file = txt_files[choice - 1]
        except (ValueError, IndexError):
            print("Invalid selection.")
            return 1

    input_path = os.path.join(current_dir, input_file)
    output_file = os.path.splitext(input_file)[0] + ".mem"
    output_path = os.path.join(current_dir, output_file)

    try:
        with open(input_path, 'r') as f:
            code = f.read()

        assembler = Assembler()
        assembler.assemble(code)
        assembler.write_output(output_path)

        print(f"\nSuccess! Output saved to: {output_file}")

        # Preview first few lines
        print("\nPreview:")
        with open(output_path) as f:
            for i, line in enumerate(f):
                if i >= 10:
                    break
                print(line.rstrip())

    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
