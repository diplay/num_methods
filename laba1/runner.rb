#!/usr/bin/ruby
#coding: utf-8

mat_cnt = 100
mat_n = 3
eps = 1e-5
mat_n_from = nil

ARGV.each do |arg|
  case arg
  when /^n=(\d+)$/
    mat_n = $1.to_i
  when /^eps=([\d\.e\-]+)$/
    eps = $1.to_f
  when /^cnt=(\d+)$/
    mat_cnt = $1.to_i
  when /^from-n=(\d+)$/
    mat_n_from = $1.to_i
  end
end

mat_n_from ||= mat_n

puts 'Генерация матриц'
`echo -ne "" > jacobi.csv`
`echo -ne "" > qr.csv`
(mat_n_from..mat_n).each do |n|
  `echo -ne "" > matrices#{n}.csv`
  (1..mat_cnt).each do |i|
    `./matrix_generator.rb n=#{n} symm >> matrices#{n}.csv`
  end
end

def run_tests(method, n, mat_cnt, eps, mat_n)
  start_time = Time.now
  sum = []
  (1..mat_cnt).each do |i|
    iter = `cat matrices#{n}.csv | awk 'NR >= #{n*(i-1) + 1} && NR <= #{n*i}' | ./laba1.rb eps=#{eps} method=#{method} output=only-iterations`
    sum << iter.to_i
  end
  finish_time = Time.now
  time = finish_time - start_time
  time /= mat_cnt
  time *= 1000
  avr = sum.reduce(:+) / mat_cnt
  disp = sum.reduce {|disp, el| (el - avr)*(el - avr)} / (mat_n - 1)
  puts "Среднее количество итераций: #{avr}"
  puts "Дисперсия количества итераций: #{disp}"
  puts "Среднее время работы: #{time} ms"
  `echo "#{n} #{time} #{avr} #{disp}" >> #{method}.csv`
end

(mat_n_from..mat_n).each do |n|
  puts "Запуск тестов метода Якоби для n=#{n}"
  run_tests('jacobi', n, mat_cnt, eps, mat_n)
end

(mat_n_from..mat_n).each do |n|
  puts "Запуск тестов метода QR для n=#{n}"
  run_tests('qr', n, mat_cnt, eps, mat_n)
end

`./plot.rb file=qr.csv method=QR`
`./plot.rb file=jacobi.csv method=Якоби`
