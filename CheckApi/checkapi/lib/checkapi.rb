require "checkapi/version"
require 'optparse'
require 'pathname'
require 'net/http'
require 'uri'
require 'json'

module Checkapi
  # Your code goes here...
  def self.run
      options = {}
      option_parser = OptionParser.new do |opts|
        opts.banner = 'here is help messages of the command line tool.'

        opts.on('-f FILENAME', '--file FILENAME', 'file name') do |value|
          options[:filename] = value
        end

        opts.on('-k A,B', '--keyword A,B', Array, 'List of search keywords') do |value|
          options[:keywords] = value
        end

        opts.on('-p USERNAME', '--push USERNAME', 'push record to server') do |value|
          options[:push] = value
        end

      end.parse!


      keywords = options[:keywords]
      keywords ||= {}

      if keywords.count > 0
       if which("ag").nil?
         system("brew update")
         system("brew install ag")
       end
       regex = keywords[0]
       if keywords.count > 1

         keywords.each do |keyword|

          index = keywords.index keyword 
          if index == 0 
            regex = "#{keyword}"
          elsif
            regex += "[\\s\\S]*#{keyword}" 
          end
    
         end

       end

       if File.exist? "CheckApiResult.h" 
         system 'rm CheckApiResult.h'
       end
       system "ag -C 200 \"#{regex}\" --heading --nonumbers > CheckApiResult.h"

       puts "open CheckApiResult.h to view result!"

      else

        file_name = options[:filename]
        if file_name 
         if File.exist? "CheckApiResult.h" 
           system 'rm CheckApiResult.h'
         end
         result_path = "#{Pathname.pwd}/CheckApiResult.h"
         result_file = File.new(result_path , "w+")
         file_list_string = `find . -name *#{file_name}*` 
         file_list_string.each_line do |file_path|
           file_path = File.expand_path(file_path)
           file_path = file_path.strip
           if File.exist? file_path
             content = File.read(file_path)
             result_file << content 
             result_file << "\n\n"
           else
             puts "#{file_path}not exist!"
           end
         end
         result_file.close
         puts "open CheckApiResult.h to view result!"
        end

      end

      user_name = options[:push]
      if user_name
        params = {}
        api_result = {}
        api_result[:title] = options.to_s
        api_result[:content] = File.read("CheckApiResult.h")
        params[:api_result] = api_result
        params[:name] =  user_name
        uri = URI.parse("http://192.168.1.153:3000/api_results")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
        request.body = params.to_json
        response = http.request(request)
      end

  end

  

  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      }
    end
    return nil
  end
end

