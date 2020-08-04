import matplotlib.pyplot as plt
import pandas as pd
import glob

files = glob.glob('outputFiles/*.csv')

for file_name in files:
    print(file_name.split('/')[1].split('.')[0])
    df = pd.read_csv(file_name, names=['x', 'y'])
    df = df.sort_values(['x', 'y'])
    print(df)
    df.plot(kind='line', x='x', y='y')
    plt.savefig('plots/' + file_name.split('/')[1].split('.')[0] + '.png')    


