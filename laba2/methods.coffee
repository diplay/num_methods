methods =
  trap: (f, a, b, n) ->
    h = (b - a) / n
    ans = (f(a) + f(b)) / 2.0
    for i in [1...n]
      ans += f(a + i*h)
    ans *= h
    return ans

  simpson: (f, a, b, n) ->
    h = (b - a) / n
    ans = f(a) + f(b)
    for i in [1...n]
      ans += 4*f(a + i*h) if i % 2 == 1
      ans += 2*f(a + i*h) if i % 2 == 0
    ans *= h / 3
    return ans

module.exports = methods
