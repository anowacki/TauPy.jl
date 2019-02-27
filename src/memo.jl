# Memoization for calls to TauPy
"Raypath cache holding previously-computed ray paths"
const RAY_CACHE = Dict{UInt64,Any}()
"Counter for number of calls to each item in raypath cache"
const RAY_NCALLS = Dict{UInt64,Int64}()
"Maximum size in MB of the raypath cache"
const MAX_SIZE_MB_CACHE = Ref(1024.0)

"Return the key for the ray cache for a particular set of arguments"
cache_args_key(args...) = hash(args)

"""
    update_cache!(key, val)

Update the raypath cache, dropping least-used values when the cache is full, and
return the value in the cache.
"""
function update_cache!(key, val)
    if haskey(RAY_CACHE, key)
        RAY_NCALLS[key] += 1
        return val
    end
    RAY_CACHE[key] = val
    RAY_NCALLS[key] = 1
    while Base.summarysize(RAY_CACHE)/1024^2 > MAX_SIZE_MB_CACHE[]
        minkey = argmin(RAY_NCALLS)
        delete!(RAY_CACHE, minkey)
        delete!(RAY_NCALLS, minkey)
    end
    val
end

"""
    get_cache(key) -> ::Union{Vector{Phase},Vector{PhaseGeog}}

Get a value from the ray path cache and update the call count.
"""
get_cache(key) = update_cache!(key, RAY_CACHE[key])

"""
    clear_cache!()

Remove all values from the ray path cache.
"""
clear_cache!() = (empty!(RAY_CACHE); empty!(RAY_NCALLS))

"""
    set_cache_size_mb!(max_size)

Set the maximum size of the ray path cache.
"""
set_cache_size_mb!(max_size) = MAX_SIZE_MB_CACHE[] = max_size