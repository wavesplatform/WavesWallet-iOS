#!/usr/bin/env ruby
#
require 'digest'
require 'json'
require 'find'
require 'fileutils'

class Main

    def api

        protos_file_paths = Find.find("api-specs").select { |p| /.*\.proto$/ =~ p }
        
        protos_map = Hash.new
        protos_file_paths.each do |protos|
            sha512 = Digest::SHA512.file protos
            protos_map[protos.split('/').last] = sha512
        end
        
        # tmp_name_file = "#{__dir__}/Protos." + ".tmp.lock"
        # lock_name_file = "#{__dir__}/Protos." + ".lock"


        # json_map = Hash.new
        # json_map["protos"] = protos_map
        

        # File.write(tmp_path_file, json_map.to_json)
        # new_hash = Digest::SHA512.file tmp_path_file    
        # File.delete(tmp_path_file)

        # # print tmp_path_file
        # old_hash = ""
        # if File.file?("#{lock_path_file}")        
        #     old_hash = Digest::SHA512.file "#{lock_path_file}"  
        # end

        
        # if old_hash != new_hash 
        #     old_hash = new_hash
        #     File.write(lock_path_file, json_map.to_json)    
        #     # return true
        # else 
        #     # return false
        # end


        unless File.directory?("#{__dir__}/Sources")
            FileUtils.rm_rf("#{__dir__}/Sources")
        end

        protos_file_paths.each do |protos|
            
            absolute_path = File.dirname(protos)
                        
            file_name = protos.split('/').last

            file_path = "#{__dir__}/#{absolute_path}"
            swift_out = "#{__dir__}/Sources/#{absolute_path}"
        
            unless File.directory?(swift_out)
                FileUtils.mkdir_p(swift_out)
            end

            puts("SCRIIIPT54")
            puts(swift_out)
            puts(file_path)
            puts(file_name)

            puts `protoc  --swift_opt=Visibility=Public --swift_out=#{swift_out} --proto_path #{file_path} #{file_name}`            
        end    
    end


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
            keys = string.split('/')[-2] + "/" + string.split('/').last
            sha512 = Digest::SHA512.file string
            strings_map[keys] = sha512
        end
        
        json_map = Hash.new
        json_map["storyboards"] = storyboards_map
        json_map["assets"] = assets_map
        json_map["strings"] = strings_map

        File.write(tmp_path_file, json_map.to_json)
        new_hash = Digest::SHA512.file tmp_path_file    
        File.delete(tmp_path_file)

        # print tmp_path_file
        old_hash = ""
        if File.file?("#{lock_path_file}")        
            old_hash = Digest::SHA512.file "#{lock_path_file}"  
        end

        
        if old_hash != new_hash 
            old_hash = new_hash
            File.write(lock_path_file, json_map.to_json)    
            return true
        else 
            return false
        end
    end
end

Main.new.api()

