import pandas as pd
import sys
file_names = sys.argv[1:]
for f in file_names:
    df = pd.read_csv(("./inputFiles/"+f), names=['x', 'y'])
    df.sort_values(by=['x'], inplace=True)
    df.to_csv("./inputFiles/"+f, mode="w+",header=False, index=False)
