# Images likes to be run in distrobox if using on julia. 
using Images, FileIO, ImageInTerminal, Statistics, CSV, Statistics, DataFrames

function bitmap_to_trace(matrix)
    height, width = size(matrix)
    averages = Float64[]  # to store average y-values

    for (col_index, column) in enumerate(eachcol(matrix))
        y_indices = [row for row in 1:height if matrix[row, col_index] == 0]
        avg_y = isempty(y_indices) ? NaN : height-mean(y_indices)
        push!(averages, avg_y)
    end

    return averages
end

img_A_low = load("../data/Config A/Config A Low.png")
img_A_med = load("../data/Config A/Config A Med.png")
img_A_high = load("../data/Config A/Config A High.jpg")

function format_scope_trace(img)
    bitmap_mono = channelview(float.(img))[3,:,:]
    img_gray = Gray.(bitmap_mono)
    img_cropped = @view img_gray[22:245, 32:309] # isolate the trace
    img_rounded = round.(img_cropped)
    return channelview(float.(img_rounded))
end

bmp_A_low = format_scope_trace(img_A_low)
bmp_A_med = format_scope_trace(img_A_med)
bmp_A_high = format_scope_trace(img_A_high)

trace_A_low = bitmap_to_trace(bmp_A_low)
trace_A_med = bitmap_to_trace(bmp_A_med)
trace_A_high = bitmap_to_trace(bmp_A_high)

df_config_A_low = DataFrame(x_rel=1:size(bmp_A_low)[2], y_rel=trace_A_low)
df_config_A_med = DataFrame(x_rel=1:size(bmp_A_med)[2], y_rel=trace_A_med)
df_config_A_high = DataFrame(x_rel=1:size(bmp_A_high)[2], y_rel=trace_A_high)
CSV.write("../data/Config_A_Trace_low.csv", df_config_A_low)
CSV.write("../data/Config_A_Trace_med.csv", df_config_A_med)
CSV.write("../data/Config_A_Trace_high.csv", df_config_A_high)
