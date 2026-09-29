import numpy as np

s = 10

# generate some off-axis diagonal ones
lower = np.zeros((s,s),dtype=np.float64)
upper = np.zeros((s,s),dtype=np.float64)
np.fill_diagonal(lower, -1, wrap=False)
np.fill_diagonal(upper, -1, wrap=False)
lower = np.roll(lower, -1, axis=1)
upper = np.roll(upper, 1, axis=1)

H = np.zeros((s,s), dtype=np.float64)
H = lower + upper

# on-axis ones
np.fill_diagonal(H, 2, wrap=False)

print(np.linalg.eigh(H).eigenvalues)
print()
print(np.linalg.eigh(H).eigenvectors)
