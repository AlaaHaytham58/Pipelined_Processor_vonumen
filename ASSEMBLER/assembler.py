#!/usr/bin/env python3
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
        self.directives = ['.ORG']
        self.labels = {}
        self.instructions = []
        self.memory = {}
        self.pc = 0

    def strip_comments(self, line):
        return re.split(r';|//|#', line)[0].strip()

    def parse_number(self, value):
        value = self.strip_comments(value).strip().replace('0x', '').replace('0X', '')
        try:
            return int(value, 16)
        except ValueError:
            raise ValueError(f"Invalid numeric/hex value: {value}")

    def reg(self, r):
        r = r.upper().strip()
        if not r.startswith('R') or not r[1:].isdigit():
            raise ValueError(f"Invalid register: {r}")
        n = int(r[1:])
        return format(n, '03b')

    def imm(self, v):
        return format(self.parse_number(v) & 0xFFFF, '016b')

    def first_pass(self, code):
        self.pc = 0
        self.instructions.clear()
        self.labels.clear()
        lines = code.splitlines()

        idx = 0
        while idx < len(lines):
            line = self.strip_comments(lines[idx])
            if not line:
                idx += 1
                continue

            if ':' in line:
                label, line = line.split(':', 1)
                self.labels[label.strip()] = self.pc
                line = line.strip()
                if not line:
                    idx += 1
                    continue

            parts = line.split(maxsplit=1)
            op = parts[0].upper()
            args = parts[1] if len(parts) > 1 else ''

            if op == '.ORG':
                self.pc = self.parse_number(args)
                idx += 1
                continue

            if re.fullmatch(r'(0[xX])?[0-9a-fA-F]+', op) and op.upper() not in self.opcodes:
                self.instructions.append((self.pc, 'DATA', self.parse_number(op)))
            else:
                self.instructions.append((self.pc, op, args))

            self.pc += 1
            idx += 1

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

            # --- Fixed Logic for IN and OUT ---
            if op == 'IN':
                rdst = self.reg(parts[0])
            elif op == 'OUT':
                rdst = self.reg(parts[0])
            # ----------------------------------
            elif op in ['NOT', 'INC', 'POP', 'PUSH']:
                rdst = self.reg(parts[0])
            elif op in ['MOV', 'SWAP']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
            elif op in ['ADD', 'SUB', 'AND']:
                rdst = self.reg(parts[0])
                rsrc1 = self.reg(parts[1])
                rsrc2 = self.reg(parts[2])
            elif op == 'LDM':
                rdst = self.reg(parts[0])
                imm_val = self.imm(parts[1])
            elif op in ['JZ', 'JN', 'JC', 'JMP']:
                if parts[0].upper().startswith('R'):
                    rsrc1 = self.reg(parts[0])
                else:
                    imm_val = format(self.labels.get(parts[0], 0) & 0xFFFF, '016b')

            # Build the 32-bit instruction
            self.memory[addr] = f"{imm_val}{rdst}{rsrc2}{rsrc1}{opcode}"

    def write_output(self, filename):
        if not self.memory: return
        max_addr = max(self.memory.keys())
        with open(filename, 'w') as f:
            for i in range(max_addr + 1):
                f.write(f"{self.memory.get(i, '0' * 32)}\n")

    def assemble(self, code, filename="output.mem"):
        self.first_pass(code)
        self.second_pass()
        self.write_output(filename)

# import re

# class Assembler:
#     def __init__(self):
#         self.opcodes = {
#             'NOP':  '0000000', 'HLT':  '0000001', 'IN':   '0001001', 'OUT':  '0001010',
#             'MOV':  '0001011', 'SWAP': '0001101', 'LDM':  '0001110',
#             'SETC': '0010111', 'ADD':  '0011001', 'SUB':  '0011010', 'AND':  '0011011',
#             'NOT':  '0011100', 'IADD': '0011101', 'INC':  '0011110',
#             'PUSH': '1000101', 'POP':  '1001100', 'LDD':  '1001010', 'STD':  '1000011',
#             'JZ':   '0100000', 'JN':   '0100001', 'JC':   '0100010', 'JMP':  '0100011',
#             'CALL': '1100001', 'RET':  '1100000', 'INT':  '1100011', 'RTI':  '1100010'
#         }
#         self.directives = ['.ORG']
#         self.labels = {}
#         self.instructions = []
#         self.memory = {}
#         self.pc = 0

