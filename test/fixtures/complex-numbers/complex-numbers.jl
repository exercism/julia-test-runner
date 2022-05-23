import Base: ==, +, -, *, /, abs, conj, exp, imag, real, zero, promote_rule

struct ComplexNumber{T <: Real} <: Number
    a::T
    b::T
end

function ComplexNumber(a::T, b::U) where {T <: Real, U <: Real}
    V = promote_type(T, U)
    ComplexNumber{V}(V(a), V(b))
end

# This makes isapprox work and is needed for Bonus 2.
ComplexNumber{T}(a::Real) where T = ComplexNumber{T}(T(a), zero(T))

# Convert ComplexNumber{U} to ComplexNumber{T}, required for Bonus 2.
ComplexNumber{T}(a::ComplexNumber) where T = ComplexNumber{T}(T(a.a), T(a.b))

# You can make isapprox work without defining the constructor above if you
# define zero and real
zero(::Type{ComplexNumber{T}}) where T = ComplexNumber(zero(T), zero(T))
zero(x::ComplexNumber{T}) where T = ComplexNumber(zero(T), zero(T))

real(::Type{ComplexNumber{T}}) where T = T
real(x::ComplexNumber) = x.a

imag(::Type{ComplexNumber{T}}) where T = T
imag(x::ComplexNumber) = x.b

# Default structural equality method uses ===, but we will often contain
# floats, which must be compared with ==
==(x::ComplexNumber, y::ComplexNumber) = x.a == y.a && x.b == y.b

conj(x::ComplexNumber) = ComplexNumber(x.a, -x.b)
abs(x::ComplexNumber) = sqrt(x.a * x.a + x.b * x.b)

-(x::ComplexNumber) = ComplexNumber(-x.a, -x.b)
+(x::ComplexNumber, y::ComplexNumber) = ComplexNumber(x.a + y.a, x.b + y.b)
-(x::ComplexNumber, y::ComplexNumber) = x + -y

*(x::ComplexNumber, y::ComplexNumber) = ComplexNumber(x.a * y.a - x.b * y.b,
                                                      x.b * y.a + x.a * y.b)

/(x::ComplexNumber, y::ComplexNumber) = ComplexNumber((x.a * y.a + x.b * y.b) / (y.a^2 + y.b^2),
                                                      (x.b * y.a - x.a * y.b) / (y.a^2 + y.b^2))

# Bonus 1: exp

# Promotion rule makes mixed Real/Complex mathematical operations work

# Commenting this out makes some of the tests fail, which is useful for testing the test runner :)
# promote_rule(::Type{T}, ::Type{ComplexNumber{U}}) where {T <: Real, U} = ComplexNumber{promote_type(T, U)}
exp(x::ComplexNumber) = ℯ^x.a * ComplexNumber(cos(x.b), sin(x.b))

# Bonus 2: jm unit

# Better to use false here because we need that strong multiplicative zero
# to make `0 + NaN * jm === ComplexNumber(0, NaN)`
const jm = ComplexNumber(false, true)
