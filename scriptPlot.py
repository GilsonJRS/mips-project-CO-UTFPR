import matplotlib.pyplot as plt
import pandas as pd
import glob

files = glob.glob('outputFiles/*.csv')

for file_name in files:
    df = pd.read_csv(file_name, names=['x', 'y'])
    df = df.sort_values(['x', 'y'])
    df.plot(kind='line', x='x', y='y', title=file_name[12:-4])
    plt.savefig('plots/' + file_name.split('/')[1].split('.')[0] + '.png')    


