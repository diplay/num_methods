#!/usr/bin/ruby
#coding: utf-8

mat_cnt = 100
mat_n = 3
eps = 1e-5
mat_n_from = nil
delimiter = ' '

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
  when /^delimiter=(.)$/
    delimiter = $1
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

(mat_n_from..mat_n).each do |n|
  puts "Запуск тестов метода Якоби для n=#{n}"
  start_time = Time.now
  sum = 0
  (1..mat_cnt).each do |i|
    iter = `cat matrices#{n}.csv | awk 'NR >= #{n*(i-1) + 1} && NR <= #{n*i}' | ./laba1.rb eps=#{eps} output=only-iterations`
    sum += iter.to_i
    `echo "#{n}#{delimiter}#{eps}#{delimiter}#{iter}" >> jacobi.csv`
  end
  finish_time = Time.now
  time = finish_time - start_time
  sum /= mat_cnt
  time /= mat_cnt
  time *= 1000
  puts "Среднее количество итераций: #{sum}"
  puts "Среднее время работы: #{time} ms"
end

(mat_n_from..mat_n).each do |n|
  puts "Запуск тестов метода QR для n=#{n}"
  start_time = Time.now
  sum = 0
  (1..mat_cnt).each do |i|
    iter = `cat matrices#{n}.csv | awk 'NR >= #{n*(i-1) + 1} && NR <= #{n*i}' | ./laba1.rb method=qr eps=#{eps} output=only-iterations`
    sum += iter.to_i
    `echo "#{n}#{delimiter}#{eps}#{delimiter}#{iter}" >> qr.csv`
  end
  finish_time = Time.now
  time = finish_time - start_time
  sum /= mat_cnt
  time /= mat_cnt
  time *= 1000
  puts "Среднее количество итераций: #{sum}"
  puts "Среднее время работы: #{time} ms"
end
