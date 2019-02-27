# TauPy

Calculate properties of teleseismic arrivals through a selection of
1D Earth models, using the [ObsPy](https://github.com/obspy/obspy/wiki) Python software.

[![Build Status](https://travis-ci.org/anowacki/TauPy.jl.svg?branch=master)](https://travis-ci.org/anowacki/TauPy.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/x0g14wuls8yp19tv/branch/master?svg=true)](https://ci.appveyor.com/project/AndyNowacki/taupy-jl/branch/master)
[![Coverage Status](https://coveralls.io/repos/github/anowacki/TauPy.jl/badge.svg?branch=master)](https://coveralls.io/github/anowacki/TauPy.jl?branch=master)

## Install

To install on Julia versions v0.7 and above:
```julia
julia> import Pkg; Pkg.add("https://github.com/anowacki/TauPy.jl")
```

This package uses [PyCall.jl](https://github.com/JuliaPy/PyCall.jl) package to
access ObsPy.  If you have the default PyCall installation, then ObsPy will be
installed automatically via its own Conda environment.  If you use your own
Python with PyCall, then you may need to install ObsPy for you installation
via `conda`, `pip`, or another means.

(Older versions of TauPy compatible with Julia v0.6 can be installed by doing
`Pkg.clone("https://github.com/anowacki/TauPy.jl")`.)

### Problems importing `geographiclib` or `obspy.taup`

If you receive and error like `ERROR: InitError: Failed to import required Python
module geographiclib` when you first try `using TauPy`, then it's likely that
PyCall is set up to use your system `python` command, but the required packages
aren't installed or available.  The easiest way to get things working is:

```julia
julia> ENV["PYTHON"] = ""; Pkg.build("PyCall")
```

Restart, and then try to do `using TauPy` again.  Note, however, that PyCall
will from hereon in always use its internal Conda `python` (which is at
`PyCall.python`).

## Use

TauPy exports three functions:

- `travel_time`
- `path`
- `turning_depth`

These take either epicentral distance, or source and receiver coordinates, and
return `TauPy.Phase` objects containing information about the phase.  There are
two types exported by TauPy:

- `Phase`, containing information about a seismic phase calculated using only
  event depth and epicentral distance; and
- `PhaseGeog`, which is the same but for source and receiver locations specified
  geographically (with longitude and latitude).

The interactive help describes the fields contained by `Phase`s and `PhaseGeog`s.
To bring this up, type `?Phase` or `?PhaseGeog` and hit return.

### Specifying the seismic phase

The final positional argument of both `travel_time` and `path` is the name of
the seismic phase.  This can be a single string, or an array of names.  E.g.:

```julia
julia> using TauPy

julia> p = travel_time(0, 10, ["P", "PcP"])
2-element Array{Phase{Float64},1}:
 Phase{Float64}("ak135", "P", 10.0, 0.0, 144.89570946391675, 13.700630345173362, 45.613198013389635, 45.613198013389635, Float64[], Float64[], Float64[])
 Phase{Float64}("ak135", "PcP", 10.0, 0.0, 516.4444277972648, 0.9479529695834205, 2.834193976594543, 2.834193976594543, Float64[], Float64[], Float64[]) 

```

By default, all arrivals from a predetermined list are returned, corresponding
to the &lsquo;phase&rsquo; `"ttall"`.

### Specifying the Earth model

With both `travel_time` and `path`, specify the Earth model by using the `model`
keyword argument like so:

```julia
julia> arr = travel_time(0, 10, "P", model="sp6")
1-element Array{Phase{Float64},1}:
 Phase{Float64}("sp6", "P", 10.0, 0.0, 144.8972605261263, 13.7011317118041, 45.61534012667141, 45.61534012667141, Float64[], Float64[], Float64[])

```

Available models are listed by calling `TauPy.available_models()`.

### Examples

Use the `travel_time` function to quickly calculate the arrival times for
the triplicated arrivals at around 20&deg; epicentral distance:

```julia
julia> using TauPy

julia> p = travel_time(110, 20, "P")
5-element Array{TauPy.Phase{Float64},1}:
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 263.806, 10.7956, 34.2707, 52.6707, Float64[], Float64[], Float64[])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 266.524, 11.5422, 37.0166, 58.2286, Float64[], Float64[], Float64[])
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 266.525, 11.5214, 36.9391, 58.063, Float64[], Float64[], Float64[]) 
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 267.698, 9.21572, 28.731, 42.7498, Float64[], Float64[], Float64[]) 
 TauPy.Phase{Float64}("ak135", "P", 20.0, 110.0, 268.261, 9.5515, 29.8818, 44.7109, Float64[], Float64[], Float64[]) 

julia> times = getfield.(p, :time)
5-element Array{Float64,1}:
 263.80556674138126
 266.52428738827155
 266.5253559803772 
 267.6979484052481 
 268.26087550766334

```

Good luck in picking all of those!

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

If you want to know the arrivals&rsquo; turning depths, then `turning_depth`
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

If you want to know the geographical coordinates of the path for an event and
station, then use the source and receiver geographical coordinates:

```julia
julia> event_lon, event_lat, sta_lon, sta_lat, dep = 0, 0, 10, 10, 100;

julia> p = path(event_lon, event_lat, dep, sta_lon, sta_lat, "S")
3-element Array{TauPy.PhaseGeog{Float64},1}:
 TauPy.PhaseGeog{Float64}("ak135", "S", 0.0, 0.0, 10.0, 10.0, 100.0, 14.106, 350.494, 24.1935, 48.835, 83.5499, Float64[], [0.0, 0.542449, 1.36541, 1.40396, 1.44327, 3.49073, 5.54737, 5.58703, 5.62594, 6.45806  …  9.8127, 9.83169, 9.84117, 9.85065, 9.88817, 9.9256, 9.96294, 9.98158, 9.99089, 10.0002], [0.0, 0.550792, 1.38607, 1.42518, 1.46506, 3.53789, 5.60619, 5.64589, 5.68482, 6.51558  …  9.81819, 9.83664, 9.84585, 9.85506, 9.89149, 9.92782, 9.96405, 9.98213, 9.99116, 10.0002], [6271.0, 6262.21, 6251.8, 6251.4, 6251.0, 6240.69, 6251.0, 6251.4, 6251.8, 6262.21  …  6347.25, 6349.13, 6350.06, 6351.0, 6356.0, 6361.0, 6366.0, 6368.5, 6369.75, 6371.0])                   
 TauPy.PhaseGeog{Float64}("ak135", "S", 0.0, 0.0, 10.0, 10.0, 100.0, 14.106, 364.733, 20.4703, 39.5658, 57.2195, Float64[], [0.0, 0.0878754, 0.192757, 0.19682, 0.200884, 0.315745, 0.431873, 0.52082, 0.666153, 0.762522  …  9.87896, 9.89135, 9.89753, 9.90372, 9.93078, 9.9578, 9.98476, 9.99822, 10.0049, 10.0117], [0.0, 0.0892309, 0.195729, 0.199855, 0.203982, 0.320611, 0.438522, 0.528832, 0.676382, 0.774215  …  9.88255, 9.89457, 9.90058, 9.90658, 9.93285, 9.95906, 9.98522, 9.99827, 10.0048, 10.0113], [6271.0, 6262.21, 6251.8, 6251.4, 6251.0, 6239.72, 6228.43, 6219.86, 6206.0, 6196.9  …  6347.25, 6349.13, 6350.06, 6351.0, 6356.0, 6361.0, 6366.0, 6368.5, 6369.75, 6371.0])
 TauPy.PhaseGeog{Float64}("ak135", "S", 0.0, 0.0, 10.0, 10.0, 100.0, 14.106, 364.855, 20.7161, 40.1367, 58.304, Float64[], [0.0, 0.0916586, 0.201103, 0.205344, 0.209587, 0.32951, 0.450821, 0.543782, 0.695759, 0.796594  …  9.86447, 9.87716, 9.8835, 9.88984, 9.91746, 9.94502, 9.97253, 9.98627, 9.99313, 9.99999], [0.0, 0.0930724, 0.204205, 0.208511, 0.212819, 0.334588, 0.457761, 0.552145, 0.706439, 0.808803  …  9.86848, 9.8808, 9.88695, 9.8931, 9.91991, 9.94667, 9.97336, 9.98668, 9.99334, 9.99999], [6271.0, 6262.21, 6251.8, 6251.4, 6251.0, 6239.72, 6228.43, 6219.86, 6206.0, 6196.9  …  6347.25, 6349.13, 6350.06, 6351.0, 6356.0, 6361.0, 6366.0, 6368.5, 6369.75, 6371.0])  

```

Similarly, `travel_time` also accepts five geographic arguments if you know the
event and station coordinates.

### Calculation cache

Unfortunately, Obspy's travel time and raypath calculations are somewhat
slow.  To speed up repeated calculations of the same times and raypaths,
TauPy implements a cache.  To set the size of the cache, use the
`TauPy.set_cache_size_mb!(size_mb)` function.  The cache can be clared
using `TauPy.clear_cache!()`.  These functions are not exported.

To disable the cache for individual calls to `path` or `travel_time`,
pass the keyword argument `cache=false`.

