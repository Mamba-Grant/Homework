filename = "movies.txt"  # there can be no blank lines

f = open(filename, 'r')
df = [line.split() for line in f]  # parse the file

score_max = max(df, key=lambda x: x[1])  # this feels very janky but using a lambda to replicate broadcasted functions

#  count duplicate scores
i=0
for line in df:
    if line[1] == score_max[1]:
        i += 1

print(f"Movie {score_max[0]} has the highest rating ({score_max[1]}).\n{i} other movies have that same rating.")
