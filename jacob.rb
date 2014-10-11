#!/usr/bin/ruby
#coding: utf-8

require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

def jacobi(a, eps)
  t = Matrix.identity(a.row_size)

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
  return a.row_size.times.collect { |i| a[i, i] }, t.column_vectors
end

$silent = true if ARGV.include?('silent')

def init_sample
  a = Matrix[[4, 2, 1],
             [2, 5, 3],
             [1, 3, 6]]
  eps = 1e-8

  puts "Матрица:" unless $silent
  p a.row(0).to_a
  p a.row(1).to_a
  p a.row(2).to_a
  puts "eps = #{eps}" unless $silent
  return a, eps
end

def init_interactive
  delimiter = ' '
  print "Введите размер квадратной матрицы: " unless $silent
  n = STDIN.gets.to_i
  vectors = []
  n.times do
    print "Введите строку матрицы: " unless $silent
    vector = STDIN.gets
    vector.sub!(' ', '') if delimiter != ' '
    vector = vector.split(delimiter).collect {|val| val.to_f }
    vectors.push(vector)
  end
  print "Введите допустимую погрешность: " unless $silent
  eps = STDIN.gets.to_f
  return Matrix.rows(vectors), eps
end

if ARGV.include?('sample')
  a, eps = init_sample
elsif ARGV.include?('stdin')
  a, eps = init_interactive
else
  STDERR.puts "Не выбран режим, по умолчанию используется stdin" unless $silent
  a, eps = init_interactive
end

ans, t_ans = jacobi(a, eps)

puts "Собственные значения:" unless $silent
puts ans
puts "Собственные векторы:" unless $silent
puts t_ans
