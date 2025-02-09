using Measurements

# Given measured values with uncertainties
R1 = 219.9 ± 2.0
R2 = 101.2 ± 1.0
R3 = 217.8 ± 2.0
R4 = 101.7 ± 1.0
V = 12.12 ± 0.03

# Thevenin resistance formula
Rth = 1 / (1/R1 + 1/R3) + R2
Rth = 1 / (1/Rth + 1/R4)

# Thevenin voltage formula (assuming given voltage values)
# Vth = -1.944 ± 0.007
Vth = R4 * (V * R3 / (R1*R2 + R1*R3 + R1*R4 + R2*R3 + R3*R4))

println("Thevenin Voltage: ", Vth)
println("Thevenin Resistance: ", Rth)
