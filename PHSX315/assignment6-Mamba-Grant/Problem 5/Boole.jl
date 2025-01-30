f(x) = x^4 * cos(x)^6

A(a, b, n) = sum(f.(a .+ (2.0 .* (1:((n+1)./2)) .- 1) .* (b - a) / n))
B(a, b, n) = sum(f.(a .+ (4.0 .* (1:((n+1)./4)) .- 2) .* (b - a) / n))
C(a, b, n) = sum(f.(a .+ (4.0 .* (1:(n/4)) .* (b - a) / n)))
@time Boole(a, b, n) = 2 / 45 * (b - a) / n * (7 * f(a) + 32 * A(a, b, n) + 12 * B(a, b, n) + 14 * C(a, b, n) + 7 * f(b))
@time Boole(0, 2*pi, 1000)

Error(a, b, c) = abs( Boole(a, b, c/2) - Boole(a, b, c) ) / 63
