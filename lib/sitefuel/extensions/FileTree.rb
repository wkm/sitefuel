#
# File::      FileTree.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# A FileTree is a generator designed to very quickly create large directory
# and file structures.
#

class FileTree

  def initialize(base_path = :automatic)
    if base_path == :automatic
      @base_path = Dir.pwd
    else
      @base_path = base_path
    end

    refresh_tree
  end

  def refresh_tree
    @directory_hash = {}
    @file_hash = {}

    top_level_contents = Dir["#{@base_path}/*"]

    top_level_contents.each do |handle|
      if File.directory?(handle)
        @directory_hash[handle] = FileTree.new(handle)
      else
        @file_hash[handle] = true
      end
    end
  end


  # gives true if the directory exists at this level of the FileTree
  def has_directory?(name)
    @directory_hash[name] == nil
  end


  # creates the given directory if it doesn't exist and returns a
  # FileTree for it
  def create_directory(name)
    res = @directory_hash[name]
    if res != nil
      return res
    else
      full_name = File.join(@base_path, name)
      Dir.mkdir(full_name)
      @directory_hash[name] = FileTree.new(full_name)
    end
  end


  # creates the file at this level of the file tree if it doesn't exist
  def create_file(name)
    full_name = File.join(@base_path, name)
    if File.exists?(full_name)
      return full_name
    else
      File.new(full_name)
    end         
  end


  # finds the file and creates it (and all the necessary directories) if it
  # doesn't already exist and gives back the filename
  def get_file(name)
    components = File.split(name)
    tld = self

    index = 0
    components.each do |part|
      if index < components.length-1
        tld = tld.create_directory(part)
      else
        tld = tld.create_file(part)
      end
    end
  end
end