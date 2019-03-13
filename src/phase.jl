# Phases in a 1D Earth

"""
    Phase(model, name, delta, depth, time, dtdd, inc, takeoff)
    Phase(..., pierce, distance, radius)

Construct a `Phase`, which represents a single event-station path and one single phase
arrival.

`Phase` objects have the following fields:

- `model`: Name of model used to calculate phase properties
- `name`: Name of phase
- `delta`: Epicentral distance in °
- `depth`: Depth of event below surface in km
- `time`: Travel time in s
- `dtdd`: Horizontal slowness (ray parameter) in s/°
- `inc`: Incidence angle at receiver, measured from downwards in °
- `takeoff`: Takeoff angle at source, measured from downwards in °

The following fields are filled if the ray path has been calculated via `path`:

- `distance`: `Vector` of distances in ° along the path
- `radius`: `Vector` of radii in km along the path
"""
struct Phase{T} <: AbstractPhase
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
function Phase(p::AbstractPhase, pierce::AbstractVector, distance::AbstractVector, radius::AbstractVector)
    length(pierce) == length(distance) == length(radius) ||
        throw(ArgumentError("pierce, distance and radius must be the same length"))
    Phase{TauPyFloat}(p.model, p.name, p.delta, p.depth, p.time, p.dtdd, p.inc, p.takeoff, pierce, distance, radius)
end

"""
    path(depth, distance, phase="ttall"; model="$DEFAULT_MODEL", cache=true) -> p::Vector{Phase}

Create a set of `Phase`s `p` which contain the computed ray path for a set of `phase`s
from an event `depth` km deep and at `distance`° away.
Optionally specify the `model` (one of: $(AVAILABLE_MODELS)).

If no arrivals are found for the geometry, an empty `Vector{Phase}` is returned.

Set `cache` to `false` to always recompute the ray path and ignore the module cache.
"""
function path(depth, distance, phase="ttall"; model=DEFAULT_MODEL, cache=true)
    phase = phase isa AbstractString ? [phase] : phase
    _call_taup(:get_ray_paths, model, depth, distance, phase; cache=cache)
end

"""
    travel_time(depth, distance, phase="ttall"; model="$DEFAULT_MODEL", cache=true) -> p::Vector{Phase}

Return a `Vector` of `Phase`s, given an event `depth` km deep and `distance`°
away.  Optionally specify a `phase` name; otherwise all arrivals are returned.
Optionally specify the model (one of: $(AVAILABLE_MODELS)).

If no arrivals are found for the geometry, an empty `Vector{Phase}` is returned.

Set `cache` to `false` to always recompute the travel time and ignore the module cache.
"""
function travel_time(depth, distance, phase="ttall"; model=DEFAULT_MODEL, cache=true)
    phase = phase isa AbstractString ? [phase] : phase
    _call_taup(:get_travel_times, model, depth, distance, phase; cache=cache)
end

"""Helper function which takes `obspy.taup.Arrivals` and returns `Phase`s.
Arguments should be the same as those to osbpy.taup calls, prefixed
by `model`."""
function _phases_from_arrivals(arr, model, depth, distance, phase)
    p = Vector{Phase{TauPyFloat}}()
    for a in arr
        name = a.name
        delta = a.distance
        depth = a.source_depth
        time = a.time
        dtdd = deg2rad(a.ray_param)
        inc = a.incident_angle
        takeoff = a.takeoff_angle
        path = a.path
        distance, radius = if path === nothing
            TauPyFloat[], TauPyFloat[]
        else
            pathlist = path.tolist()
            rad2deg.([pp[3] for pp in pathlist]), RADIUS[model] .- [pp[4] for pp in pathlist]
        end
        push!(p, Phase{TauPyFloat}(model, name, delta, depth, time, dtdd, inc, takeoff,
              [], distance, radius))
    end
    p
end
