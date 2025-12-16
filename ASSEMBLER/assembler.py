#!/usr/bin/env python3
"""
assembler.py

32-bit Assembler for Phase 2 ISA
Generates ModelSim / Quartus compatible .mem files
"""

import re


class Assembler:
    def __init__(self):
        # ---------------- OPCODES ----------------
        self.opcodes = {
            # R-type
            'NOP': '0000000', 'HLT': '0000001',
            'IN': '0001001', 'OUT': '0001010',
            'MOV': '0001011', 'SWAP': '0001101',
            'LDM': '0001110',

            # ALU
            'SETC': '0010000', 'ADD': '0011001',
            'SUB': '0011010', 'AND': '0011011',
            'NOT': '0011100', 'IADD': '0011101',
            'INC': '0011110',

            # Memory
            'PUSH': '1000101', 'POP': '1001100',
            'LDD': '1001010', 'STD': '1000011',

            # Branch
            'JZ': '0100000', 'JN': '0100001',
            'JC': '0100010', 'JMP': '0100011',

            # Mem-branch
            'CALL': '1100001', 'RET': '1100000',
            'INT': '1100011', 'RTI': '1100010'
        }

        self.directives = ['.ORG']
        self.labels = {}
        self.instructions = []
        self.memory = {}
        self.pc = 0

    def strip_comments(self, line):
        return re.split(r';|//|#', line)[0].strip()

    def parse_number(self, value):
        value = self.strip_comments(value)
        value = value.replace('#', '').strip()

        if re.fullmatch(r'[0-9A-Fa-f]+', value):
            return int(value, 16)

        if value.startswith(('0x', '0X')):
            return int(value, 16)

        return int(value, 10)

    def reg(self, r):
        r = r.upper()
        if not r.startswith('R') or not r[1:].isdigit():
            raise ValueError(f"Invalid register: {r}")
        n = int(r[1:])
        if not (0 <= n <= 7):
            raise ValueError(f"Register out of range: {r}")
        return format(n, '03b')

    def imm(self, v):
        return format(self.parse_number(v) & 0xFFFF, '016b')

    def first_pass(self, code):
        self.pc = 0
        self.instructions.clear()
        self.labels.clear()

        for raw in code.splitlines():
            line = self.strip_comments(raw)
            if not line:
                continue

            if ':' in line:
                label, line = line.split(':', 1)
                self.labels[label.strip()] = self.pc
                line = line.strip()
                if not line:
                    continue

            parts = line.split(maxsplit=1)
            op = parts[0].upper()
            args = parts[1] if len(parts) > 1 else ''

            if op in self.directives:
                if op == '.ORG':
                    self.pc = self.parse_number(args)
                continue

            if re.fullmatch(r'#?\d+|#?0[xX][\da-fA-F]+', op):
                self.instructions.append((self.pc, 'DATA', self.parse_number(op)))
                self.pc += 1
                continue

            self.instructions.append((self.pc, op, args))
            self.pc += 1

    def second_pass(self):
        self.memory.clear()

        for addr, op, args in self.instructions:
            if op == 'DATA':
                self.memory[addr] = format(args & 0xFFFFFFFF, '032b')
                continue

            opcode = self.opcodes[op]
            rdst = rsrc1 = rsrc2 = '000'
            imm = '0' * 16

            parts = [p.strip() for p in args.split(',')] if args else []

            expanded = []
            for p in parts:
                m = re.match(r'(#?\w+)\((R\d)\)', p, re.IGNORECASE)
                if m:
                    off, r = m.groups()
                    expanded.extend([r.upper(), off])
                else:
                    expanded.append(p)
            parts = expanded

            if op in ['IN', 'POP', 'PUSH', 'INC', 'NOT']:
                rdst = self.reg(parts[0])

            elif op in ['MOV', 'SWAP']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])

            elif op in ['ADD', 'SUB', 'AND']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                rsrc2 = self.reg(parts[2])

            elif op == 'IADD':
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                if parts[2].upper().startswith('R'):
                    raise ValueError(
                        f"IADD expects an immediate, not register ({parts[2]})"
                    )
                imm = self.imm(parts[2])

            elif op == 'LDM':
                rdst = self.reg(parts[0])
                imm = self.imm(parts[1])

            elif op == 'LDD':
                rsrc1 = self.reg(parts[0])
                rdst = self.reg(parts[1])
                imm = self.imm(parts[2])

            elif op == 'STD':
                rsrc1 = self.reg(parts[0])
                rsrc2 = self.reg(parts[1])
                imm = self.imm(parts[2])

            elif op in ['JZ', 'JN', 'JC', 'JMP']:
                target = parts[0]
                if target.upper().startswith('R'):
                    rsrc1 = self.reg(target)
                else:
                    imm = format(self.labels[target] & 0xFFFF, '016b')

            self.memory[addr] = f"{opcode}{rsrc1}{rsrc2}{rdst}00{imm}"

    def write_output(self, filename):
        addrs = sorted(self.memory)
        with open(filename, 'w') as f:
            f.write("// memory data file\n")
            f.write("// format=bin addressradix=h dataradix=b wordsperline=4\n\n")
            line, start, last = [], None, None
            for addr in addrs:
                if start is None or addr != last + 1 or len(line) == 4:
                    if line:
                        f.write(f"@{start:X}  " + " ".join(line) + "\n")
                    line, start = [], addr
                line.append(self.memory[addr])
                last = addr
            if line:
                f.write(f"@{start:X}  " + " ".join(line) + "\n")

    def assemble(self, code):
        self.first_pass(code)
        self.second_pass()