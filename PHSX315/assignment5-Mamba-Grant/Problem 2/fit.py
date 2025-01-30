import numpy as np
import pandas as pd
from iminuit import Minuit
from matplotlib import pyplot as plt
import seaborn as sb

PI = 3.1415
G = 9.8
L = 1


def quadradic_model(x, a, b, c):
    return a*x**2 + b*x + c

# An approximation must be derived with the spring equations as a basis
def period(x, t):
        return 2*PI*np.sqrt(L/G)*t

def quadratic_chisq_model(a, b, c):
    ym = quadradic_model(x_data, a, b, c)
    z = (y_data - ym)/yerr_data
    chisq = np.sum(z**2)
    print("chisq: ", chisq)
    return chisq


df = pd.read_csv("rsc/HighPrecisionPeriodData.csv")

x_data = df[['theta']].to_numpy().T[0]
y_data = df[['T']].to_numpy().T[0]
yerr_data = df[['dT']].to_numpy().T[0]

m = Minuit(quadratic_chisq_model, a=0.0, b=0.0, c=0.0)  # starting values for intercept (c) and slope (m) parameters
m.errordef = 1.0 # Corresponds to change in function value associated with +- 1 standard error 
m.migrad()  # finds minimum of least_squares function
m.hesse()   # accurately computes uncertainties

print(m.values)


sb.set_theme(style="darkgrid")
fig = sb.FacetGrid(df).set(title="Chisqfit.py")
sb.lineplot(x=x_data, y=quadradic_model(x_data, m.values[0], m.values[1], m.values[2]), label="Line fit", color="m")
fig.map(plt.errorbar, "theta", "T", yerr=yerr_data, fmt="o", label="Data", color="m")
plt.show()