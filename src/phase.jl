# Phases in a 1D Earth

"""
    Phase(model, name, delta, depth, time, dtdd, inc, takeoff)
    Phase(..., pierce, distance, radius)

Construct a `Phase1D`, which represents a single event-station path and one single phase
arrival.
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
    path(depth, distance, phase="all"; model="$DEFAULT_MODEL") -> p::Vector{Phase}

Create a set of `Phase`s which contain the computed ray path for a set of `phase`s
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
