# Geographic phases

"""
    PhaseGeog(model, name, evlon, evlat, depth, time, dtdd, inc, takeoff)
    PhaseGeog(..., pierce, lon, lat, radius)

Construct a `PhaseGeog`, which represents a single event-station path and one single phase
arrival between two geographic points.


`PhaseGeog` objects have the following fields:

- `model`: Name of model used to calculate phase properties
- `name`: Name of phase
- `evlon`, `evlat`, `depth`: Event longitude and latitude (in °) and depth (in km)
- `stlon`, `stlat`: Station longitude and latitude in °
- `delta`: Epicentral distance in °
- `time`: Travel time in s
- `dtdd`: Horizontal slowness (ray parameter) in s/°
- `inc`: Incidence angle at receiver, measured from downwards in °
- `takeoff`: Takeoff angle at source, measured from downwards in °

The following fields are filled if the ray path has been calculated via `path`:

- `lon`, `lat: `Vector`s of geographic coodinates in ° along the path
- `radius`: `Vector` of radii in km along the path
"""
struct PhaseGeog{T} <: AbstractPhase
    model::String
    name::String
    evlon::T
    evlat::T
    stlon::T
    stlat::T
    depth::T
    delta::T
    time::T
    dtdd::T
    inc::T
    takeoff::T
    pierce::Vector{T}
    lon::Vector{T}
    lat::Vector{T}
    radius::Vector{T}
end
PhaseGeog(model, name, evlon, evlat, stlon, stlat, depth, delta, time, dtdd, inc, takeoff) = 
    PhaseGeog{TauPyFloat}(model, name, evlon, evlat, stlon, stlat, depth, delta, time,
                          dtdd, inc, takeoff, [], [], [], [])
PhaseGeog(p::PhaseGeog, pierce, lon, lat, radius) =
    PhaseGeog{TauPyFloat}(p.model, p.name, p.evlon, p.evlat, p.evlon, p.evlat, p.depth,
                          p.delta, p.time, p.dtdd, p.inc, p.takeoff, pierce, lon, lat, radius)


"""
    path(event_lon, event_lat, depth, station_lon, station_lat, phase="ttall"; model="$DEFAULT_MODEL", cache=true) -> Vector{PhaseGeog}

Create a set of `PhaseGeogs` which contain the computed ray path for a set of `phase`s
from event at (`event_lon`, `event_lat`)° and `depth` km deep, recorded at a station
at (`station_lon`, `station_lat`)°.  Optionally specify the model (one of
$(AVAILABLE_MODELS)).

If no arrivals are found for the geometry, an empty `Vector{Phase}` is returned.

Set `cache` to `false` to always recompute the ray path and ignore the module cache.
"""
function path(event_lon, event_lat, depth, station_lon, station_lat, phase="ttall";
              model=DEFAULT_MODEL, cache=true)
    phase = phase isa AbstractString ? [phase] : phase
    _call_taup(:get_ray_paths_geo, model, depth, event_lat, event_lon,
               station_lat, station_lon, phase; cache=cache)
end

"""
    travel_time(event_lon, event_lat, depth, station_lon, station_lat, phase="ttall"; model="$DEFAULT_MODEL", cache=true) -> Vector{PhaseGeog}

Return a `Vector` of `PhaseGeog`s, given an event `depth` km deep located at
(`event_lon`, `event_lat`)°, recorded at a station at (`station_lon`, `station_lat`)°.
Optionally specify the model (one of: $(AVAILABLE_MODELS)).

If no arrivals are found for the geometry, an empty `Vector{Phase}` is returned.

Set `cache` to `false` to always recompute the ray path and ignore the module cache.
"""
function travel_time(event_lon, event_lat, depth, station_lon, station_lat, phase="ttall";
                     model=DEFAULT_MODEL, cache=true)
    phase = phase isa AbstractString ? [phase] : phase
    _call_taup(:get_travel_times_geo, model, depth, event_lat, event_lon, station_lat, station_lon, phase; cache=cache)
end

"""Helper function which takes `obspy.taup.Arrivals` and returns `PhaseGeog`s.
Arguments should be the same as those passed to osbpy.taup calls, prefixed
by `model`."""
function _phases_from_arrivals(arr, model, depth, event_lat, event_lon,
                               station_lat, station_lon, phase)
    p = Vector{PhaseGeog{TauPyFloat}}()
    for a in arr
        name = a.name
        delta = a.distance
        depth = a.source_depth
        time = a.time
        dtdd = deg2rad(a.ray_param)
        inc = a.incident_angle
        takeoff = a.takeoff_angle
        path = a.path
        lon, lat, radius = if path === nothing
            TauPyFloat[], TauPyFloat[], TauPyFloat[]
        else
            pathlist = path.tolist()
            [pp[6] for pp in pathlist], [pp[5] for pp in pathlist],
                RADIUS[model] .- [pp[4] for pp in pathlist]
        end
        push!(p, PhaseGeog{TauPyFloat}(model, name, event_lon, event_lat, station_lon,
                                       station_lat, depth, delta, time, dtdd, inc, takeoff,
                                       [], lon, lat, radius))
    end
    p
end
