#!/usr/bin/env ruby
#
require 'digest'
require 'json'
require 'find'

storyboards_pdf_paths = []
root_folder = "."
tmp_name_file = "SwiftGen.tmp.lock"
lock_name_file = "SwiftGen.lock"

storyboards_file_paths = Find.find(root_folder).select { |p| /.*\.storyboard$/ =~ p }
assets_file_paths = Find.find(root_folder).select { |p| /.*\.xcassets$/ =~ p }
strings_file_paths = Find.find(root_folder).select { |p| /.*\.strings$/ =~ p }

storyboards_map = Hash.new
storyboards_file_paths.each do |storyboard|
    sha512 = Digest::SHA512.file storyboard
    storyboards_map[storyboard] = sha512
end

assets_map = Hash.new
assets_file_paths.each do |asset_file_paths|

    files = Find.find(asset_file_paths).select { |p| /.*\.json$/ =~ p }
    asset_map = Hash.new
        
    files.each do |img_file|
        sha512 = Digest::SHA512.file img_file
        asset_map[img_file] = sha512
    end

    assets_map[asset_file_paths] = asset_map
end

strings_map = Hash.new
strings_file_paths.each do |string|
    sha512 = Digest::SHA512.file string
    strings_map[string] = sha512
end

json_map = Hash.new
json_map["storyboards"] = storyboards_map
json_map["assets"] = assets_map
json_map["strings"] = strings_map

File.write(tmp_name_file, json_map.to_json)
new_hash = Digest::SHA512.file tmp_name_file    
File.delete(tmp_name_file)

old_hash = ""
if File.file?("./#{lock_name_file}")        
    old_hash = Digest::SHA512.file "./#{lock_name_file}"  
end

if old_hash != new_hash 
    old_hash = new_hash
    File.write(lock_name_file, json_map.to_json)    
    puts true
else 
    puts false
end