import matplotlib.pyplot as plt
import matplotlib.ticker as plticker
import pandas as pd
import glob

files = glob.glob('outputFiles/*.csv')

for file_name in files:
    df = pd.read_csv(file_name,names=['x_axis', 'y_axis'])
    plt.plot(df['x_axis'], df['y_axis'], label="mean")
    plt.title(file_name[12:-4])
    plt.grid(True)
    plt.xlabel('x')
    plt.legend()
    plt.savefig('plots/' + file_name.split('/')[1].split('.')[0] + '.png')
    plt.close()    

