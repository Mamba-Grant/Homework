import numpy as np 

N = 10
k = np.arange(0, 10)
pk = (2 * np.pi * k) / N

a_res = np.sort(2 * (1 - np.cos(pk)))

print(a_res)
