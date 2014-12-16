express = require('express')
methods = require('./methods')

app = express()
app.engine('html', require('ejs').renderFile)

app.use(express.static(__dirname + '/public'))

solve = (f, a, b, n, method) ->
  `f = new Function("x", "return " + f)`
  if method == "1"
    console.log("trap")
    return methods.trap(f, a, b, n)
  else
    console.log("simpson")
    return methods.simpson(f, a, b, n)

app.get('/', (req, res) ->

    res.render('index.ntml')
)

app.get('/solve', (req, res) ->
  ans = solve(req.param('f'),
    parseFloat(req.param('from')),
    parseFloat(req.param('to')),
    parseFloat(req.param('n')),
    req.param('method')
  )
  res.send({"ans": ans})
)

app.listen(3000, '127.0.0.1')
