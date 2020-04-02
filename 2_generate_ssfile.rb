#!/usr/bin/env ruby

require "pp"
require "open3"

if ARGV.length != 1 then
  STDERR.puts "Usage: #{$0} dir_to_be_processed"
  exit(-1)
end
dirfilename = "#{ARGV[0]}/files_to_be_processed.txt"

######################################
####  read filename from dirfile  #### 
if (File.exist?(dirfilename))
  begin 
    dirfile = File.new(dirfilename, "r")    
  rescue
    STDERR.print "Could not open file #{dirfilename}!\n"
    exit 1
  end
else
  STDERR.print "File #{dirfilename} does not exist!\n"
  exit 1
end

dirdata = dirfile.readlines() 
dirdata.each do |seqfilename|
    seqfilename.strip!
    rootname=seqfilename.split(".")[0]
    kinfilename="#{ARGV[0]}/#{rootname}.kin"

    if (File.exist?(kinfilename))
      begin
        kinfile = File.new(kinfilename, "r")
      rescue
        STDERR.print "Could not open file #{kinfilename}!\n"
        exit 1
      end
    else
      STDERR.print "File #{kinfilename} does not exist!\n"
      exit 1
    end

    
    ss_array = []
    #seq = ""
    kindata = kinfile.readlines() 
    kindata.each do |line|
      line.strip!
      line_data = line.split(%r{\s+})
      
      if line_data.length != 1 then
        ss_array << line_data[1]
      elsif line_data.length == 1 then
        #seq = line_data[0]
      end
    end

    i=0
    ss_array.each do|ss1|
      j=0
      ss_array.each do|ss2| 
	puts "writing #{ARGV[0]}/#{rootname}.ssfiles/#{i}_#{j}.ss"
	directory_name = "#{ARGV[0]}/#{rootname}.ssfiles"
	Dir.mkdir(directory_name) unless File.exists?(directory_name)
	begin
	  ssfile = File.new("#{ARGV[0]}/#{rootname}.ssfiles/#{i}_#{j}.ss", "w")
	rescue
	  STDERR.print "Could not open file #{ARGV[0]}/#{rootname}.ssfiles (Does it exist?)\n"
	  exit 1
	end
	ssfile.puts(ss_array[i])
	ssfile.puts(ss_array[j])
	ssfile.close
	j=j+1
      end
      i=i+1
    end

end