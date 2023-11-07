default_info="""
NET "clk" LOC = P57;

# NET "rst_n" LOC = P111;
# NET "debug[0]" LOC = P113 | IOSTANDARD = LVTTL;
# NET "debug[1]" LOC = P114 | IOSTANDARD = LVTTL;

NET "clk" IOSTANDARD = LVCMOS33;

# NET "rst_n" IOSTANDARD = LVTTL   ;

"""
print(default_info+"\n")

Seg1_d_Pin={
    "P31":6,
    "P30":1,
    "P27":5,

    "P21":2,
    "P20":3,
    "P15":4,
    "P13":0,

}
for i in Seg1_d_Pin:
    print(f"NET seg71_d<{Seg1_d_Pin[i]}>  LOC = {i} | IOSTANDARD = LVTTL;")

print()
Seg1_sel_Pin={
    "P32":0,
    "P29":1,
    "P28":2,
    "P12":3
}
for i in Seg1_sel_Pin:
    print(f"NET seg71_sel<{Seg1_sel_Pin[i]}>  LOC = {i} | IOSTANDARD = LVTTL;")

print()

led_Pin={
    "P10":"o_G1",
    "P7": "o_Y1",
    "P3": "o_R2_L",
    "P126":"o_R2"
}
for i in led_Pin:
    print(f"NET {led_Pin[i]}  LOC = {i} | IOSTANDARD = LVTTL;")

SN74HC595={
    "P4":"SN74HC595_data",
    "P5":"SN74HC595_refresh_clk",
    "P6":"SN74HC595_data_clk",
}

for i in SN74HC595:
    print(f"NET {SN74HC595[i]}  LOC = {i} | IOSTANDARD = LVTTL;")

print()

Key_Pin={
    "P110":"Key_plus",
    "P111":"Key_sub",
    "P113":"Key_state<0>",
    "P114":"Key_state<1>",
}

for i in Key_Pin:
    print(f"NET {Key_Pin[i]}  LOC = {i} | IOSTANDARD = LVTTL;")

print()





Seg2_d_Pin={
    "P76":2,
    "P77":3,
    "P79":4,
    "P90":0,

    "P93":6,
    "P102":1,
    "P105":5,

}
for i in Seg2_d_Pin:
    print(f"NET seg72_d<{Seg2_d_Pin[i]}>  LOC = {i} | IOSTANDARD = LVTTL;")

print()
Seg2_sel_Pin={
    "P91":3,

    "P92":0,
    "P103":1,
    "P104":2,
 
}
for i in Seg2_sel_Pin:
    print(f"NET seg72_sel<{Seg2_sel_Pin[i]}>  LOC = {i} | IOSTANDARD = LVTTL;")
