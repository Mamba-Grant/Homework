# Assignment 4 : Testing Simple Hypotheses

# Problem 1:
Use the PValues calculator in ClassExamples to calculate (and report) the two-tailed probability for a normally distributed random number to be more than 1.0 σ, 2.0 σ, 3.0 σ, 4.0 σ, 5.0 σ, and 6.0 σ from the mean. 

| σ   | p         | 1-p   |
| --- | --------- | ----- |
| 1.0 | 31.73     | 68.27 |
| 2.0 | 4.550     | 95.45 |
| 3.0 | 0.2700    | 99.73 |
| 4.0 | 0.006334  | 99.99 |
| 5.0 | 5.733e-05 | 99.99 |
| 6.0 | 1.973e-07 | 99.99 |

# Problems 2, 3, 4:

$$\begin{align*}
\chi^{2}=\sum\limits_{i=1}^{n}\left(\frac{g_{i}-E(g)}{\sigma_{i}}\right)^{2} &&\text{(definition of chi-squared distribution)}
\end{align*}$$

1. $H_0$: Acelleration due to gravity is constant at all heights.
2. $H_1$: Acelleration due to gravity is not constant at all heights.

**Calculating Chi-Square Values for our Datasets:**

$$\begin{align*}
\chi^{2}=\sum\limits_{i=1}^{n}\left(\frac{g_{i}-9.8}{\sigma_{i}}\right)^{2} &&\text{(chi-squared value as predicted by $H_0$)}
\end{align*}$$

$$\begin{align*}
\chi^{2}&=\sum\limits_{i=1}^{n}\left(\frac{g_{i}-G_{earth}( \frac{M_{earth}}{R_{earth}+h_i} )}{\sigma_{i}}\right)^{2} &&\text{(chi-squared value as predicted by $H_1$)}\\
& &&G_{earth}=6.67430\times10^{-11}\\
& &&M_{earth}=5.97219\times10^{24}\\
& &&R_{earth}=6.378\times10^6
\end{align*}$$


**Calculating the Chi-Square Distribution and p-values:**

$$\begin{align*}
c(x)&=\frac{x^{\frac{D_{freedom}}{2}-1}e^{-\frac{x}{2}}}{2^{\frac{D_{freedom}}{2}}\cdot\Gamma\left(\frac{D_{freedom}}{2}\right)}\ &&\{x\ge0\} &&&\text{(Chi-Square Distribution)}
\end{align*}$$

$$\begin{align*}
p&=1-\int_{0}^{\chi^2}c(x)\ dx &&&\text{(p-value from Chi-Square Distribution)}
\end{align*}$$

## Results:

**Program Output:**
```
   RESULTS           (Chi-Square, p-value)
χ² Constant (Set 1): (15.153200000000115, 71.28246508819987%)
χ² Constant (Set 2): (2.7811730000000883, 99.99999999027636%)
χ² Newton's (Set 2): (0.2842575504814163, 100.0%)
Done!  saved file to:
"Plots.png"
```

---

![](https://github.com/phsx315-sp23/assignment4-Mamba-Grant/blob/main/Plots.png)

---