#!/usr/bin/env python3
"""
Assembler.py

32-bit Assembler for Phase 2 Instruction Set Architecture 

Supports:
- Full instruction set from phase2.docx
- .ORG, .DATA, .CODE directives
- Label resolution (2-pass)
- Immediate values with # or direct (hex/dec)
- Memory layout in 4-word-per-line format
"""

import re

class Assembler:
    def __init__(self):
        self.opcodes = {
            # R-Type + Single ops
            'NOP':  '0000000', 'HLT':  '0000001', 'IN':   '0001001', 'OUT':  '0001010',
            'MOV':  '0001011', 'SWAP': '0001101', 'LDM':  '0001110',

            # ALU ops
            'SETC': '0010000', 'ADD':  '0011001', 'SUB':  '0011010', 'AND':  '0011011',
            'NOT':  '0011100', 'IADD': '0011101', 'INC':  '0011110',

            # Memory
            'PUSH': '1000101', 'POP':  '1001100', 'LDD':  '1001010', 'STD':  '1000011',

            # Branch
            'JZ':   '0100000', 'JN':   '0100001', 'JC':   '0100010', 'JMP':  '0100011',
            #branch -memory
            
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
        if value.startswith('0x'):
            return int(value, 16)
        return int(value)

    def reg(self, name):
        name = name.strip().upper()
        if name.startswith('R') and name[1:].isdigit():
            n = int(name[1:])
            if 0 <= n <= 7:
                return format(n, '03b')
        raise ValueError(f"Invalid register: {name}")

    def imm(self, val):
        val = val.lstrip('#')
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
            parts = [a.strip() for a in re.split(r',\s*', args)] if args else []

            if op in ['NOP', 'HLT', 'SETC', 'RET', 'RTI']:
                pass
            elif op in ['IN', 'POP']:
                rdst = self.reg(parts[0])
            elif op in ['OUT', 'PUSH']:
                rsrc1 = self.reg(parts[0])
            elif op in ['MOV', 'SWAP']:
                rdst, rsrc1 = self.reg(parts[0]), self.reg(parts[1])
            elif op == 'LDM':
                rdst, imm = self.reg(parts[0]), self.imm(parts[1])
            elif op in ['ADD', 'SUB', 'AND']:
                rdst, rsrc1, rsrc2 = self.reg(parts[0]), self.reg(parts[1]), self.reg(parts[2])
            elif op in ['NOT', 'INC']:
                rdst = rsrc1 = self.reg(parts[0])
            elif op == 'IADD':
                rdst, rsrc1, imm = self.reg(parts[0]), self.reg(parts[1]), self.imm(parts[2])
            elif op == 'LDD':
                rdst, rsrc1, imm = self.reg(parts[0]), self.reg(parts[1]), self.imm(parts[2])
            elif op == 'STD':
                rsrc1, rsrc2, imm = self.reg(parts[0]), self.reg(parts[1]), self.imm(parts[2])
            elif op in ['JZ', 'JN', 'JC', 'JMP', 'CALL']:
                target = parts[0]
                val = self.labels.get(target, None)
                imm = self.imm(val if val is not None else target)
            elif op == 'INT':
                imm = self.imm(parts[0])

            instr = f"{opcode}{rsrc1}{rsrc2}{rdst}{'00'}{imm}"
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
