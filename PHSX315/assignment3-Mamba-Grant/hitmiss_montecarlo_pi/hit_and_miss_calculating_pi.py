import seaborn as sb
import numpy as np
import mplcatppuccin
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import argparse
 
def plot():
    # sb.set(style='whitegrid', rc={"figure.figsize":(4, 4)})
    # sb.set_palette(['#62C370', '#EF476F'])
    mpl.style.use(["ggplot", "latte"])


    fig = plt.figure()
    x1 = fig.add_subplot(projection='3d')
    # x1.set_aspect("equal")

    # x1.view_init(45, 55)

    # Draw Scatter
    for s in df.in_bounds.unique():
        x1.scatter(df.x[df.in_bounds==s],df.y[df.in_bounds==s],df.z[df.in_bounds==s],label=s)

    u, v = np.mgrid[0:2*np.pi:20j, 0:np.pi:10j]
    x = np.cos(u)*np.sin(v)
    y = np.sin(u)*np.sin(v)
    z = np.cos(v)
    x1.plot_wireframe(x, y, z)

    plt.show()
    

parser = argparse.ArgumentParser()

parser.add_argument("-i", "--iterations", help="Iteration Count.", type=int, default=1000)
parser.add_argument("-s", "--seed", help="Random Seed.", type=int, default=2)
parser.add_argument("-p", "--plot", help="Plot Results.", action="store_true")
parser.add_argument("-df", "--dataframe", help="Display Dataframe.", action="store_true")
args = parser.parse_args()

np.random.seed(args.seed)

df = pd.DataFrame(columns =["x","y","in_bounds","radius","one_minus_radius"])
# Pandas screams at us for not casting the column to a bool type for some reason? This fixes that even though it causes no issues... I miss type safety in rust :(
df["in_bounds"]=df["in_bounds"].astype(bool)

index=0
for e in range(0,  args.iterations):
    x=np.random.uniform(-1,1)
    y=np.random.uniform(-1,1)
    z=np.random.uniform(-1,1)
    
    dist = np.sqrt(x**2 + y**2 + z**2)
    
    row_to_append = pd.DataFrame([{"x":x, "y":y, "z":z, "in_bounds": False if dist > 1 else True, "one_minus_radius": 1-dist, "radius": dist}])
    df = pd.concat([df,row_to_append])
    
    index+=1

percent = df["in_bounds"].value_counts()[True]/args.iterations
calculated_pi = percent*6

err = 6 * np.sqrt( (calculated_pi/6) * (1.0 - (calculated_pi/6) )) / np.sqrt(args.iterations)
print("% in Sphere:", percent, "\nCalculated pi:", calculated_pi, "\nStandard Deviation:", err)

if args.dataframe:
    print("\n", df)

if args.plot:
    plot()
