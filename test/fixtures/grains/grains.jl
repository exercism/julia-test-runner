"""Calculate the number of grains on square `i`."""
# 2^(i-1)
on_square(i) = i in 1:64 ? (UInt64(1) << (i-1)) : throw(DomainError(i))

"""Calculate the total number of grains on squares `1:i`"""
# (2^i) - 1
total_after(i) = i in 1:64 ? ((UInt64(1) << i) - 1) : throw(DomainError(i))
