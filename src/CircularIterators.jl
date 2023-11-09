@everywhere module CircularIterators

export CircularIterator, iterate

struct CircularIterator{T}
    # TODO: make this an iterator
    it::Vector{T}
    len::Int
    prec::Int
    CircularIterator(it::Vector{T}, len::Int, prec::Int = -1) where T = new{T}(it, len, prec)
end

function Base.iterate(self::CircularIterator{T}) where T
    if self.len == 0
        return nothing
    end
    (self.it[1], 1)
end

function Base.iterate(self::CircularIterator{T}, state::Integer) where T
    if self.len == 0
        return nothing
    end
    (self.it[mod1(state + 1, self.len)], mod1(state + 1, self.len))
end
    



end