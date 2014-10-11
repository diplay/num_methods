#!/usr/bin/ruby
#coding: utf-8

require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

def proj(v1, v2)
  v1.inner_product(v2) / v2.inner_product(v2)
end

def qr(v)
  u = [v.row(0)]
  e = [u[0] / u[0].norm]
  (1..v.row_size-1).each do |i|
    projAcc = Vector.elements(Array.new(v.row(0).size, 0))
    (0..i-1).each do |j|
      projAcc += proj(v.row(i), e[j])*e[j]
    end
    u.push(v.row(i) - projAcc)
    e.push(u[i] / u[i].norm)
  end
  r = Matrix.build v.row_size do |i, j|
    i >= j ? e[j].inner_product(v.row(i)) : 0
  end
  r = r.transpose
  q = Matrix.rows(e.collect {|vec| vec.to_a}).transpose
  return q, r
end

a = Matrix[[4, 2, 1],
          [2, 5, 3],
          [1, 3, 6]]

eps = 1e-8
error = 2*eps

while error >= eps do
  q, r = qr(a)
  a = r*q
  error = 0
  a.each_with_index :strict_lower do |el, i, j|
    error = el.abs if error < el.abs
    a[i, j] = 0 if el < eps
  end
end

a.each(:diagonal) { |el| p el}

