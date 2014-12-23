finiteDifference = (f, xk, xk1, yk, yk1, m) ->
  if m == 1
    f(xk1, yk1) - f(xk, yk)
  else
    finiteDifference(f, xk, xk1, yk, yk1, m-1)

startValues = (f, a, b, ya, za, n) ->
  g = (x, y, z) -> z
  h = (a - b) / n
  x = a
  y = ya
  z = za
  ans = [[x, y]]
  [0...2].forEach (i) ->
    k1 = h * f(x, y, z)
    q1 = h * g(z, y, z)

    k2 = h * f(x + h/2, y + q1/2, z + k1/2)
    q2 = h * g(x + h/2, y + q1/2, z + k1/2)

    k3 = h * f(x + h/2, y + q2/2, z + k2/2)
    q3 = h * g(x + h/2, y + q2/2, z + k2/2)

    k4 = h * f(x + h, y + q3, z + k3)
    q4 = h * g(x + h, y + q3, z + k3)

    z = z + (k1 + 2*k2 + 2*k3 + k4)/6
    y = y + (q1 + 2*q2 + 2*q3 + q4)/6
    x = x + h
    ans.push [x, y]
  ans.reverse()

methods =

  explicit: (f, a, b, ya, derya, n) ->
    h = (b - a) / n
    y = startValues(f, a, b, ya, derya, n)

    console.log y

    p = (i) ->
      f(a + h*i, y[i + 2][1]) +
        finiteDifference(f, a + h*(i-2), a + h*(i-1), y[i-2 + 2][1], y[i-1 + 2][1], 2) / 12

    [0...n].forEach (i) ->
      y.push([a + h*(i+1), 2*y[i + 2][1] - y[i-1 + 2][1] + (h*h)*p(i)])
    console.log y
    return y[2..(n+2)]

  implicit: (f, a, b, ya, derya, n) ->
    return [[a, 0]]

module.exports = methods