#     def strip_comments(self, line):
#         return re.split(r';|//|#', line)[0].strip()

#     def parse_number(self, value):
#         """Treats all numeric strings as hexadecimal by default."""
#         value = self.strip_comments(value).strip().replace('0x', '').replace('0X', '')
#         try:
#             return int(value, 16)
#         except ValueError:
#             # If it's not a valid hex string, it might be a label or error
#             raise ValueError(f"Invalid numeric/hex value: {value}")

#     def reg(self, r):
#         r = r.upper()
#         if not r.startswith('R') or not r[1:].isdigit():
#             raise ValueError(f"Invalid register: {r}")
#         n = int(r[1:])
#         return format(n, '03b')

#     def imm(self, v):
#         return format(self.parse_number(v) & 0xFFFF, '016b')

#     def first_pass(self, code):
#         self.pc = 0
#         self.instructions.clear()
#         self.labels.clear()
#         lines = code.splitlines()

#         idx = 0
#         while idx < len(lines):
#             line = self.strip_comments(lines[idx])
#             if not line:
#                 idx += 1
#                 continue

#             if ':' in line:
#                 label, line = line.split(':', 1)
#                 self.labels[label.strip()] = self.pc
#                 line = line.strip()
#                 if not line:
#                     idx += 1
#                     continue

#             parts = line.split(maxsplit=1)
#             op = parts[0].upper()
#             args = parts[1] if len(parts) > 1 else ''

#             if op == '.ORG':
#                 self.pc = self.parse_number(args)

#                 # Check next line for a raw hex number
#                 next_idx = idx + 1
#                 while next_idx < len(lines):
#                     next_line = self.strip_comments(lines[next_idx])
#                     if next_line:
#                         # If the next line is purely a hex number (e.g., 0xA0 or A0)
#                         if re.fullmatch(r'(0[xX])?[0-9a-fA-F]+', next_line) and next_line.upper() not in self.opcodes:
#                             val = self.parse_number(next_line)
#                             self.instructions.append((self.pc, 'DATA', val))
#                             idx = next_idx # Consume the number line
#                             self.pc += 1
#                             break
#                         else:
#                             break # It's a normal instruction
#                     next_idx += 1
#                 idx += 1
#                 continue

#             # Standard instruction handling
#             if re.fullmatch(r'(0[xX])?[0-9a-fA-F]+', op) and op.upper() not in self.opcodes:
#                 self.instructions.append((self.pc, 'DATA', self.parse_number(op)))
#             else:
#                 self.instructions.append((self.pc, op, args))

#             self.pc += 1
#             idx += 1

#     def second_pass(self):
#         self.memory.clear()
#         for addr, op, args in self.instructions:
#             if op == 'DATA':
#                 self.memory[addr] = format(args & 0xFFFFFFFF, '032b')
#                 continue

#             opcode = self.opcodes.get(op, '0000000')
#             rdst = rsrc1 = rsrc2 = '000'
#             imm = '0' * 16
#             parts = [p.strip() for p in args.split(',')] if args else []

#             # (Logic for different instruction types remains the same as your original)
#             if op in ['NOT', 'INC', 'POP', 'PUSH']:
#                 rdst = self.reg(parts[0])
#             elif op in ['MOV', 'SWAP']:
#                 rdst = self.reg(parts[0]); rsrc1 = self.reg(parts[1])
#             elif op in ['ADD', 'SUB', 'AND']:
#                 rdst = self.reg(parts[0]); rsrc1 = self.reg(parts[1]); rsrc2 = self.reg(parts[2])
#             elif op == 'LDM':
#                 rdst = self.reg(parts[0]); imm = self.imm(parts[1])
#             elif op in ['JZ', 'JN', 'JC', 'JMP']:
#                 if parts[0].upper().startswith('R'): rsrc1 = self.reg(parts[0])
#                 else: imm = format(self.labels.get(parts[0], 0) & 0xFFFF, '016b')

#             self.memory[addr] = f"{imm}{rdst}{rsrc2}{rsrc1}{opcode}"

#     def write_output(self, filename):
#         if not self.memory: return
#         max_addr = max(self.memory.keys())
#         with open(filename, 'w') as f:
#             for i in range(max_addr + 1):
#                 f.write(f"{self.memory.get(i, '0' * 32)}\n")

#     def assemble(self, code, filename="output.mem"):
#         self.first_pass(code)
#         self.second_pass()
#         self.write_output(filename)