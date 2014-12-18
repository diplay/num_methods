express = require('express')
methods = require('./methods')

app = express()
app.engine('html', require('ejs').renderFile)

app.use(express.static(__dirname + '/public'))

prepare_f = (f) ->
  f.replace( /Math./gi, "")
    .replace /(exp|log|pow|sin|cos|tan|sqrt|abs|acos|asin|atan)/g, (match) ->
      "Math." + match

solve = (f, a, b, n, method) ->
  if f == ""
    return "f(x) is empty"
  f = prepare_f f
  f = new Function("x", "return " + f)
  if method == "1"
    console.log("trap")
    methods.trap(f, a, b, n)
  else
    console.log("simpson")
    methods.simpson(f, a, b, n)

plot = (f, a, b, n_min, n_max) ->
  f = prepare_f f
  console.log f
  f = new Function("x", "return " + f)
  ans_trap = [n_min..n_max].map (n) -> [n, methods.trap(f, a, b, n)]
  ans_simpson = [n_min..n_max].map (n) -> [n, methods.simpson(f, a, b, n)]
  return {"ans_trap": ans_trap, "ans_simpson": ans_simpson}

app.get('/solve', (req, res) ->
  ans = solve(req.param('f'),
    parseFloat(req.param('from')),
    parseFloat(req.param('to')),
    parseFloat(req.param('n')),
    req.param('method')
  )
  res.send({"ans": ans})
)

app.get('/plot', (req, res) ->
  ans = plot(req.param('f'),
    parseFloat(req.param('from')),
    parseFloat(req.param('to')),
    parseInt(req.param('n_min', 1)),
    parseInt(req.param('n_max', 1000))
  )
  res.send({"ans" : ans})
)

app.listen(3000)
