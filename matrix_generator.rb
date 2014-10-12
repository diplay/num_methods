#!/usr/bin/ruby
#coding: utf-8

require 'matrix'

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

def gen_matrix(n, symm, min, max)
  a = Matrix.build(n) do |i, j|
    rand(min .. max)
  end
  a.each_with_index(:strict_lower) { |el, i, j| a[i, j] = a[j, i] } if symm
  return a.row_vectors
end

def print_help
  help = "Параметры:
  symm
    Сгенерирует симметричную матрицу
  min=число (по умолчанию 0.0)
    Задает минимально возможное значение элемента матрицы
  max=число (по умолчанию 10.0)
    Задает максимально возможное значение элемента матрицы
  Если параметры min и max были целыми, то элементы матрицы тоже будут целыми
  delimiter=символ
    Задает разделитель для csv, по умолчанию прибел"
  puts help
end

if ARGV.include?('help')
  print_help
  exit 0
end

$symm = false
$n = 3
$delimiter = ' '
$min = 0.0
$max = 10.0

ARGV.each do |arg|
  case arg
  when /^n=(\d+)$/
    $n = $1
  when 'symm'
    $symm = true
  when /^delimiter=(.)$/
    $delimiter = $1
  when /^min=([\d]+)$/
    $min = $1.to_i
  when /^min=([\d\.]+)$/
    $min = $1.to_f
  when /^max=([\d]+)$/
    $max = $1.to_i
  when /^max=([\d\.]+)$/
    $max = $1.to_f
  end
end

gen_matrix($n, $symm, $min, $max).each { |vec| puts vec.to_a.join($delimiter) }
