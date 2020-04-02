#!/usr/bin/env ruby

=begin
prestep: convert stockholm to aln: http://www.ibi.vu.nl/programs/convertalignwww/
Step 1: RNAalihishapes RF00500_seed.aln -k 100 > RF00500_seed.res
Step 2: ./1_* 2_* 3_* 4_*
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
    resfilename="#{ARGV[0]}/#{rootname}.res"

    if (File.exist?(resfilename))
      begin
        resfile = File.new(resfilename, "r")
      rescue
        STDERR.print "Could not open file #{resfilename}!\n"
        exit 1
      end
    else
      STDERR.print "File #{resfilename} does not exist!\n"
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
    resdata = resfile.readlines() 
    resdata.each do |line|
      line.strip!
      line_data = line.split(%r{\s+})
      
#       if line_data.length>1 && line_data[1]!="=" && line_data[0]!="Published;" then
# 	  kinfile.printf("%6d    ",i);
# 	  hishape_G = ((-kT*Math.log(line_data[3].to_f))*100).round / 100.0
# 	  kinfile.puts("#{line_data[0]}    #{hishape_G}    #{line_data[2]}")
# 	  id_fenergies[i] = hishape_G
#       elsif line_data.length==1 then
# 	  kinfile.puts(line)
#       end
      if line_data.length != 2 then  #line_data[0] != "length" and line_data[0] != ">Published;" and line_data[0] != "Published;" then
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
      end
    end
    if (!contains_openchain) then
        kinfile.printf("%6d    ",i)
        kinfile.puts("#{'.'*seq.length}    0.00    [_]")
    end
end