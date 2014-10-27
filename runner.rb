#!/usr/bin/ruby
#coding: utf-8

require 'json'

mat_cnt = 100
mat_n = 3
eps = 1e-5

ARGV.each do |arg|
  case arg
  when /^n=(\d+)$/
    mat_n = $1.to_i
  when /^eps=([\d\.e\-]+)$/
    eps = $1.to_f
  when /^cnt=(\d+)$/
    mat_cnt = $1.to_i
  end
end

puts 'Генерация матриц'
`echo -ne "" > matrices.txt`
`echo -ne "" > jacobi.txt`
`echo -ne "" > qr.txt`
(1..mat_cnt).each do |i|
  `./matrix_generator.rb n=#{mat_n} symm >> matrices.txt`
end

puts 'Запуск тестов метода Якоби'
start_time = Time.now
sum = 0
(1..mat_cnt).each do |i|
  iter = `cat matrices.txt | awk 'NR >= #{mat_n*(i-1) + 1} && NR <= #{mat_n*i}' | ./laba1.rb eps=#{eps} output=only_iterations`
  sum += iter.to_i
  `echo "#{iter}" >> jacobi.txt`
end
finish_time = Time.now
time = finish_time - start_time
sum /= mat_cnt
time /= mat_cnt
time *= 1000
puts "Среднее количество итераций: #{sum}"
puts "Среднее время работы: #{time} ms"

puts 'Запуск тестов метода QR'
start_time = Time.now
sum = 0
(1..mat_cnt).each do |i|
  iter = `cat matrices.txt | awk 'NR >= #{mat_n*(i-1) + 1} && NR <= #{mat_n*i}' | ./laba1.rb method=qr eps=#{eps} output=only_iterations`
  sum += iter.to_i
  `echo "#{iter}" >> qr.txt`
end
finish_time = Time.now
time = finish_time - start_time
sum /= mat_cnt
time /= mat_cnt
time *= 1000
puts "Среднее количество итераций: #{sum}"
puts "Среднее время работы: #{time} ms"
