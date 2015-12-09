require "checkapi/version"
require 'optparse'
require 'pathname'

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

       if File.exist? "CheckApiResult.txt" 
         system 'rm CheckApiResult.txt'
       end
       system "ag -C 200 \"#{regex}\" --heading --nonumbers > CheckApiResult.txt"

       puts "open CheckApiResult.txt to view result!"

      else

        file_name = options[:filename]
        if file_name 
         if File.exist? "CheckApiResult.txt" 
           system 'rm CheckApiResult.txt'
         end
         result_path = "#{Pathname.pwd}/CheckApiResult.txt"
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
        end

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

