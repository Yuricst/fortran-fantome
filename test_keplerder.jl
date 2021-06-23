"""
Test module on Julia

Compile as:

```
gfortran linalg.f90 orbitalelements.f90 keplerder.f90 -o keplerder.so -shared -fPIC
```

Tuto:
https://craftofcoding.wordpress.com/2017/03/01/calling-fortran-from-julia-ii/
"""

using BenchmarkTools


## first test
n = Int32(5)
a = Float64(2.0)
b = [Float64(0.0)] # 配列にする b = zeros(Float64, 1) 等でも可
c = [Float64(0.0)] # 配列にする

println("b: $b, n: $n")
ccall((:test1, "./keplerder.so"), Nothing,
        (Ref{Int32}, Ref{Float64}, Ref{Float64}, Ref{Float64}),
        n, a, b, c)
println("b: $b, n: $n")


## Keplerder test
state1 = [Float64(0.0), Float64(0.0), Float64(0.0),
          Float64(0.0), Float64(0.0), Float64(0.0)]
mu = Float64(1.0)
state0 = [Float64(1.01), Float64(0.0), Float64(0.2),
          Float64(0.0), Float64(0.98), Float64(0.067)]
t0 = Float64(0.0)
t  = Float64(3.14)
tol = Float64(1.e-14)
maxiter = Int32(10)

println("state0: \n$state0")

ccall((:propagate, "./keplerder.so"), Nothing,
       (Ref{Float64}, Ref{Float64}, Ref{Float64},
        Ref{Float64}, Ref{Float64}, Ref{Float64}, Ref{Int32}),
       state1, mu, state0,
       t0, t, tol, maxiter)
println("state1: \n$state1")

println("Done!")

## Measure time
# @time begin
#         ccall((:propagate, "./keplerder.so"), Nothing,
#                (Ref{Float64}, Ref{Float64}, Ref{Float64},
#                 Ref{Float64}, Ref{Float64}, Ref{Float64}, Ref{Int32}),
#                state1, mu, state0,
#                t0, t, tol, maxiter)
# end

@btime ccall((:propagate, "./keplerder.so"), Nothing,
       (Ref{Float64}, Ref{Float64}, Ref{Float64},
        Ref{Float64}, Ref{Float64}, Ref{Float64}, Ref{Int32}),
       state1, mu, state0,
       t0, t, tol, maxiter)
