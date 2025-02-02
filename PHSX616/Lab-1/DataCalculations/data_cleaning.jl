using CSV
using DataFrames

common_values = (0.0076, 886, 9.8, 1.83E-05, 8.2e-3, 1.01520E5, 21)

trial1_data = DataFrame(
    voltage_V = fill(200.8, 14),
    neutral_fall_seconds = [38.03, 17.85, 17.73, 16.05, 16.26, 19.23, 21.05, 20.08, 21.93, 21.24, 17.82, 18.33, 21.33, 23.36],
    charged_rise_seconds = [4.79, 3.72, 3.29, 3.48, 3.34, 3.54, 2.42, 3.51, 3.84, 4.44, 4.97, 3.36, 4.11, 4.55],
    ionization_seconds = fill(0.0, 14),
    d = fill(common_values[1], 14),
    rho = fill(common_values[2], 14),
    g = fill(common_values[3], 14),
    eta = fill(common_values[4], 14),
    b = fill(common_values[5], 14),
    p = fill(common_values[6], 14),
    room_temp = fill(common_values[7], 14),
)

trial2_data = DataFrame(
    voltage_V = fill(510.7, 11),
    neutral_fall_seconds = [24.26, 34.59, 24.84, 34.49, 28.85, 34.57, 28.35, 27.15, 29.12, 35.99, 37.05],
    charged_rise_seconds = [2.67, 5.14, 5.2, 5.44, 5.07, 4.49, 4.97, 4.59, 4.62, 5.29, 5.02],
    ionization_seconds = fill(0.0, 11),
    d = fill(common_values[1], 11),
    rho = fill(common_values[2], 11),
    g = fill(common_values[3], 11),
    eta = fill(common_values[4], 11),
    b = fill(common_values[5], 11),
    p = fill(common_values[6], 11),
    room_temp = fill(common_values[7], 11),
)

trial3_data = DataFrame(
    voltage_V = fill(510.1, 9),
    neutral_fall_seconds = [15.39, 13.87, 17.78, 13.56, 18.00, 13.77, 14.65, 15.00, 14.16],
    charged_rise_seconds = [0.73, 0.79, 1.21, 1.06, 1.25, 1.03, 1.29, 1.09, 2.76],
    ionization_seconds = fill(15.0, 9),
    d = fill(common_values[1], 9),
    rho = fill(common_values[2], 9),
    g = fill(common_values[3], 9),
    eta = fill(common_values[4], 9),
    b = fill(common_values[5], 9),
    p = fill(common_values[6], 9),
    room_temp = fill(common_values[7], 9),
)

trial4_data = DataFrame(
    voltage_V = fill(511.1, 9),
    neutral_fall_seconds = [5.69, 7.62, 8.43, 8.91, 8.30, 8.21, 7.57, 8.05, 7.52],
    charged_rise_seconds = [1.46, 1.23, 1.83, 1.44, 1.71, 1.86, 1.89, 2.08, 2.26],
    ionization_seconds = fill(4.99, 9),
    d = fill(common_values[1], 9),
    rho = fill(common_values[2], 9),
    g = fill(common_values[3], 9),
    eta = fill(common_values[4], 9),
    b = fill(common_values[5], 9),
    p = fill(common_values[6], 9),
    room_temp = fill(common_values[7], 9),
)

trial5_data = DataFrame(
    voltage_V = fill(510.3, 6),
    neutral_fall_seconds = [12.89, 13.96, 14.57, 12.51, 14.46, 14.91],
    charged_rise_seconds = [2.97, 3.12, 3.11, 2.99, 3.19, 5.05],
    ionization_seconds = fill(0.0, 6),
    d = fill(common_values[1], 6),
    rho = fill(common_values[2], 6),
    g = fill(common_values[3], 6),
    eta = fill(common_values[4], 6),
    b = fill(common_values[5], 6),
    p = fill(common_values[6], 6),
    room_temp = fill(common_values[7], 6),
)

CSV.write("raw_data/Trial 1.csv", trial1_data)
CSV.write("raw_data/Trial 2.csv", trial2_data)
CSV.write("raw_data/Trial 3.csv", trial3_data)
CSV.write("raw_data/Trial 4.csv", trial4_data)
CSV.write("raw_data/Trial 5.csv", trial5_data)
