import sys
import pandas as pd
import numpy as np

def calculate_ess_refined(x):
    n = len(x)
    x = x - np.mean(x)
    # Compute autocorrelation using numpy
    acorr = np.correlate(x, x, mode='full')[n-1:]
    acorr = acorr / (np.var(x) * np.arange(n, 0, -1))
    
    # Tracer-like stopping rule: sum until the sum of 
    # consecutive pairs becomes negative
    ess_sum = 0
    for i in range(1, len(acorr) - 1, 2):
        pair_sum = acorr[i] + acorr[i+1]
        if pair_sum < 0:
            break
        ess_sum += pair_sum
        
    return n / (1 + 2 * ess_sum)

df = pd.read_csv(sys.argv[1], sep='\t', comment='#')
data = df['posterior'].iloc[int(len(df)*0.1):].values
print(calculate_ess_refined(data))
