using SIMD

include("sorting-network-parameters.jl")

@generated function sort_net(input::Vararg{T, L}) where {L,T}

    ex = Expr[Expr(:meta, :inline)]

    net_params = sorting_network_parameters[L]

    nsteps = length(net_params)

    for t in 1:L
        a1 = Symbol("input_", 0, "_", t)
        push!(ex, :($a1 = input[$t]))
    end

    for st in 1:nsteps

        touched = [x for t in net_params[st] for x in t]
        untouched = setdiff(1:L, touched)

        for t in untouched
            a1 = Symbol("input_", st-1, "_", t)
            b1 = Symbol("input_", st, "_", t)
            push!(ex, :($b1 = $a1))
        end

        for t in net_params[st]
            a1 = Symbol("input_", st-1, "_", t[1])
            a2 = Symbol("input_", st-1, "_", t[2])
            b1 = Symbol("input_", st, "_", t[1])
            b2 = Symbol("input_", st, "_", t[2])
            push!(ex, :($b1 = min($a1, $a2)))
            push!(ex, :($b2 = max($a1, $a2)))
        end
    end

    push!(ex,
          Expr(:tuple, ntuple(t->Symbol("input_", nsteps, "_", t), L)...))

    ex
    quote $(ex...) end
end
