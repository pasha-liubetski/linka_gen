#!/usr/bin/env ruby

src_dir = 'src'

puts 'cards:'

names = Dir.glob("#{src_dir}/*png").map{ |str| str.gsub src_dir, '' }.map{ |str| str.gsub /\/|.png$/,'' }

names.each do |name|
  puts "  - title: #{name.upcase}"
  puts "    png: #{name}.png"
end
