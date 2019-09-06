require 'csv'
require 'json'
require 'benchmark'


class Array
  def sum
    reduce(:+)
  end

  def mean
    return nil if size.zero?

    sum.to_f / size
  end

  def var
    return nil if (size - 1).zero?

    m = mean
    reduce(0) { |a,b| a + (b - m) ** 2 } / (size - 1)
  end

  def sd
    Math.sqrt(var)
  end
end


module Analyses

  @@method_info = {}
  @@output = {}
  @@wrapped_names = []

  def self.included(base)
    base.class_eval do
      # in included class
      def self.method_added(name)
        wrapped_name = "#{name}__wrapped"

        return if @@method_info.key? name
        return if @@wrapped_names.include? name.to_s

        @@method_info[name] = {count: 0, time: []}
        @@wrapped_names.push(wrapped_name)

        puts "method \"#{name}\" was added"

        alias_method wrapped_name, name

        define_method name do |*args|
          @@method_info[name][:count] += 1
          rst = nil

          time = Benchmark.realtime do
            rst = self.send(wrapped_name, *args)
          end

          @@method_info[name][:time] << time
          @@output[name] = rst

          rst
        end
      end
    end
  end

  at_exit do
    CSV.open("#{Dir.home}/result.csv", 'w') do |csv|
      csv << %w[method count sum max min avg sd]

      @@method_info.each do |name, info|
        continue if name == 'db'
        time = info[:time]
        csv << [name, info[:count], time.sum, time.max, time.min, time.mean, time.sd]
      end
    end

    File.open("#{Dir.home}/output.json", 'w') do |file|
      output = @@output.reject { |name, out| name =~ /(GET|PUT|PATCH|UPDATE|DELETE|db).*/ }

      JSON.dump(output, file)
    end
  end
end
