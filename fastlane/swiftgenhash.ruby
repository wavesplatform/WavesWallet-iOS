#!/usr/bin/env ruby
#
require 'digest'
require 'json'
require 'find'

class Main

    def check(project_name, resources_path, lock_path) 
        
        tmp_name_file = "SwiftGen." + project_name + ".tmp.lock"
        lock_name_file = "SwiftGen." + project_name + ".lock"

        tmp_path_file = lock_path + "/" + tmp_name_file
        lock_path_file = lock_path + "/" + lock_name_file

        storyboards_file_paths = Find.find(resources_path).select { |p| /.*\.storyboard$/ =~ p }
        assets_file_paths = Find.find(resources_path).select { |p| /.*\.xcassets$/ =~ p }
        strings_file_paths = Find.find(resources_path).select { |p| /.*\.strings$/ =~ p }

        storyboards_map = Hash.new
        storyboards_file_paths.each do |storyboard|
            sha512 = Digest::SHA512.file storyboard
            storyboards_map[storyboard.split('/').last] = sha512
        end

        assets_map = Hash.new
        assets_file_paths.each do |asset_file_paths|

            files = Find.find(asset_file_paths).select { |p| /.*\.json$/ =~ p }
            asset_map = Hash.new
                
            files.each do |img_file|
                sha512 = Digest::SHA512.file img_file
                asset_map[img_file.split('/').last] = sha512
            end

            assets_map[asset_file_paths.split('/').last] = asset_map
        end

        strings_map = Hash.new
        strings_file_paths.each do |string|
            sha512 = Digest::SHA512.file string
            strings_map[string.split('/').last] = sha512
        end

        json_map = Hash.new
        json_map["storyboards"] = storyboards_map
        json_map["assets"] = assets_map
        json_map["strings"] = strings_map

        File.write(tmp_path_file, json_map.to_json)
        new_hash = Digest::SHA512.file tmp_path_file    
        File.delete(tmp_path_file)

        old_hash = ""
        if File.file?("./#{lock_path_file}")        
            old_hash = Digest::SHA512.file "./#{lock_path_file}"  
        end

        
        if old_hash != new_hash 
            old_hash = new_hash
            File.write(lock_path_file, json_map.to_json)    
            puts true
        else 
            puts false
        end
    end
end

return Main.new.check(ARGV[0], ARGV[1], ARGV[2])