__precompile__()

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
    copy!(Taup, pyimport_conda("obspy.taup", "obspy", "conda-forge"))
    # This is just to make sure geographiclib is installed
    pyimport_conda("geographiclib", "geographiclib")
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

abstract type AbstractPhase end

include("phase.jl")
include("phase_geog.jl")

"""    available_models()

Return the models which are available for use in TauPy."""
available_models() = AVAILABLE_MODELS

"""
    turning_depth(p::AbstractPhase) -> depth

Return the turning `depth` (km) for a phase which has had its ray path calculated.
"""
turning_depth(p::AbstractPhase) = length(p.radius) > 0 ? RADIUS[p.model] - minimum(p.radius) :
    error("No path calculated for phase")

end # module
