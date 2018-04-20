# TauPy

Calculate properties of teleseismic arrivals through a selection of
1D Earth models, using the [ObsPy](https://github.com/obspy/obspy/wiki) Python software.

## Install

```julia
Pkg.clone(https://github.com/anowacki/TauPy.jl)
```

This package uses [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) package to
access ObsPy.  If you have the default PyCall installation, then ObsPy will be
installed automatically via its own Conda environment.  If you use your own
Python with PyCall, then you may need to install ObsPy for you installation
via `conda`, `pip`, or another means.

If you want to use the local PyCall conda install, but are having problems,
you can try rebuilding PyCall to use this:

```julia
julia> ENV["PYTHON"] = ""; Pkg.build("PyCall")
```

## Use

Use the `travel_time` function to quickly calculate the arrival time, slowness, and
takeoff and incidence angles for the triplicated arrivals at around 20&deg;
epicentral distance:

```julia
julia> using TauPy

julia> p = travel_time(110, 20, "P")
5-element Array{TauPy.Phase{Float64},1}:
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 263.806, 10.7956, 34.2707, 52.6707, Float64[], Float64[], Float64[])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 266.524, 11.5422, 37.0166, 58.2286, Float64[], Float64[], Float64[])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 266.525, 11.5214, 36.9391, 58.063, Float64[], Float64[], Float64[]) 
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 267.698, 9.21572, 28.731, 42.7498, Float64[], Float64[], Float64[]) 
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 268.261, 9.5515, 29.8818, 44.7109, Float64[], Float64[], Float64[]) 

```

You can also calculate the ray paths between the event and station:

```julia
julia> p = path(110, 20, "P")
5-element Array{TauPy.Phase{Float64},1}:
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 263.806, 10.7956, 34.2707, 52.6707, Float64[], [0.0, 0.120381, 0.142296, 0.1643, 0.208576, 0.298225, 0.472472, 0.652408, 0.667963, 0.683563  …  19.8216, 19.8493, 19.8632, 19.8701, 19.877, 19.9267, 19.9634, 19.9817, 19.9909, 20.0001], [6261.0, 6251.0, 6249.19, 6247.37, 6243.74, 6236.44, 6222.49, 6208.41, 6207.2, 6206.0  …  6343.5, 6347.25, 6349.13, 6350.06, 6351.0, 6359.05, 6365.02, 6368.01, 6369.51, 6371.0])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 266.524, 11.5422, 37.0166, 58.2286, Float64[], [0.0, 0.148344, 0.175382, 0.202552, 0.257294, 0.368423, 0.585572, 0.811497, 0.831113, 0.850797  …  19.8016, 19.8328, 19.8484, 19.8562, 19.864, 19.9189, 19.9596, 19.9799, 19.99, 20.0001], [6261.0, 6251.0, 6249.19, 6247.37, 6243.74, 6236.44, 6222.49, 6208.41, 6207.2, 6206.0  …  6343.5, 6347.25, 6349.13, 6350.06, 6351.0, 6359.05, 6365.02, 6368.01, 6369.51, 6371.0])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 266.525, 11.5214, 36.9391, 58.063, Float64[], [0.0, 0.147386, 0.174248, 0.20124, 0.255622, 0.366009, 0.581664, 0.805968, 0.82544, 0.844979  …  19.7997, 19.8308, 19.8463, 19.854, 19.8618, 19.9165, 19.9571, 19.9773, 19.9875, 19.9976], [6261.0, 6251.0, 6249.19, 6247.37, 6243.74, 6236.44, 6222.49, 6208.41, 6207.2, 6206.0  …  6343.5, 6347.25, 6349.13, 6350.06, 6351.0, 6359.05, 6365.02, 6368.01, 6369.51, 6371.0]) 
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 267.698, 9.21572, 28.731, 42.7498, Float64[], [0.0, 0.0847973, 0.100216, 0.115685, 0.146774, 0.209565, 0.331002, 0.455546, 0.466272, 0.47702  …  19.858, 19.8798, 19.8907, 19.8961, 19.9016, 19.9415, 19.971, 19.9858, 19.9931, 20.0005], [6261.0, 6251.0, 6249.19, 6247.37, 6243.74, 6236.44, 6222.49, 6208.41, 6207.2, 6206.0  …  6343.5, 6347.25, 6349.13, 6350.06, 6351.0, 6359.05, 6365.02, 6368.01, 6369.51, 6371.0])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 268.261, 9.5515, 29.8818, 44.7109, Float64[], [0.0, 0.0908228, 0.10734, 0.123913, 0.157226, 0.224534, 0.3548, 0.488528, 0.500051, 0.511599  …  19.8505, 19.8734, 19.8848, 19.8905, 19.8963, 19.9381, 19.9691, 19.9845, 19.9923, 20.0], [6261.0, 6251.0, 6249.19, 6247.37, 6243.74, 6236.44, 6222.49, 6208.41, 6207.2, 6206.0  …  6343.5, 6347.25, 6349.13, 6350.06, 6351.0, 6359.05, 6365.02, 6368.01, 6369.51, 6371.0])   

```

If you want to know the arrivals&rsquo; turning depths, then `turning_depths`
is what you want:

```julia
julia> turning_depth.(p)
5-element Array{Float64,1}:
 465.716
 406.874
 410.0  
 665.676
 660.0  

```

If you want to know the geographical