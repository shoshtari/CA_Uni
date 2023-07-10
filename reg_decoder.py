data = input()


if len(data) == 15:
    print("ID/EXE")
    data = bin(int(data, 16))[2:]
    rd_address = data[0:3]
    rd = data[4:19]
    rs = data[20:35]
    immediate = data[36:51]
    wb = data[52]
    mw = data[53]
    aluop = data[54:55]
    alusrc = data[56]
    is_addm = data[57]
    sw = data[58]
    is_lw = data[59]
    print(f"wb = {wb}\nmw = {mw}\naluop = {aluop}\nalusrc = {alusrc}\nis_addm = {is_addm}\nsw = {sw}\nis_lw = {is_lw}")

