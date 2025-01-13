[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/O-RUJ5Ek)

# Assignment-6

Assignment 6 (MC integration, numerical integration, numerical ODEs)

## TODO:

- [x] Go back over problems 1-3
- [x] Problem 4
- [x] Uncertainties in Problem 5
- [x] Estimate values at 0 in Problem 6
- [x] Include initial state vectors for Problem 6
- [x] Fix up theta in Problem 6 - treat it the same as the other functions
- [x] Problem 1 is just wrong - implement distribution correctly.
- [x] Problem 2 is also wrong - implement distribution correctly.
- [x] Profile my implementation of the custom distribution. 
- [x] Documentation for problem 1 & 2.
- [x] Uncertainty on problem 3
- [x] Uncertainty on problem 4
- [ ] Uncertainty on problem 6
- [ ] Problem 6 optimization

## Problem 1

- This is an custom implementation of a distribution for the standard Distributions.jl library.

To use this implementation, add `Distributions` and `Random` to your julia packages with `]add Distributions Random` and add them to your project.

```julia
# usage example
sampler = CustomSampler()
rand(sampler, 10)
```

**Histogram of Distribution With 100000 Samples**
<p align="center">
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/CustomDistribution.png" />
</p>

### Profiling Statistics

I am not adept at writing tests for code, however I have included a separate script which:
1. Collects $n$ samples of my random distribution, repeating this collection process $n$ times.
2. Records the number of samples required to sample $n$ random numbers.
3. Records the time taken to calculate $n$ samples.
    - Also calculates the mean, rms, max, and min values for this data.
4. Produces a histogram visualizing the data.
5. Accounts for the inital compilation time (as Julia is a JIT language).


```julia
julia> include("p1_profiling.jl")
--- SAMPLE COUNTS ---

    mean: 7032.012
    rms:  7034.522030671309
    max:  7702
    min:  6512

--- SAMPLE TIMES ---

    mean: 0.00031706192799999997
    rms:  1.0000002258840557
    max:  0.019043066
    min:  0.00025603

--- END ---
```

**Profiling Statistics Chart** $\mathbf{(n=1000)}$

<p align="center">
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/p1_profile.png" />
</p>

## Problem 2

- As more samples are taken, the resulting distribution will begin to look more and more like a normal distribution according to the law of large numbers (see histogram).

```julia
julia> include("p2.jl")
first: 4701.402251684796
mean:  4581.93687870481
rms:   4582.126128051981
max:   4716.011533064496
min:   4459.934877375053
```

**Distribution**
<p align="center">
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/FortuneDist.png" />
</p>

## Problem 3 (1000000 Samples)

- Requires high samples to get a result with any sort of reasonable uncertainty.

```julia
julia> include("p3.jl")
 36.895349 seconds (500.17 M allocations: 15.688 GiB, 2.72% gc time, 0.35% compilatio
n time)
mean estimate: 736.1698650126942
Uncertainty: 24.054696385603236
```

<p align="center">
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/MCHitMiss.png" />
</p>

## Problem 4 (1000 Samples)

$$\frac{1}{b-a}\int_a^b f(x)\, dx \approx \frac{1}{n} \sum_{i=1}^n f(x_i)$$

```julia
julia> include("p4.jl")
  0.213850 seconds (2.16 M allocations: 87.170 MiB, 3.81% gc time, 24.20% compilation
 time: 32% of which was recompilation)
Estimate: 736.754170605653
STDEV: 60.49794854835743

```


## Problem 5 (1000 Steps)
### Simpson's Rule

- Evaluation time of Simpson's rule was 77 microseconds
- Calculation time of the integral was 74 microseconds

```julia
julia> include("Simpson.jl")
  0.000077 seconds (21 allocations: 1.439 KiB)
  0.000074 seconds (2 allocations: 8.125 KiB)
742.7980187404278
```

#### Errors

Here, we approximate the error with Richardson extrapolation. The basic premise of this is to apply Simpson's rule with with the step size $h$ and $\frac{h}{2}$. Then, using the order of the error term, an estimate can be made:
$$\frac{I\left(\frac{h}{2}\right)-I(h)}{2^{p-1}}$$

```julia
julia> Error(0, 2*pi, 1000)
0.43522784272583975
```

### Boole's Rule

- Evaluation time of Boole's rule was 87 microseconds
- Calculation time of the integral was 74 microseconds

```julia
julia> include("Boole.jl")
  0.000087 seconds (21 allocations: 1.572 KiB)
  0.000073 seconds (3 allocations: 8.188 KiB)
742.3627908977022
```

#### Errors

Again, we approximate the error with Richardson extrapolation.

```julia
julia> Error(0, 2*pi, 1000)
0.0967173325363496
```

## Problem 6
### Related Math

1. Euler's method (Effectively RK1): $f_1 = f_0 + \Delta t \times f(t_0)$
2. RK2 method: $f_1 = f_0 + \Delta t \times f( t_0 + \frac{\Delta t}{2})$

### Differential Equations:
$x: \quad m\frac{d^{2}x}{dt^{2}} = -\frac{1}{2}\rho \left( \frac{dx}{dt} \right)^{2}AC_{D}\cos \theta$

$y: \quad m\frac{d^{2}x}{dt^{2}} = -mg - \frac{1}{2}\rho \left( \frac{dx}{dt} \right)^{2}AC_{D}\sin \theta$


### Results, 0.1 Step Size (Using Secant Approximations Between Samples)

| Method                 | Hang-time ($s$)   | Range ($m$) (at $y=0$) |
|:----------------------:|:-----------------:|:----------------------:|
| Euler (No Drag Forces) | $\approx 21.5460$ |   $\approx 2285.298$   |
| Euler (Drag Forces) | $\approx 19.9344$ |   $\approx 1451.182$   |
| RK2 (No Drag Forces)   | $\approx 21.5460$ |   $\approx 1256.914$   |
| RK2 (Drag Forces)      | $\approx 19.9612$ |   $\approx 834.878$    |


### Optimization (0.0005 Step Wize, Using Quadradic Interpolation and Bisections to Approximate Zeroes)
```julia
julia> include("RK2_Optimization.jl")
([44.11872632356557], [0.011064427460937805])

julia> approximate_range(44.118)
758.4025033449454
```

### Plots (0.5 Step Size & 0.0005 Step Size)

<p align="center">
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/Euler.png" />
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/RK2.png" />
<img src="https://github.com/phsx315-sp23/assignment-6-Mamba-Grant/blob/main/assets/RK2_Multiplot.png" />
</p>
