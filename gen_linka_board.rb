#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'yaml'

output_zip = 'example.linka'
output_dir = 'out_dir'
src_dir = 'src'

rhvoice_voice = 'anna'

def get_card_hash(card_hash, card_id = 0)
  wav_file = card_hash['png'].gsub(/\.png$/,'.wav')

  card_template_hash = {
    id: card_id,
    title: card_hash['title'],
    imagePath: card_hash['png'],
    audioPath: wav_file,
    cardType: 0
  }
  
  card_template_hash
end

puts "Reading config.yaml..."

config_yaml_src = YAML::load_file("#{src_dir}/config.yaml")

config_header = config_yaml_src.except('cards')
config_cards = config_yaml_src['cards']

puts "Parsing cards description..."

i = 0

cards = config_cards.map do |card_name|
  out = get_card_hash(card_name, i)

  i += 1
  
  out
end

config = config_header.merge({ 'cards' => cards })

puts "Deleting old #{output_dir}..."

FileUtils.rm output_zip, :force => true
FileUtils.rm_r output_dir, :force => true
FileUtils.mkdir output_dir

puts "Writing config.json..."

File.open("#{output_dir}/config.json", 'w') do |f|
  f.puts JSON.pretty_generate config
end

puts "Creating .wav files via RHVoice..."

cards.each do |card|
  str = card[:title]
  out_wav = card[:audioPath]

  rhvoice_cmdline="echo #{str} | RHVoice-test -R 44100 -p #{rhvoice_voice} -o '#{output_dir}/#{out_wav}'"

  puts rhvoice_cmdline
  system rhvoice_cmdline
end

puts "Copying png files..."

FileUtils.cp Dir.glob("#{src_dir}/*png"), output_dir

puts "Creating .zip file..."

FileUtils.rm output_zip, :force => true

FileUtils.cd(output_dir) do
  system "zip ../#{output_zip} *"
end
