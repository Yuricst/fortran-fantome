"""
Running kepler-der algorithm on python

Compilation:

```bash
f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m keplerder
python -m numpy.f2py -c linalg.f90 orbitalelements.f90 keplerder.f90 -m keplerder
```
"""

from keplerder import keplerder

mu = 1.0
state0 = [ 1.0, 0.0, 0.2, 0.0, 0.98, 0.067 ]
t0 = 0.0
t = 3.14

tol = 1.e-13
maxiter = 10

state1 = keplerder.propagate(mu, state0, t0, t, tol, maxiter)
print("state0: ")
print(state0)
print("state1: ")
print(state1)

