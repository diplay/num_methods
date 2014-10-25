#!/usr/bin/ruby
#coding: utf-8

require 'json'

mat_cnt = 100
mat_n = 3
puts 'Генерация матриц'
`echo -ne "" > matrices.txt`
`echo -ne "" > jacobi.txt`
`echo -ne "" > qr.txt`
(1..mat_cnt).each do |i|
  `./matrix_generator.rb n=#{mat_n} symm >> matrices.txt`
end

puts 'Запуск тестов метода Якоби'
(1..mat_cnt).each do |i|
  iter = `cat matrices.txt | awk 'NR >= #{3*i-2} && NR <= #{3*i}' | ./laba1.rb output=json output=only_iterations`
  `echo "#{iter}" >> jacobi.txt`
end
puts 'Запуск тестов метода QR'
(1..mat_cnt).each do |i|
  iter = `cat matrices.txt | awk 'NR >= #{3*i-2} && NR <= #{3*i}' | ./laba1.rb method=qr output=json output=only_iterations`
  `echo "#{iter}" >> qr.txt`
end
