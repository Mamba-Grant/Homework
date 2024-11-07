import math as m

T = float(input("Enter the temperature, degrees F: "))
RH = float(input("Enter relative humidity, percent: "))

HI = (
    -42.379
    + 2.04901523 * T
    + 10.14333127 * RH
    - 0.22475541 * T * RH
    - 0.00683783 * T**2
    - 0.05481717 * RH**2
    + 0.00122874 * T**2 * RH
    + 0.00085282 * T * RH**2
    - 0.00000199 * T**2 * RH**2
)

TAVG = (T + HI) / 2
HI_final = HI

if TAVG < 80:
    HI_final = (0.5 * (T + 61.0 + ((T - 68.0) * 1.2) + (RH * 0.094)) + T) / 2

else:
    if (RH < 13) and (80 < T) and (T < 112):
        HI_final += ((13 - RH) / 4) * m.sqrt((17 - abs(T - 95.0)) / 17)
    elif (RH > 85) and (80 < T) and (T < 87):
        HI_final += ((RH - 85) / 10) * ((87 - T) / 5)
    else:
        HI_final = HI

print(f"The heat index is {round(HI_final)}.")
