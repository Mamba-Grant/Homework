import sys

CONDITIONVAR = False
ITERCOUNT = abs(int(sys.argv[1]) - 1)
i = 0
pi = 0

while CONDITIONVAR == False:
    pi += (-1) ** i / (2 * i + 1)
    i += 1

    str_pi_real = "3.1415926535"
    str_pi_calculated = str(4 * pi)
    str_slice_count = 0

    for j in range(len(str_pi_real)):
        if str_pi_real[j] == str_pi_calculated[j]:
            str_slice_count += 1
        else:
            break

    print(f"Iteration {i+1}: {4 * pi}")
    if ITERCOUNT == str_slice_count:
        CONDITIONVAR = True
