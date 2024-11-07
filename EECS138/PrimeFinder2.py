import math
# This file demonstrates writing data to a text file
# Michael S. Branicky, 2020-10-18, 2020-03-31

NUMPRIMES = 100000
PRINTEVERY = 10000

# an OK program that computes whether a number is prime or not
# returns True if n>=2 is prime; False, otherwise
def is_prime(n):
    if n < 2:
        return False # prime must be >=2
    i = 2
    # test factors up to, and including, the square root of n
    while i*i <= n:
        # if i evenly divides n, n isn't prime
        if n%i == 0:
            return False
        i += 1
    return True

primes = [ 0 for i in range(NUMPRIMES) ]

#### COMPUTE SOMETHING, E.G., Find the first NUMPRIMES primes
primes[0] = 2
numFound = 1

i = 3
while numFound < NUMPRIMES:
    if is_prime(i):
        primes[numFound] = i
        numFound += 1
        if numFound%PRINTEVERY == 0:
            print(f"Found {numFound}th prime ...")
    i += 2

print("Found all", NUMPRIMES)
print(primes[:5], "...", primes[-5:])
print()


#### WRITE OUTPUT
print("Writing file ...")

outfile = "roots.csv"
with open(outfile, 'w') as fout:
    for i in range(20):
        output_string = f"{i+1},{math.sqrt(primes[i])}\n"
        fout.write(output_string)

print(".. done writing file.")
