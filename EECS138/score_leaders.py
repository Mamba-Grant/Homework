filename = 'ncaa_scoring_leaders.txt'

with open(filename, 'r') as f:
    df = [line.strip().split(',') for line in f]  # parse the file
    ku = [line for line in df if line[2].upper() == 'KU']  # match ku players
    jalens = [line for line in df if line[1].lower().split()[0] == 'jalen']  # match jalens (why are there so many)

    # open files to write
    with open('jayhawks.txt', 'w') as f_ku:
        for entry in ku:
            f_ku.write(','.join(map(str, entry)) + '\n')  # nifty setup to write in csv format

    with open('jalens.txt', 'w') as f_jalens:
        for entry in jalens:
            f_jalens.write(','.join(map(str, entry)) + '\n')

