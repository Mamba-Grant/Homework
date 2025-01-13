A(a, b, n) = sum(4.0 .* f.(a .+ (2.0 .* (1:((n+1)./2)) .- 1) .* (b - a) / n))
B(a, b, n) = sum(2.0 .* f.(a .+ (2.0 .* (1:(n/2))) .* (b - a) / n))

f(x) = x^4 * cos(x)^6

@time Simpson(a, b, n) = (b - a) / (3 * n) * (f(a) + A(a, b, n) + B(a, b, n) + f(b))
@time Simpson(0, 2*π, 1000)

Error(a, b, c) = abs( Simpson(a, b, c/2) - Simpson(a, b, c) ) / 15
