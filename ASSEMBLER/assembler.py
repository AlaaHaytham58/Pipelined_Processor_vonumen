#!/usr/bin/env python3
import re

class Assembler:
    def __init__(self):
        self.opcodes = {
            'NOP':  '0000000', 'HLT':  '0000001', 'IN':   '0001001', 'OUT':  '0001010',
            'MOV':  '0001011', 'SWAP': '0001101', 'LDM':  '0001110',
            'SETC': '0010111', 'ADD':  '0011001', 'SUB':  '0011010', 'AND':  '0011011',
            'NOT':  '0011100', 'IADD': '0011101', 'INC':  '0011110',
            'PUSH': '1000101', 'POP':  '1001100', 'LDD':  '1001010', 'STD':  '1000011',
            'JZ':   '0100000', 'JN':   '0100001', 'JC':   '0100010', 'JMP':  '0100011',
            'CALL': '1100001', 'RET':  '1100000', 'INT':  '1100011', 'RTI':  '1100010'
        }
        self.labels = {}
        self.instructions = []
        self.memory = {}
        self.pc = 0

    def strip_comments(self, line):
        return re.split(r'#|;', line)[0].strip()

    def parse_number(self, value):
        """Extracts numeric value from strings like '0x10', '10', or 'R3' (for IADD)"""
        if not value: return None
        clean_val = value.strip().upper().replace('R', '').replace('0X', '')
        try:
            return int(clean_val, 16)
        except ValueError:
            return None

    def reg(self, r):
        """Converts register string 'R1' to 3-bit binary '001'"""
        r = r.upper().strip()
        if r.startswith('R'):
            try:
                return format(int(r[1:]), '03b')
            except ValueError:
                return '000'
        return '000'

    def imm(self, v):
        """Converts value to 16-bit binary string"""
        val = self.parse_number(v)
        return format(val & 0xFFFF, '016b') if val is not None else '0' * 16

    def first_pass(self, code):
        self.pc = 0
        self.instructions.clear()
        self.labels.clear()
        for line in code.splitlines():
            line = self.strip_comments(line)
            if not line: continue

            # Label handling
            if ':' in line:
                label, line = line.split(':', 1)
                self.labels[label.strip()] = self.pc
                line = line.strip()
                if not line: continue

            parts = line.split(maxsplit=1)
            op = parts[0].upper()
            args = parts[1] if len(parts) > 1 else ''

            if op == '.ORG':
                val = self.parse_number(args)
                if val is not None: self.pc = val
                continue

            # Check if line is a raw data value (Reset vector/Interrupt vector)
            if self.parse_number(op) is not None and op not in self.opcodes:
                self.instructions.append((self.pc, 'DATA', self.parse_number(op)))
            else:
                self.instructions.append((self.pc, op, args))
            self.pc += 1

    def second_pass(self):
        self.memory.clear()
        for addr, op, args in self.instructions:
            if op == 'DATA':
                self.memory[addr] = format(args & 0xFFFFFFFF, '032b')
                continue

            opcode = self.opcodes.get(op, '0000000')
            rdst = rsrc1 = rsrc2 = '000'
            imm_val = '0' * 16
            parts = [p.strip() for p in args.split(',')] if args else []

            # Instruction field mapping
            if op == 'IN':
                rsrc1 = self.reg(parts[0]) # Switched logic: IN uses rsrc1
            elif op == 'OUT':
                rdst = self.reg(parts[0]) # Switched logic: OUT uses rdst
            elif op == 'IADD':
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                imm_val = self.imm(parts[2]) # Fix for third operand as immediate
            elif op == 'LDM':
                rdst = self.reg(parts[0])
                imm_val = self.imm(parts[1])
            elif op in ['ADD', 'SUB', 'AND']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                rsrc2 = self.reg(parts[2])
            elif op in ['NOT', 'INC', 'PUSH', 'POP']:
                rdst = self.reg(parts[0])
            elif op in ['MOV', 'SWAP']:
                rsrc1 = self.reg(parts[0])
                rsrc2 = self.reg(parts[1])
            elif op in ['JZ', 'JN', 'JC', 'JMP', 'CALL']:
                if parts and parts[0].upper().startswith('R'):
                    rsrc1 = self.reg(parts[0])
                elif parts:
                    # Check labels first, then raw numbers
                    target = self.labels.get(parts[0])
                    if target is None:
                        target = self.parse_number(parts[0])
                    if target is not None:
                        imm_val = format(target & 0xFFFF, '016b')

            # Construct 32-bit word: [Immediate(16)][Rdst(3)][Rsrc2(3)][Rsrc1(3)][Opcode(7)]
            self.memory[addr] = f"{imm_val}{rdst}{rsrc2}{rsrc1}{opcode}"
    def write_output(self, filename):
        if not self.memory: return
        max_addr = max(self.memory.keys())
        with open(filename, 'w') as f:
            for i in range(max_addr + 1):
                f.write(f"{self.memory.get(i, '0' * 32)}\n")

    def assemble(self, code):
        self.first_pass(code)
        self.second_pass()
        return self.memory
