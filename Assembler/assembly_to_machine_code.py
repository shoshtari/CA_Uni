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
    "d0": "0000",
    "d1": "0001",
    "d2": "0010",
    "d3": "0011",
    "d4": "0100",
    "d5": "0101",
    "d6": "0110",
    "d7": "0111",
    "d8": "1000",
    "d9": "1001",
    "d10": "1010",
    "d11": "1011",
    "BA": "1010"
}

def assembly_to_machine_code(assembly_line):
    print(assembly_line)
    result = ""
    instruction, register_and_data = assembly_line.split(" ", 1)
    instruction = instruction.lower()
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