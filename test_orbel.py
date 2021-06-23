"""
Running orbital elements on python

Compilation:

```bash
f2py -c linalg.f90 orbitalelements.f90 -m orbel
python -m numpy.f2py -c linalg.f90 orbitalelements.f90 -m orbel
```
"""

import orbel

state = [1.0 ,0.0, 0.01, 0.0, 1.0, 0.0]
mu = 1.0

kepelts = orbel.orbitalelements.state2kepelts(state, mu)
print(kepelts)

