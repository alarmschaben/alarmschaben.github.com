#!/usr/bin/ruby

require 'find'

if ARGV.length == 0
  puts "Usage: #{$0} <directory to scan>"
  exit(1)
end

if FileTest.directory?ARGV[0]
  path = ARGV[0]
else
  puts "#{ARGV[0]} is not a directory."
  exit(2)
end

# array declarations
mediafiles = Array.new
extensions = Array.new
extensiontypes = Hash.new(0)
validextensions = [ "avi", "vob", "mkv", "mpg" ]
filestobescanned = Array.new

# traverse top-level directory and put each file into an array
Find.find(path) do |p|
  if FileTest.directory?(p)
    next
  end
  mediafiles << p
end

# sanitizing: this does two things...
mediafiles.each do |m|
  filenameparts=m.split(/\./)
  extension = filenameparts.last.downcase
  # ...if the file's extension is included in out valid filenames list,
  # the file gets on the list of files to be processed further.
  if validextensions.include?(extension)
    filestobescanned << m
  end
  # ..and in any other case (given it's actually a proper extension),
  # the file type is counted
  if filenameparts.last.length < 5
    extensions << extension
    extensiontypes[extension] += 1
  end
end

# output an overview over relevant file types and their distribution
extensiontypes.sort { |x,y| y[1] <=> x[1]}.each do |e,c|
  if c > 6
    puts "#{e} #{c}"
  end
end

#puts filestobescanned
