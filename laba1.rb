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

def qr_method(a, eps)
  error = 2*eps
  regular = true

  unless a.regular?
    puts "Матрица вырожденная, ответ может быть неправильным" unless $silent
    regular = false
  end
  while error >= eps do
    q, r = qr(a)
    a = r*q
    error = 0
    a.each_with_index :strict_lower do |el, i, j|
      error = el.abs if error < el.abs
      a[i, j] = 0 if el < eps
    end
  end

  ans = []
  a.each(:diagonal) { |el| ans.push(el)}
  return ans, regular
end

def jacobi_method(a, eps)
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
  return a
end

def enter_row
  print "Введите строку матрицы: " unless $silent
  vector = STDIN.gets
  vector.sub!(' ', '') if $delimiter != ' '
  vector = vector.split($delimiter).collect {|val| val.to_f }
end

def init_interactive
  vectors = []
  vectors.push(enter_row)
  (vectors[0].size - 1).times { vectors.push(enter_row) }
  puts "Допустимая погрешность: #{$eps}" unless $silent
  return Matrix.rows(vectors)
end

def print_help
  help = "Параметры:
  input=sample|csv
    Задает способ ввода данных, sample - прогоняется образец, не требует ввода
                                csv - вводится матрица построчно, элементы разделяются разделителем
  output=csv|json
    Задает формат выходных данных
  method=jacobi|qr|test
    Задает используемый метод решения задачи, test использует алгоритм из стандартной библиотеки
  silent
    Отключает лишний вывод, остается только ответ задачи
  eps=число
    Задает погрешность, по умолчанию 1e-8
  delimiter=символ
    Задает разделитель для csv, по умолчанию прибел"
  puts help
end

if ARGV.include?('help')
  print_help
  exit 0
end

$delimiter = ' '
$method = 'jacobi'
$input = 'default'
$output = 'csv'
$eps = 1e-8

ARGV.each do |arg|
  case arg
  when /^input=(.+)$/
    $input = $1
  when 'silent'
    $silent = true
  when /^delimiter=(.)$/
    $delimiter = $1
  when /^method=(.+)$/
    $method = $1
  when /^output=(.+)$/
    $output = $1
    $silent = true if $output != 'csv'
  when /^eps=([\d\.e\-]+)$/
    $eps = $1.to_f
  end
end

case $input
when 'sample'
  a = init_sample
when 'csv'
  a = init_interactive
else
  a = init_interactive
end

if $method == 'jacobi'
  ans, t_ans = jacobi_method(a, $eps)
  case $output
  when 'csv'
    puts "Собственные значения:" unless $silent
    puts ans.join($delimiter)
    puts "Собственные векторы:" unless $silent
    t_ans.each {|vec| puts vec.to_a.join($delimiter) }
  when 'json'
    $ans_json = "{matrix: [#{a.row_vectors.collect {|vec| '[' + vec.to_a.join(',') + ']' }.join(',') }], eigenvalues : [#{ans.join(',')}], eigenvectors : [#{t_ans.collect {|vec| '[' + vec.to_a.join(',') + ']' }.join(',') }] }"
    print $ans_json
  end
elsif $method == 'qr'
  ans, regular = qr_method(a, $eps)
  case $output
  when 'csv'
    puts "Собственные значения:" unless $silent
    puts ans
  when 'json'
    $ans_json = "{matrix: [#{a.row_vectors.collect {|vec| '[' + vec.to_a.join(',') + ']' }.join(',') }], eigenvalues : [#{ans.join(',')}], matrix_regular : #{regular} }"
    print $ans_json
  end
elsif $method == 'test'
  v, d, t_ans = a.eigensystem
  t_ans = t_ans.row_vectors
  ans = d.row_size.times.collect { |i| d[i, i] }
  case $output
  when 'csv'
    puts "Собственные значения:" unless $silent
    puts ans.join($delimiter)
    puts "Собственные векторы:" unless $silent
    t_ans.each {|vec| puts vec.to_a.join($delimiter) }
  when 'json'
    $ans_json = "{matrix: [#{a.row_vectors.collect {|vec| '[' + vec.to_a.join(',') + ']' }.join(',') }], eigenvalues : [#{ans.join(',')}], eigenvectors : [#{t_ans.collect {|vec| '[' + vec.to_a.join(',') + ']' }.join(',') }] }"
    print $ans_json
  end
else
  STDERR.puts "Параметр method указан неверно, используйте help"
end
