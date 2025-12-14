#!/usr/bin/env python3
"""
Assembler.py

32-bit Assembler for Phase 2 Instruction Set Architecture (Custom Team Edition)
Generates ModelSim/Quartus compatible .mem output from .asm files.

Supports:
- Full instruction set from phase2.docx
- .ORG, .DATA, .CODE directives
- Label resolution (2-pass)
- Immediate values with # or direct (hex/dec)
- Memory layout in 4-word-per-line format

Authors: Razan Megahed, Alaa Haytham, Abdelrahman Mohamed, Abdelrahman Zakaria
"""

import re

class Assembler:
    def __init__(self):
        self.opcodes = {
            #r-type opcodes
            'NOP':  '0000000', 'HLT':  '0000001', 'IN':   '0001001', 'OUT':  '0001010',
            'MOV':  '0001011', 'SWAP': '0001101', 'LDM':  '0001110',
            #ALU opcodes
            'SETC': '0010000', 'ADD':  '0011001', 'SUB':  '0011010', 'AND':  '0011011',
            'NOT':  '0011100', 'IADD': '0011101', 'INC':  '0011110',
            #MEMORY OPERATION
            'PUSH': '1000101', 'POP':  '1001100', 'LDD':  '1001010', 'STD':  '1000011',
            'JZ':   '0100000', 'JN':   '0100001', 'JC':   '0100010', 'JMP':  '0100011',
            #BRANCH MEMORY
            'CALL': '1100001', 'RET':  '1100000', 'INT':  '1100011', 'RTI':  '1100010'
        }

        self.directives = ['.ORG', '.DATA', '.CODE']
        self.labels = {}
        self.instructions = []
        self.memory_map = {}
        self.origin = 0
        self.pc = 0

    def parse_hex(self, value):
        value = value.strip()
        if value.startswith('0x') or value.startswith('#0x'):
            return int(value.replace('#', ''), 16)
        return int(value.replace('#', ''))

    def reg(self, name):
        name = name.strip().upper()
        if name.startswith('R') and name[1:].isdigit():
            n = int(name[1:])
            if 0 <= n <= 7:
                return format(n, '03b')
        raise ValueError(f"Invalid register: {name}")

    def imm(self, val):
        return format(self.parse_hex(val) & 0xFFFF, '016b')

    def first_pass(self, code):
        for line in code.splitlines():
            line = line.split(';')[0].strip()
            if not line:
                continue
            if ':' in line:
                label, rest = line.split(':', 1)
                self.labels[label.strip()] = self.pc
                line = rest.strip()
            if not line:
                continue

            tokens = line.split(maxsplit=1)
            op = tokens[0].upper()
            args = tokens[1] if len(tokens) > 1 else ''

            if op in self.directives:
                if op == '.ORG':
                    self.pc = self.origin = self.parse_hex(args)
                continue

            self.instructions.append((self.pc, op, args))
            self.pc += 1

    def second_pass(self):
        for addr, op, args in self.instructions:
            opcode = self.opcodes.get(op)
            if not opcode:
                raise ValueError(f"Unknown instruction: {op}")

            rsrc1 = rsrc2 = rdst = '000'
            imm = '0' * 16

            parts = [p.strip() for p in args.split(',')] if args else []

            # Handle memory format offset(Rx) — case insensitive
            new_parts = []
            for part in parts:
                part = part.strip()
                if '(' in part and ')' in part:
                    match = re.match(r'(#?\d+|#?0x[\da-fA-F]+)\((r\d)\)', part, re.IGNORECASE)
                    if not match:
                        raise ValueError(f"Invalid memory operand format: {part}")
                    offset, reg = match.groups()
                    reg = reg.upper()
                    new_parts.extend([reg, offset])
                else:
                    new_parts.append(part)
            parts = new_parts

            if op in ['NOP', 'HLT', 'SETC', 'RET', 'RTI', 'JZ', 'JN', 'JC', 'JMP', 'CALL', 'INT']:
                pass
            elif op in ['IN', 'POP', 'PUSH']:
                rdst = self.reg(parts[0])
            elif op == 'OUT':
                pass
            elif op in ['MOV', 'SWAP']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
            elif op == 'LDM':
                rdst = self.reg(parts[0])
                imm = self.imm(parts[1])
            elif op in ['ADD', 'SUB', 'AND']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                rsrc2 = self.reg(parts[2])
            elif op in ['NOT', 'INC']:
                rdst = self.reg(parts[0])
            elif op == 'IADD':
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                imm = self.imm(parts[2])
            elif op == 'LDD':
                rsrc1 = self.reg(parts[0])
                rdst = self.reg(parts[1])
                imm = self.imm(parts[2])
            elif op == 'STD':
                rsrc1 = self.reg(parts[0])
                rsrc2 = self.reg(parts[1])
                imm = self.imm(parts[2])

            instr = f"{opcode}{rsrc1}{rsrc2}{rdst}00{imm}"
            self.memory_map[addr] = instr

    def generate_output(self):
        return [(addr, self.memory_map[addr]) for addr in sorted(self.memory_map)]

    def write_output(self, filename, fmt='mem'):
        out = self.generate_output()
        if fmt == 'mem':
            with open(filename, 'w') as f:
                f.write("// memory data file\n")
                f.write("// format=bin addressradix=h dataradix=b version=1.0 wordsperline=4\n\n")
                for i in range(0, len(out), 4):
                    group = out[i:i+4]
                    addr = group[0][0] if group else 0
                    f.write(f"@{addr:X}  ")
                    for _, binval in group:
                        f.write(f"{binval} ")
                    f.write("\n")

    def assemble(self, code):
        self.first_pass(code)
        self.second_pass()
        return self.generate_output()