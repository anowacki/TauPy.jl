"""
# TauPy

Use the Python package ObsPy to calculate seismic travel times and ray paths for
teleseismic phases.

## Phases defined only by event depth and distance

For this case, functions return vectors of `Phase`s, which only contain details of each
phase in terms of distance from the event and radius.  Two methods are available:

## Phases defined by geographic coordinates

Here, functions give vectors of `PhaseGeog`s, which include information about the
geographic location within the Earth of the event, station, and potentially ray
path between them.

## Functions

In the case of either 1D or geographical phases, two functions are available:

- `travel_time` returns `Phase` objects which contain only time and slowness information.
- `path` returns `Phase`s which also contain the ray path.

Each have two methods, one where only depth and distance are specified, and the other
for when one wants also to include geographic information.

There is also the convenience function `turning_depth`, which gives the turning
depth of a `Phase` or `PhaseGeog` when the path has been calculated, and throws
an error when it has not.
"""
module TauPy

export
    AbstractPhase,
    Phase,
    PhaseGeog,
    path,
    travel_time,
    turning_depth

using PyCall

function __init__()
    # This is just to make sure geographiclib is installed for geographic ray paths
    pyimport_conda("geographiclib", "geographiclib", "conda-forge")
    copy!(Taup, pyimport_conda("obspy.taup", "obspy", "conda-forge"))
    for m in AVAILABLE_MODELS
        global MODEL[m] = Taup[:TauPyModel](m)
        global RADIUS[m] = MODEL[m][:model][:radius_of_planet]
    end
end

const Taup = PyNULL()

const TauPyFloat = Float64
"All available models for us in TauPy"
const AVAILABLE_MODELS = ("1066a", "1066b", "ak135", # "ak135f", # FIXME: Doesn't work
                          "ak135f_no_mud", "herrin",
                          "iasp91", "jb", "prem", "pwdk", "sp6")
"Default model used by TauPy"
const DEFAULT_MODEL = "ak135"
"Dictionary of pre-instantiated models, where keys are the model names"
const MODEL = Dict{String,PyObject}()
"Dictionary of the radius (km) of models"
const RADIUS = Dict{String,TauPyFloat}()

"""
    AbstractPhase

Abstract type from which `Phase` and `PhaseGeog` subtype.  Methods which may take
either `Phase`s or `PhaseGeog`s should specify their arguments as `AbstractPhase`s.
"""
abstract type AbstractPhase end

function Base.:(==)(p1::AbstractPhase, p2::AbstractPhase)
    p1 === p2 && return true
    typeof(p1) == typeof(p2) || return false
    for f in fieldnames(typeof(p1))
        if getfield(p1, f) isa AbstractVector
            length(getfield(p1, f)) == length(getfield(p2, f)) || return false
            all((a,b) -> a==b, zip(getfield(p1, f), getfield(p2, f))) ||
                return false
        else
            getfield(p1, f) == getfield(p2, f) || return false
        end
    end
    true
end

include("phase.jl")
include("phase_geog.jl")
include("memo.jl")

"""
    available_models()

Return the models which are available for use in TauPy.
"""
available_models() = AVAILABLE_MODELS

"""
    turning_depth(p::AbstractPhase) -> depth

Return the turning `depth` (km) for a phase which has had its ray path calculated.
Throw an error if the path has not been calculated.
"""
turning_depth(p::AbstractPhase) = length(p.radius) > 0 ? RADIUS[p.model] - minimum(p.radius) :
    error("No path calculated for phase")

"""
    _call_taup(taup_function, model, args...; cache=true) -> arrivals

Generic routine to call the Obspy taup module and process the arguments into a vector
of `Phase`s or `PhaseGeog`s.

`taup_function` is a `Symbol` giving the name of the obspy.taup function to call.
"""
function _call_taup(func::Symbol, model, args...; cache=true)
    key = cache_args_key(func, model, args...)
    arr = if cache && haskey(RAY_CACHE, key)
        get_cache(key)
    else
        arr = _phases_from_arrivals(MODEL[model][func](args...), model)
        cache && update_cache!(key, arr)
        arr
    end
end

end # module
