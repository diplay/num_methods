#!/usr/bin/ruby
#coding: utf-8

require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

def sign(a)
  if a >= 0
    return 1
  else
    return -1
  end
end

def qr_householder(a)
  n = a.row_size
  q = Matrix.identity(n)
  (0...n-1).each do |i|
    sum = 0
    a.column(i).each_with_index {|el, k| sum += el*el if k >= i}
    beta = sign(-a[i, i])*Math::sqrt(sum)
    w = Matrix.build n, 1 do |j, k|
      if j < i
        0
      elsif j == i
        a[i, i] + beta
      else
        a[j, i]
      end
    end
    #mu = 1/(Math::sqrt(2*beta*beta - 2*beta*a[i, i]))
    sum = 0
    w.column(0).each {|el| sum += el*el}
    mu = 1 / Math::sqrt(sum)
    w = w*mu
    h = Matrix.identity(n) - 2*w*w.transpose
    q = h*q
    a = h*a
  end
  q = q.transpose
  return q, a
end

a = Matrix[[12, -51, 4],
           [6, 167, -68],
           [-4, 24, -41]]
#a = Matrix[[9.428571428571429, 1.3997084244475304, 0.0],
#           [1.3997084244475309, -0.4285714285714287, 1.1102230246251565e-16],
#           [0, 0, -3.875101402201047e-17]]
a = Matrix[[25.000000000000007, -11.040000000000013, 9.280000000000003],
           [-95.00000000000001, 146.00000000000003, -71.99999999999997],
           [-10.00000000000002, -5.9999999999999645, -33.000000000000014]]
q, r = qr_householder(a)
p q*r
p r*q
