using CSV, DataFrames, Unitful, Plots, Measures

files = readdir("../data/voltage_sweep/", join=true, sort=true)
dfs = [(CSV.read(file, DataFrame), basename(file)) for file in files]
dfs = [(select(df, [4,5,10,11]), name) for (df, name) in dfs]
dfs = [(transform!(df,
    [1] => ByRow(x -> x*u"s") => :time_in,
    [3] => ByRow(x -> x*u"s") => :time_out,
    [2] => ByRow(x -> (x ± x*0.03)*u"V") => :v_in,
    [4] => ByRow(x -> (x ± x*0.03)*u"V") => :v_out
), name) for (df, name) in dfs]

p1 = plot(title="Voltage Sweep, Output", xlabel="time", ylabel="output", margin=0.5cm)
for (df, name) in dfs
    scatter!(p1, uconvert.(u"ms", df.time_out .- 1u"ms"), uconvert.(u"V", df.v_out), label=chop(name, tail=4), ms=1)
end

p2 = plot(title="Voltage Sweep, Input", xlabel="time", ylabel="output")
for (df, name) in dfs
    scatter!(p2, uconvert.(u"ms", df.time_in), uconvert.(u"V", df.v_in), label=chop(name, tail=4), ms=1)
end

p3 = plot(title="Input vs Gain", xlabel="V (in)", ylabel="Gain")
for (df, name) in dfs 
    x = uconvert.(u"V", df.v_in)
    y = df.v_in ./ df.v_out
    plot!(p3, ustrip.(x), ustrip.(y), label=chop(name, tail=4), ms=1)
end
