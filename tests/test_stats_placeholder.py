import numpy as np
from scipy import stats

def test_ttest_small():
    a = np.random.normal(0,1,100)
    b = np.random.normal(0.5,1,100)
    t,p = stats.ttest_ind(a,b)
    assert p >= 0.0 and p <= 1.0