import matplotlib as mpl
from matplotlib import pyplot as plt
import numpy as np
from iminuit import Minuit
from scipy.stats import chi2
import argparse
import seaborn as sb
import pandas as pd

def line_model(x, c, m):
    return m*x + c
    
def custom_chisq_model(c, m):
    """ Chi-squared function to be minimized """
    ym = line_model(x_data, c, m)
    z = (y_data - ym)/yerr_data
    chisq = np.sum(z**2)
    if args.verbose:
        print('ym = ',ym)
        print('z  = ',z)
        print('Chisq = ',chisq,'for c,m = ',c,m) 
    return chisq


parser = argparse.ArgumentParser()
parser.add_argument('-s', '--seed', type=int, default=2)
parser.add_argument('-n', '--numpoints', type=int, default=20)
parser.add_argument('-c', '--true_intercept', type=float, default=1.0)
parser.add_argument('-sl', '--true_slope', type=float, default=2.0)
parser.add_argument('-p', '--plot', default=False, action="store_true")
parser.add_argument('-v', '--verbose', default=True, action="store_true")
args = parser.parse_args()


# generate random toy data with random offsets in y 
np.random.seed(args.seed)
x_data = np.linspace(-1.0, 1.0, args.numpoints)
ran = np.random.randn(len(x_data)) 
y_true = line_model(x_data, args.true_intercept, args.true_slope)
yerr_data = 0.1 + 0.05*x_data    # Make assumed Gaussian uncertainties increase with increasing x.
y_data = y_true + yerr_data * ran  # Use standard normal random numbers

# This probably slows the script some but it puts everything in a nice table
df_data = [x_data, y_data, y_true, yerr_data, ran]
df = pd.DataFrame(dict(zip(range(len(df_data)), df_data)))
df.columns = ["x", "y", "y-True", "y-Error", "Ran"] 

m = Minuit(custom_chisq_model, c = 0.0, m = 0.0)  # starting values for intercept (c) and slope (m) parameters
m.errordef = 1.0 # Corresponds to change in function value associated with +- 1 standard error 
m.migrad()  # finds minimum of least_squares function
m.hesse()   # accurately computes uncertainties


# plot toy data
sb.set_theme(style="darkgrid")
fig = sb.FacetGrid(df).set(title="Chisqfit.py")
sb.lineplot(x=x_data, y=line_model(x_data, m.values[0], m.values[1]), label="Line fit", color="m")
fig.map(plt.errorbar, "x", "y", yerr=df["y-Error"], fmt="o", label="Data", color="m")

fit_info = [
    f"$\\chi^2$ / $n_\\mathrm{{dof}}$ = {m.fval:.2f} / {len(x_data) - m.nfit}",
]
fit_info.append(f"c = ${m.values[0]:.3f} \\pm {m.errors[0]:.3f}$")
fit_info.append(f"m = ${m.values[1]:.3f} \\pm {m.errors[1]:.3f}$")
plt.legend(title="\n".join(fit_info))


# Logging
ndof = len(x_data)-m.nfit

if args.verbose:
    print(df)
    print("Run Arguments:", args)

    print('\nBest fit function value (Chi-squared):',m.fval,' for ndof = ',len(x_data)-m.nfit)
    print('Fitted parameter values ',m.values)
    print('Fitted parameter errors ',m.errors)
    print('Fitted parameter correlation coefficient matrix:')
# print(m.covariance.correlation())

print('p-value =',1.0-chi2.cdf(m.fval, ndof))


if args.plot:
    plt.show(block=False)
    plt.pause(10)   # Keep on-screen for 10s