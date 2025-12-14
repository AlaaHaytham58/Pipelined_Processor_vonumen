#!/usr/bin/env python3
"""
Script to run the custom 32-bit assembler on any .asm file in current dir
Generates .mem file compatible with Quartus/ModelSim from the .asm source
"""

import os
import sys
from assembler import Assembler


def main():
    print("32-bit Assembly to Memory Formatter")
    print("===========================")

    current_dir = os.path.dirname(os.path.abspath(__file__))
    asm_files = [f for f in os.listdir(current_dir) if f.endswith('.asm')]

    if not asm_files:
        print("Error: No .asm files found.")
        return 1

    input_file = None
    if len(asm_files) == 1:
        input_file = asm_files[0]
        print(f"Found file: {input_file}")
    else:
        print("Multiple .asm files found:")
        for i, f in enumerate(asm_files, 1):
            print(f"  {i}. {f}")
        try:
            idx = int(input("Enter number of file to assemble: "))
            input_file = asm_files[idx - 1]
        except:
            print("Invalid input.")
            return 1

    input_path = os.path.join(current_dir, input_file)
    output_file = os.path.splitext(input_file)[0] + ".mem"
    output_path = os.path.join(current_dir, output_file)

    try:
        with open(input_path, 'r') as f:
            code = f.read()

        assembler = Assembler()
        assembler.assemble(code)
        assembler.write_output(output_path, 'mem')

        print(f"\nSuccess! Output saved to: {output_file}")
        with open(output_path) as f:
            lines = f.readlines()
            print("\nPreview:")
            for line in lines[:20]:
                print(line.strip())
            if len(lines) > 20:
                print("...")

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
