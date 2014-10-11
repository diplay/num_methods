#!/usr/bin/ruby
#coding: utf-8

require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

a = Matrix[[4, 2, 1],
          [2, 5, 3],
          [1, 3, 6]]

p a

eps = 1e-8

t = Matrix.identity(3)

until a.diagonal? do
  i = 0
  j = 1
  sigma = 0
  a.each_with_index :off_diagonal do |el, row, col|
    sigma += el*el
    if a[i, j].abs < el.abs
      i = row
      j = col
    end
  end
  sigma /= 2
  break if Math::sqrt(sigma) < eps
  tij = Matrix.identity(3)
  if a[i, i] == a[j, j]
    cosa = Math::cos(Math::PI / 4)
    sina = cosa
  else
    tg2a = 2*a[i, j] / (a[i, i] - a[j, j])
    cos2a = 1 / Math::sqrt(1 + tg2a*tg2a)
    cosa = Math::sqrt((1 + cos2a) / 2)
    sina = Math::sqrt((1 - cos2a) / 2)
    sina *= -1 if (a[i, j]*(a[i, i] - a[j, j]) < 0)
  end
  tij[i, i] = cosa
  tij[i, j] = - sina
  tij[j, i] = sina
  tij[j, j] = cosa
  a = tij.transpose * a * tij
  a[i, j] = a[j, i] = 0
  t = t * tij

end

p "Собственные значения:"
a.row_size.times.each { |i| p a[i, i] }
p "Собственные векторы:"
p t
