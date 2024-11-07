ITERCOUNT = 6
i = 0
pi = 0
while abs(ITERCOUNT) != 0:
    pi += (-1) ** i / (2 * i + 1)
    ITERCOUNT -= 1
    i += 1
    print(f"Iteration {i}: {4 * pi}")
