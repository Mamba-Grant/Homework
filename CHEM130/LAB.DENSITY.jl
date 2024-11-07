using DataFrames

# Data

d1 = DataFrame(x1=["H₂O", "D₂O"], x2=[20,19], x3=[32.6152,32.6152], x4=[40.4932,46.8561], x5=[7.878,14.2411], x6=[10,15])
rename!(d1,[:"Type of Water",:"Temperature (°C)",:"Mass of Cylinder (g)",:"Mass of Cylinder + Water (g)",:"Mass of Water (g)",:"Volume of Water (mL)"])

d2 = DataFrame(x1=["A", "B"], x2=["Metal A","Metal B"], x3=[28.9743,29.0234], x4=[0.5,0.5], x5=[0.25,0.25], x6=[1.2,0.9], x7=[5.0,5.0], x8=[8.8,7.9])
rename!(d2,[:"Metal",:"Description",:"Mass (g)",:"Diameter (in)",:"Radius (in)",:"Height (in)",:"V₀ (mL)",:"V₁ (mL)"])

# Calculations

Density(m, v₀, v₁) = (m)/(v₁-v₀)

d1."Volume of Water (mL)" = d1."Mass of Cylinder + Water (g)" .- d1."Mass of Cylinder (g)"

densityH₂O = Density.( d1."Mass of Water (g)"[1], 0, d1."Volume of Water (mL)"[1] )
densityD₂O = Density.( d1."Mass of Water (g)"[2], 0, d1."Volume of Water (mL)"[2] )

densityA = Density.(d2."Mass (g)"[1], d2."V₀ (mL)"[1], d2."V₁ (mL)"[1])
densityB = Density.(d2."Mass (g)"[2], d2."V₀ (mL)"[2], d2."V₁ (mL)"[2])

print("")

