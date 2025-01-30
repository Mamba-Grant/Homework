\# Assignment3
## Assignment Details:
PHSX 315 Assignment 3\
Problem 1

Goal: Measure π using one million random points in 3-d space by measuring the fraction of
the volume of a cube with side-length of 2 that is occupied by the unit sphere (the sphere
with radius of 1).

Report the absolute and relative deviation of the measured value of π from the true
value for two different choices of random number seed. You should be able to estimate
the uncertainty on your values of π. This can be done either empirically by measuring the
standard deviation of smaller subsets of the data (for example 100 sub-sets of 10,000 points
each), or from first principles related to the expected variance of the binomial probability
distribution for N=1,000,000.

Does this 3-d method have the same precision, more precision, or less precision compared
with the 2-d method for the same number of points? Do you understand why?
Deliverables. You should upload to your repository a summary of your findings, a copy
of your code, example results from running the code, and appropriate figures.

---

## Results:

#### Rust Script (this should run without having rust installed, but I have not tested it):

`./rust_hitmiss_montecarlo_pi/target/release/rust_hitmiss_montecarlo_pi -i 100000000`

produces the output:


```
Running with 100000000 Samples:
Elapsed time (calculation): 1.55s
 Pi is approximately equal to: 3.14155782
 There were [52359297] points inside the sphere [0.52359297%].
 Standard Deviation: 0.0002996658369517094
 Diff %: 0.000011087937473239571
Done!
Elapsed time (total): 1.55s
```
*note: the program runs into memory allocation issues with sample sizes greater than 100,000,000* 

#### Python Script:
`python3 /hitmiss_montecarlo_pi/hit_and_miss_calculating_pi.py -i 1000000`

produces the output:


```
% in Sphere: 0.522125 
Calculated pi: 3.1327499999999997 
Standard Deviation: 0.002997061467087387
```
*note: script took 1 hour and 15 minutes to complete due to the poor choice in data structure, it is recommended to run it at a low sample count (<10,000) for testing, since large numbers of concationations of pandas dataframes result in very bad performance.*

## Visualization of Results (Rust Script - 10,000 Samples - Seed 42)
![](https://github.com/phsx315-sp23/assignment3-Mamba-Grant/blob/main/resources/3d-plot2.gif)

## Discussion:
In both 2D and 3D systems, we can analyze this problem using the Central Limit Theorem, where our sampled points are vectors describing the position of the sampled point. 

The average is given by:
$\frac1n \left[\begin{array}{c} \sum_{i=1}^n \overline{X}_{i(1)}\\ \vdots\\ \sum_{i=1}^n \overline{X}_{i(k)} \end{array} \right] = \overline{X}_n$
 