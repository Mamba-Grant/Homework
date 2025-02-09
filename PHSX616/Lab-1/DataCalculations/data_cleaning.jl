using CSV, DataFrames

# Common experimental parameters
const PARAMS = (
    d = 0.0076,
    ρ = 886,       
    g = 9.8,       
    η = 1.83e-5,   
    b = 8.2e-3,    
    p = 1.01520e5, 
    room_temp = 21 
)

# Function to create a standard trial DataFrame
function create_trial_df(trial_num, voltage, falls, rises, ion)
    n = length(falls)
    DataFrame(
        trial = fill(trial_num, n),
        voltage_V = fill(voltage, n),
        neutral_fall_seconds = falls,
        charged_rise_seconds = rises,
        ionization_seconds = fill(ion, n),
        d = fill(PARAMS.d, n),
        rho = fill(PARAMS.ρ, n),
        g = fill(PARAMS.g, n),
        eta = fill(PARAMS.η, n),
        b = fill(PARAMS.b, n),
        p = fill(PARAMS.p, n),
        room_temp = fill(PARAMS.room_temp, n)
    )
end

# Dictionary to store trials
trials = Dict(
    # 1 => create_trial_df(1, 200.8, 
    #     [38.03, 17.85, 17.73, 16.05, 16.26, 19.23, 21.05, 20.08, 21.93, 21.24, 17.82, 18.33, 21.33, 23.36],
    #     [4.79, 3.72, 3.29, 3.48, 3.34, 3.54, 2.42, 3.51, 3.84, 4.44, 4.97, 3.36, 4.11, 4.55],
    #     0.0),
    2 => create_trial_df(2, 510.7, 
        [24.26, 34.59, 24.84, 34.49, 28.85, 34.57, 28.35, 27.15, 29.12, 35.99, 37.05],
        [2.67, 5.14, 5.2, 5.44, 5.07, 4.49, 4.97, 4.59, 4.62, 5.29, 5.02],
        0.0),
    4 => create_trial_df(3, 510.1, 
        [15.39, 13.87, 17.78, 13.56, 18.00, 13.77, 14.65, 15.00, 14.16],
        [0.73, 0.79, 1.21, 1.06, 1.25, 1.03, 1.29, 1.09, 2.76],
        15.0),
    3 => create_trial_df(4, 511.1, 
        [5.69, 7.62, 8.43, 8.91, 8.30, 8.21, 7.57, 8.05, 7.52],
        [1.46, 1.23, 1.83, 1.44, 1.71, 1.86, 1.89, 2.08, 2.26],
        4.99),
    5 => create_trial_df(5, 510.3, 
        [12.89, 13.96, 14.57, 12.51, 14.46, 14.91],
        [2.97, 3.12, 3.11, 2.99, 3.19, 5.05],
        0.0),
    6 => create_trial_df(6, 511.3, 
        [16.98, 14.81, 14.81, 15.25, 15.52, 13.03, 15.51, 18.86, 15.02, 13.74],
        [1.31, 1.21, 2.17, 1.54, 1.71, 1.15, 1.28, 1.53, 2.09, 1.98],
        0.0),
    7 => create_trial_df(7, 511.3, 
        [10.59, 10.66, 10.11, 8.3, 13.67, 9.98, 10.3, 10.64, 9.91, 9.15],
        [3.22, 4.77, 4.14, 3.36, 3.69, 3.16, 3.41, 3.17, 3.01, 3.39],
        0.0)
)

# Additional trials from individual measurements
measurements = [
    (511.2, 21.26, 3.94),
    (511.2, 22.91, 4.4),
    (511.2, 6.58, 1.98),
    (511.2, 21.33, 3.17),
    (511.2, 12.04, 2.54),
    (512.3, 5.65, 4.39),
    (512.3, 5.85, 4.72),
    (512.3, 11.29, 3.07),
    (512.3, 9.53, 1.36),
    (512.3, 8.02, 0.71),
    (512.3, 12.81, 5.92),
    (512.3, 19.48, 1.31),
    # (512.3, 41.36, 6.7),
    (512.3, 12.76, 1.18)
]

# Add each measurement as a separate trial
for (i, (voltage, fall, rise)) in enumerate(measurements)
    trials[7+ i] = create_trial_df(7 + i, voltage, [fall], [rise], 0.0)
end

# Create directory for exports
mkpath("raw_data")

# Export all trials
for (trial_num, df) in trials
    filename = "raw_data/Trial_$(lpad(trial_num, 2, '0')).csv"
    CSV.write(filename, df)
end

println("Export completed successfully.")
