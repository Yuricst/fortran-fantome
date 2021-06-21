"""
Running on python

Compilation:

```bash
f2py -c primes.f95 -m primes
python -m numpy.f2py -c primes.f95 -m primes
```
"""

import orbel

state = [1.0 ,0.0, 0.01, 0.0, 1.0, 0.0]
mu = 1.0

orbel.orbitalelements.state2kepelts(state, mu)