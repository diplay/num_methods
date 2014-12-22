methods =
  trap: (f, a, b, n) ->
    h = (b - a) / n
    ans = (f(a) + f(b)) / 2.0
    ans += [1...n].reduce (x, i) -> x + f(a + i*h)
    ans *= h
    return ans

  simpson: (f, a, b, n) ->
    n *= 2
    h = (b - a) / n
    ans = f(a) + f(b)
    ans += [1...n].reduce (x, i) -> x + (if i % 2 == 1 then 4 else 2)*f(a + i*h)
    ans *= h / 3
    return ans

module.exports = methods
