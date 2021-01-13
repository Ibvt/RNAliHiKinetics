#!/usr/bin/env ruby

=begin
prestep: convert stockholm to aln: http://www.ibi.vu.nl/programs/convertalignwww/
Step 1: RNAliHeliCes RF00500_seed.aln -k 100 > RF00500_seed.res
Step 2: 1_* 2_* 3_* 4_*
Step 3: replace [_] with [\_]
Step 4: gnuplot RF00500_seed.kin.plt; okular RF00500_seed.kin.ps
                RF00500_seed.plt; okular RF00500_seed.ps
                ./ShowTree -f RF00500_seed.tree.dat
=end

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
    alnfilename="#{ARGV[0]}/#{rootname}.aln"

    if (File.exist?(alnfilename))
      begin
        alnfile = File.new(alnfilename, "r")
      rescue
        STDERR.print "Could not open file #{alnfilename}!\n"
        exit 1
      end
    else
      STDERR.print "File #{alnfilename} does not exist!\n"
      exit 1
    end

    puts "writing #{ARGV[0]}/#{rootname}.kin"
    begin
      kinfile = File.new("#{ARGV[0]}/#{rootname}.kin", "w")
    rescue
      STDERR.print "Could not open file #{ARGV[0]}/#{rootname}.kin\n"
      exit 1
    end
    
    contains_openchain = false;
    ss_array = []
    seq = ""
    i=0
    resdata = alnfile.readlines() 
    resdata.each do |line|
      line.strip!
      line_data = line.split(%r{\s+})
      
      if line_data.length != 2 then
        ss_array << line_data[0]
        kinfile.printf("%6d    ",i)
        #kinfile.puts("#{line_data[0]}    #{line_data[1]}    #{line_data[2]}")
	kinfile.puts(line)
        i=i+1
        if (line_data[2] == "[_]") then
            contains_openchain = true;
        end
      elsif line_data.length == 2 and line_data[1]=="#consensus" then
        kinfile.printf("          %s\n", line_data[0])
        seq = line_data[0]
      else
	puts line_data[0]
	puts line_data[1]
	hited = Array.new(ss_array.length) { Array.new(ss_array.length) {0.0} }
	i=0
	ss_array.each do|ss1|
	    last_line = `RNAHeliCes -s '#{line_data[0]}' -k 100`
	    puts last_line.strip!
	    #last_line_data = last_line.split(%r{\s+})
	  i=i+1
	end
      end
    end
    if (!contains_openchain) then
        kinfile.printf("%6d    ",i)
        kinfile.puts("#{'.'*seq.length}    0.00    [_]")
    end
end
