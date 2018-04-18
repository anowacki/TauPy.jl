__precompile__()

"""
# TauPy

Use the Python package ObsPy to calculate seismic travel times and ray paths for
teleseismic phases.

#### Functions

- `travel_time` returns `Phase` objects which contain only time and slowness information.
- `path` returns `Phase`s which also contain the ray path.
"""
module TauPy

export
    Phase,
    path,
    travel_time,
    turning_depth

using PyCall

function __init__()
    copy!(Taup, pyimport_conda("obspy.taup", "obspy", "conda-forge"))
    for m in AVAILABLE_MODELS
        global MODEL[m] = Taup[:TauPyModel](m)
        global RADIUS[m] = MODEL[m][:model][:radius_of_planet]
    end
end

const Taup = PyNULL()

const TauPyFloat = Float64
const AVAILABLE_MODELS = ("1066a", "1066b", "ak135", # "ak135f", # FIXME: Doesn't work
                          "ak135f_no_mud", "herrin",
                          "iasp91", "jb", "prem", "pwdk", "sp6")
const DEFAULT_MODEL = "ak135"
const MODEL = Dict{String,PyObject}()
const RADIUS = Dict{String,TauPyFloat}()

"""
    Phase(model, name, delta, depth, time, dtdd, inc, takeoff)
    Phase(..., pierce, distance, radius)

Construct a `Phase`, which represents a single event-station path and one single phase
arrival.
"""
struct Phase{T}
    model::String
    name::String
    delta::T
    depth::T
    time::T
    dtdd::T
    inc::T
    takeoff::T
    pierce::Vector{T}
    distance::Vector{T}
    radius::Vector{T}
end
Phase(model, name, delta, depth, time, dtdd, inc, takeoff) =
    Phase{TauPyFloat}(model, name, delta, depth, time, dtdd, inc, takeoff, [], [], [])
function Phase(p::Phase, pierce::AbstractVector, distance::AbstractVector, radius::AbstractVector)
    length(pierce) == length(distance) == length(radius) ||
        throw(ArgumentError("pierce, distance and radius must be the same length"))
    Phase{TauPyFloat}(p.model, p.name, p.delta, p.depth, p.time, p.dtdd, p.inc, p.takeoff, pierce, distance, radius)
end

"""
    path(depth, distance, phase="all"; model="$DEFAULT_MODEL") -> p::Vector{Path{$TauPyFloat}}

Create a set of `Path`s which contain the computed ray path for a set of `phase`s
from an event `depth` km deep and at `distance`° away.
"""
function path(depth, distance, phase="all"; model=DEFAULT_MODEL)
    arr = if phase == "all"
        MODEL[model][:get_ray_paths](depth, distance)
    else
        phase = phase isa AbstractString ? [phase] : phase
        MODEL[model][:get_ray_paths](depth, distance, phase)
    end
    _phases_from_arrivals(arr, model)
end

"""
    travel_time(depth, distance, phase="all"; model="$DEFAULT_MODEL") -> Vector{Phase}

Return a `Vector` of `Phase`s, given an event `depth` km deep and `distance`°
away.  Optionally specify a phase name; otherwise all arrivals are returned.
Optionally specify the model (one of: $(AVAILABLE_MODELS)).
"""
function travel_time(depth, distance, phase="all"; model=DEFAULT_MODEL)
    arr = if phase == "all"
        MODEL[model][:get_travel_times](depth, distance)
    else
        phase = phase isa AbstractString ? [phase] : phase
        MODEL[model][:get_travel_times](depth, distance, phase)
    end
    _phases_from_arrivals(arr, model)
end

"""
    turning_depth(p::Phase) -> depth

Return the turning `depth` (km) for a phase which has had its ray path calculated.
"""
turning_depth(p::Phase) = length(p.distance) > 0 ? RADIUS[p.model] - minimum(p.radius) :
    error("No path calculated for phase")

"""Helper function which takes `obspy.taup.Arrivals` and returns `Phase`s."""
function _phases_from_arrivals(arr, model)
    p = Vector{Phase{TauPyFloat}}()
    for a in arr
        name = a[:name]
        delta = a[:distance]
        depth = a[:source_depth]
        time = a[:time]
        dtdd = deg2rad(a[:ray_param])
        inc = a[:incident_angle]
        takeoff = a[:takeoff_angle]
        path = a[:path]
        distance, radius = if path === nothing
            TauPyFloat[], TauPyFloat[]
        else
            pathlist = path[:tolist]()
            rad2deg.([pp[3] for pp in pathlist]), RADIUS[model] .- [pp[4] for pp in pathlist]
        end
        push!(p, Phase{TauPyFloat}(model, name, delta, depth, time, dtdd, inc, takeoff,
              [], distance, radius))
    end
    p
end

end # module
