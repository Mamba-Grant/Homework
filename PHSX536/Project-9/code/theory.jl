using DataFrames, Plots, Unitful, Dates, PyCall, Measurements
iminuit = pyimport("iminuit")
theme(:wong2)

idx2resistance(x) = (5.1 * x + 2.2) * u"Ω"
resistance2idx(x) = ustrip(x / 5.1 - 2.2) 

# --------------------------------

RE = (22.1 ± 0.3)*u"Ω"
β = 270.8 ± 6.2
ZCin = β * RE
RL = (220.3 ± 2.0)*u"Ω"
G = 3u"V"
Vin = 1u"V"

RC = (G * RE * ZCin * RL + G * RE^2 * RL) / (Vin * ZCin * RL - G * RE * ZCin - G*RE^2)

# --------------------------------

VCC = (12.12 ± 0.02)*u"V"
VC = 7u"V"
VBE = 0.6u"V"

IC = VC / RC
IB = IC / β
VE = IC * RE
VB = VE + VBE

R2 = (100.5e3 ± 1.1e3)u"Ω"
REQ = R2 * ZCin / (R2 + ZCin)

R1 = (REQ * VCC)
