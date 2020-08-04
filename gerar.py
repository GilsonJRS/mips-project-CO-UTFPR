import csv
import random
from random import seed
from random import randint
import decimal
with open('inputFiles/aleatorio.csv', mode='w', newline='') as csv_file:
    writer = csv.DictWriter(csv_file, fieldnames=['x', 'y'])
    for i in range(0,100):
        seed(i)
        writer.writerow({"x":randint(0,100),"y":float(decimal.Decimal(random.randrange(155,389)/100))})
