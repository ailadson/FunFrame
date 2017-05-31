require 'fileutils'

funframe_dir = "#{File.expand_path(File.dirname(__FILE__))}/app"
project_dir = "#{Dir.pwd}/#{ARGV[0]}"

FileUtils.copy_entry funframe_dir, project_dir
