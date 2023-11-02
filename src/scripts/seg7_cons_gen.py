Seg1_d_Pin={
    "P31":6,
    "P30":1,
    "P27":5,

    "P21":2,
    "P20":3,
    "P15":4,
    "P13":0,

}
Seg1_sel_Pin={
    "P32":0,
    "P29":1,
    "P28":2,
    "P12":3
}
led_Pin={
    "P10":"R2",
    "P7":"Y2",
    "P6":"G2",
    "P5":"R1",
    "P4":"Y1",
    "P3":"G1"
}
Key_Pin={
    "P110":"Key_plus",
    "P111":"Key_sub",
    "P113":"Key_state<0>",
    "P114":"Key_state<1>",
}
for i in Seg1_d_Pin:
    print(f"NET seg71_d<{Seg1_d_Pin[i]}>  LOC = {i} | IOSTANDARD = LVTTL;")

print()
for i in Seg1_sel_Pin:
    print(f"NET seg71_sel<{Seg1_sel_Pin[i]}>  LOC = {i} | IOSTANDARD = LVTTL;")

print()

for i in led_Pin:
    print(f"NET {led_Pin[i]}  LOC = {i} | IOSTANDARD = LVTTL;")

print()

for i in Key_Pin:
    print(f"NET {Key_Pin[i]}  LOC = {i} | IOSTANDARD = LVTTL;")