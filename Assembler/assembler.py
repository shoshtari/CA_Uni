import sys
from convertor import assembly_to_machine_code

def write_list_to_file(li, file_name):
    pass


if len(sys.argv) < 2:
    raise ValueError("pls enter the file address")

file_address = sys.argv[1]

results = []
with open(file_address, 'r') as f:
    for line in f:
        assembly_line = line.rstrip('\n')
        results.append(assembly_to_machine_code(assembly_line)+'\n')

with open("program.exe", 'w') as f:
    f.writelines(results)

        
