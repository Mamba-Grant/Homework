import numpy as np

N = 200
def hamiltonian(lam):
    eps = N**2 / (8 * np.pi**2 * lam)

    lower = np.zeros((N, N), dtype=np.float64)
    upper = np.zeros((N, N), dtype=np.float64)
    np.fill_diagonal(lower, -1)
    np.fill_diagonal(upper, -1)
    lower = np.roll(lower, -1, axis=1)
    upper = np.roll(upper, 1, axis=1)
    U = lower + upper
    np.fill_diagonal(U, 2)
    U *= eps

    n = np.arange(N)
    phi_n = 2 * np.pi * n / N
    V = lam * np.diag(1 - np.cos(phi_n))

    return U + V

for lam in [1, 10, 50]:
    H = hamiltonian(lam)
    eigvals = np.linalg.eigvalsh(H)
    print(f"eigvals = {np.round(eigvals[:3], 4)}")
