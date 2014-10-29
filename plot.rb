#!/usr/bin/ruby
#coding: utf-8

require 'gnuplot'

def plot_file(filename, method)
  data = []
  File.foreach(filename) do |line|
    data << line.split(' ').each_with_index.collect {|el, index| index == 1 ? el.to_f : el.to_i}
  end

  n = data.collect{ |el| el[0] }
  iter = data.collect{ |el| el[2] }
  time = data.collect{ |el| el[1] }
  err = data.collect { |el| Math::sqrt(el[3]) }

  Gnuplot.open do |gp|
    Gnuplot::Plot.new(gp) do |plot|
      plot.terminal 'pdf'
      plot.grid 'xtics ytics mytics mytics'
      plot.output "#{method}.pdf"
      plot.title "Метод #{method}"
      plot.encoding 'utf8'
      plot.xrange "[1:#{data.last[0] + 1}]"
      plot.xlabel "Размерность"
      plot.ylabel "Итерации"
      plot.data << Gnuplot::DataSet.new([n, iter, err]) do |ds|
        ds.with = 'errorb'
        ds.notitle
      end
      plot.data << Gnuplot::DataSet.new([n, iter]) do |ds|
        ds.with = 'lines'
        ds.linewidth = 2
        ds.title = "Среднее число итераций"
      end
    end

    Gnuplot::Plot.new(gp) do |plot|
      plot.title "Среднее время работы, метод #{method}"
      plot.xrange "[1:#{data.last[0] + 1}]"
      plot.xlabel "Размерность"
      plot.ylabel "Время работы, мс"
      plot.data << Gnuplot::DataSet.new([n, time]) do |ds|
        ds.with = 'lines'
        ds.linewidth = 2
        ds.title = "Среднее время работы"
      end
    end
  end

end

filename = nil
method = 'undefined'

ARGV.each do |arg|
  case arg
  when /^method=(.+)$/
    method = $1
  when /^file=(.+)$/
    filename = $1
  end
end

plot_file(filename, method)
