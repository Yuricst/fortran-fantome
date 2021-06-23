"""
Running kepler-der algorithm on python

Compilation:

```bash
f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m keplerder
python -m numpy.f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m keplerder
```
"""

import time
from keplerder import keplerder

mu = 1.0
state0 = [ 1.01, 0.0, 0.2, 0.0, 0.98, 0.067 ]
t0 = 0.0
t = 3.14

tol = 1.e-14
maxiter = 12

state1 = keplerder.propagate(mu, state0, t0, t, tol, maxiter)
print("state0: ")
print(state0)
print("state1: ")
print(state1)


# for comparison
import sys
sys.path.append(r"C:\Users\yurio\Documents\GitHub\galt")
import pygalt
import numpy as np

state2 = pygalt.keplerder_nostm(mu, np.array(state0), t0, t, tol=tol, maxiter=maxiter)
print("state2: ")
print(state2)


# measure time
n_test = 100
tstart = time.time()
for i in range(n_test):
	_ = keplerder.propagate(mu, state0, t0, t, tol, maxiter)
tend = time.time()