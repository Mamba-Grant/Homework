# initialize ecoli with some number of doubling cycles
# do math
# print bool mass > earthmass
# print bool volume > earthvolume

DOUBLES = 48  # Doubling periods
ECOLI = 1
ECOLI = [ECOLI := ECOLI * 2 for i in range(DOUBLES)][-1]
# I finally used the walrus operator :D

dt = DOUBLES * 30
weight_ecoli = 1e-15 * ECOLI
volume_ecoli = 1e-18 * ECOLI
weight_earth = 5.97e24
volume_earth = 1.08e15

print(
    f"1. Count: {ECOLI}\n2. {weight_ecoli} is {'' if (weight_ecoli>weight_earth) else 'NOT'} greater than the weight of the Earth\n3. {volume_ecoli} is {'' if (volume_ecoli>volume_earth) else 'NOT'} greater than the volume of the earth"
)
