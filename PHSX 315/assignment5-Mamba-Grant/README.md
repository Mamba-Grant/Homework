## Problem 1 - Results (seed=102 in Figure)
<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/p1.png" width="1200">

batchrun.sh is a helper script which can run n parallel instances of our Chisqfit.py script. It returns the number of times a p-value was under 5%, and the respective p-values which were under this threshold. Unfortunately, I am not skilled enough to filter out the corresponding seed in bash, however it is easy enough to cross-reference the p-values with the respective seed in nohup.out.

Output from "./batchrun.sh 100"
```bash
Running Chisqfit.py 100 Times...
nohup: ignoring input and appending output to 'nohup.out'
Number of occurrances: 4
0.032626556547229235 0.021345150351458786 0.007885013130158436 0.009806391439382556
```

## Problem 2 - Results
<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/p2.png" width="700">

## Problem 3 - Results ✓
<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/p3.png" width="700">

## Problem 4 - Results ✓
<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/p4.png" width="700">

The Legendre model appears to give results with lower errors than the fit produced by a standard quadratic model. Additionally, these models are not closely correlated, which is evidenced by the correlations below:

```bash
Value Correlation: -0.9998358524014973
Error Correlation: -0.9798376512173532
```

## TODO
```bash
.
├── Problem 1
│   ├── batchrun.sh
│   ├── Chisqfit.py
│   └── nohup.out
├── Problem 2
│   ├── Physical Model Fitting.jl (most up-to-date)
│   └── fit.py
├── Problem 3
│   └── Likelihood Estimation.jl
├── Problem 4
│   ├── p4.py (deprecated)
│   └── Quadradic-Legenre Fit.jl
├── README.md
└── rsc
    ├── Assignment Details
    │   ├── Assignment5-315-1.png
    │   ├── Assignment5-315-2.png
    │   ├── Assignment5-315-3.png
    │   └── Assignment5-315.pdf
    ├── HighPrecisionPeriodData.csv
    ├── HighPrecisionPeriodData.ods
    ├── LowPrecisionPeriodData.csv
    ├── LowPrecisionPeriodData.ods
    ├── p1.png
    ├── p2.png
    ├── p3.png
    ├── p4.png
    └── Table1.ods

7 directories, 22 files
```

- [ ] **PROBLEM 1** - Implement output formatting (grep) for batchrun.sh.
- [x] **PROBLEM 1** - Fix plotting errors which mysteriously appeared (Previously Working)?
- [x] **PROBLEM 1** - Include plots/results.
- [x] ~~**PROBLEM 2** - Verify that quadradic fitting is what we are supposed to do.~~
- [x] **PROBLEM 2** - Implement correct model (currently using quadradic).
- [ ] **PROBLEM 2** - Return CHISQ values, include all data in results.
- [ ] **PROBLEM 2** - Fix mysterious disappearance of error values.
- [x] **PROBLEM 3** - Handle type size issues with last data point, current dataset excludes the last data point due to float size issues.
- [x] **PROBLEM 3** - Include errors in results.
- [x] **PROBLEM 3** - Legend, axis titles must be included in plot.
- [x] **PROBLEM 3** - Fix plot scale.
- [x] **PROBLEM 4** - Plot data.
- [x] **PROBLEM 4** - Implement Legendre polynomials.
- [x] **PROBLEM 4** - Verify correctness of Legendre polynomials.
- [ ] **PROBLEM 4** - Output CHISQ values.
- [ ] **PROBLEM 4** - Try cleaning up plot code.
- [x] **GENERAL** - Error bars.
- [ ] **GENERAL** - Consistent palette.

---

## Assignment Details

<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/Assignment Details/Assignment5-315-1.png" width="700">
<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/Assignment Details/Assignment5-315-2.png" width="700">
<img src="https://github.com/phsx315-sp23/assignment5-Mamba-Grant/blob/main/rsc/Assignment Details/Assignment5-315-3.png" width="700">
