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
$ python -m numpy.f2py -c linalg.f90 orbitalelements.f90 -m orbel
```

then use in Python:
```python
import orbel
state = [1.0 ,0.0, 0.01, 0.0, 1.0, 0.0]
mu = 1.0
kepelts = orbel.orbitalelements.state2kepelts(state, mu)
```

### Usage via Julia

Compile via

```bash
gfortran linalg.f90 orbitalelements.f90 keplerder.f90 -o keplerder.so -shared -fPIC
```

then use with Julia: 
```julia
state1 = [Float64(0.0), Float64(0.0), Float64(0.0),
          Float64(0.0), Float64(0.0), Float64(0.0)]
mu = Float64(1.0)
state0 = [Float64(1.01), Float64(0.0), Float64(0.2),
          Float64(0.0), Float64(0.98), Float64(0.067)]
t0 = Float64(0.0)
t  = Float64(3.14)
tol = Float64(1.e-14)
maxiter = Int32(10)

ccall((:propagate, "./keplerder.so"), Nothing,
       (Ref{Float64}, Ref{Float64}, Ref{Float64},
        Ref{Float64}, Ref{Float64}, Ref{Float64}, Ref{Int32}),
       state1, mu, state0,
       t0, t, tol, maxiter)
```

Note that when using Julia's `ccall` for Fortran code, the return type should always be `Nothing`. 
