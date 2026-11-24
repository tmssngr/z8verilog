from pathlib import Path
import re


# Gowin accepts a P,N pin pair on the positive port. nextpnr needs one pin per
# port, including the negative port, and matching electrical settings for both.
def expand_pair(match):
    positive, p_pin, n_pin = match.groups()
    negative = positive.replace("_p[", "_n[")
    return f'IO_LOC "{positive}" {p_pin};\nIO_LOC "{negative}" {n_pin};'


cst = Path("tangnano9k_hdmi.cst").read_text()
cst = re.sub(r'IO_LOC\s+"(hdmi_tx_p\[\d+\])"\s+(\d+)\s*,\s*(\d+)\s*;', expand_pair, cst)
cst = re.sub(
    r'IO_PORT\s+"hdmi_tx_p\[\d+\]"[^;]*;',
    lambda match: match[0] + "\n" + match[0].replace("hdmi_tx_p[", "hdmi_tx_n["),
    cst,
)
# This pre-pack hook runs before the Gowin packer loads its CST file.
Path("../build/jtc_es40_hdmi.cst").write_text(cst)

# Frequencies in MHz for the active PLL settings in top_es40_hdmi.v.
ctx.addClock("clk", 27.0)
ctx.addClock("clkDiv", 4.0)
ctx.addClock("hdmi_clk", 25.2)
ctx.addClock("hdmi_clk_5x", 126.0)
