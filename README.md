# fortran-astrodynamics
Fortran astrodynamics routines

### Orbital elements

Compiling: 

```bash
> gfortran linalg.f90 orbitalelements.f90
```

or specifying the output executable name:

```bash
$ gfortran -o orbel linalg.f90 orbitalelements.f90
```

then executing:

```bash
$ a.exe
```

### Usage via Python

Prepare the module for python with 

```bash
$ f2py -c linalg.90 orbitalelements.f90 -m orbel
$ python -m numpy.f2py -c linalg.90 orbitalelements.f90 -m orbel
```

then use in python:
```python
import orbel
state = [1.0 ,0.0, 0.01, 0.0, 1.0, 0.0]
mu = 1.0
kepelts = orbel.orbitalelements.state2kepelts(state, mu)
```
