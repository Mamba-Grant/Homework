import matplotlib.pyplot as plt
import matplotlib
matplotlib.use("WebAgg")

index = [0, 200, 260, 310, 360, 370, 390, 400, 410, 430, 500, 600, 700, 800, 999]
current = [-1600, -380, -220, -140, -37, -18, -10, 0, 10, 28, 100, 180, 220, 280, 360]
error = [100, 10, 10, 10, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 10]

def galvanometer_fit(index) -> float: 
    return 5e-3 * index + 17e-3

resistance = [galvanometer_fit(x) for x in index]

print(resistance)

plt.figure(figsize=(10, 6))
plt.errorbar(resistance, current, yerr=error, fmt='o', capsize=5, label='Current with Error', color='b')
plt.title("Current vs. Resistance", fontsize=14)
plt.xlabel("Resistance ($k\\Omega$)", fontsize=12)
plt.ylabel("Current ($\\mu$A)", fontsize=12)  # Corrected LaTeX formatting
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()
plt.show()
