express = require('express')

app = express()
app.engine('html', require('ejs').renderFile)

app.use(express.static(__dirname + '/public'))

solve = (f, a, b) ->
  `f = new Function("x", "return " + f)`
  return f(b)
  

app.get('/', (req, res) ->

    res.render('index.html')
)

app.get('/solve', (req, res) ->
  ans = solve(req.param('f'),
    parseInt(req.param('from')),
    parseInt(req.param('to'))
  )
  res.send({"ans": ans})
)

app.listen(3000, '127.0.0.1')
