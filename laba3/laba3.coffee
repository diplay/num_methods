express = require('express')
methods = require('./methods')

app = express()
app.engine('html', require('ejs').renderFile)

app.use(express.static(__dirname + '/public'))

prepare_f = (f) ->
  f.replace( /Math./gi, "")
    .replace /(exp|log|pow|sin|cos|tan|sqrt|abs|acos|asin|atan)/g, (match) ->
      "Math." + match

solve = (f, a, b, y0, dery0, n, method) ->
  if f == ""
    return "f(x) is empty"
  f = prepare_f f
  f = new Function("x", "y", "return " + f)
  if method == "1"
    console.log("explicit")
    methods.explicit(f, a, b, y0, dery0, n)
  else
    console.log("implicit")
    methods.implicit(f, a, b, y0, dery0, n)

#plot = (f, a, b, n_min, n_max) ->
#  f = prepare_f f
#  console.log f
#  f = new Function("x", "return " + f)
#  ans_explicit = [n_min..n_max].map (n) -> [n, methods.explicit(f, a, b, n)]
#  ans_implicit = [n_min..n_max].map (n) -> [n, methods.implicit(f, a, b, n)]
#  return {"ans_explicit": ans_explicit, "ans_implicit": ans_implicit}

app.get('/solve', (req, res) ->
  ans = solve(req.param('f'),
    parseFloat(req.param('from')),
    parseFloat(req.param('to')),
    parseFloat(req.param('y0')),
    parseFloat(req.param('dery0')),
    parseFloat(req.param('n')),
    req.param('method')
  )
  res.send({"ans": ans})
)

#app.get('/plot', (req, res) ->
#  ans = plot(req.param('f'),
#    parseFloat(req.param('from')),
#    parseFloat(req.param('to')),
#    parseInt(req.param('n_min', 1)),
#    parseInt(req.param('n_max', 1000))
#  )
#  res.send({"ans" : ans})
#)

app.listen(3000)
