instruction_to_opcode = {
    "add" : "0000",
    "addm" : "0001",
    "subtract" : "0010",
    "addi" : "0011",
    "and" : "0101",
    "sll" : "0110",
    "lw" : "0111",
    "sw" : "1001",
    "clr" : "1011",
    "mov" : "1100",
    "cmp" : "1101",
    "bne" : "1110",
    "jmp" : "1111"
}

instruction_to_type = {
    "add" : "r",
    "addm" : "i",
    "subtract" : "r",
    "addi" : "i",
    "and" : "r",
    "sll" : "i",
    "lw" : "i",
    "sw" : "i",
    "clr" : "c",
    "mov" : "i",
    "cmp" : "r",
    "bne" : "j",
    "jmp" : "j"
}

register_to_binary = {
    "zero": "0000",
    "d0": "0001",
    "d1": "0010",
    "d2": "0011",
    "d3": "0100",
    "a0": "0101",
    "a1": "0110",
    "a2": "0111",
    "a3": "1000",
    "sr": "1001",
    "ba": "1010",
    "pc": "1011"
}

def assembly_to_machine_code(assembly_line):
    print(assembly_line)
    assembly_line = assembly_line.lower()
    result = ""
    instruction, register_and_data = assembly_line.split(" ", 1)
    register_and_data = [x.strip() for x in register_and_data.strip().split(",")]
    if instruction == "add" and len(register_and_data) == 2 and register_and_data[1].isdigit():
        instruction = "addm"
    
    result += instruction_to_opcode[instruction]

    ins_type = instruction_to_type[instruction]
    if ins_type == "r":
        # use dict for ensuring the register to be exist
        result += register_to_binary[register_and_data[0]]
        result += register_to_binary[register_and_data[1]]
        result += "0000"

    if ins_type == "i":
        result += register_to_binary[register_and_data[0]]
        result += format(int(register_and_data[1]), '08b')

    if ins_type == "j":
        result += format(int(register_and_data[0]), '012b')

    if ins_type == "c":
        result += register_to_binary[register_and_data[0]]
        result += "00000000"

    return result