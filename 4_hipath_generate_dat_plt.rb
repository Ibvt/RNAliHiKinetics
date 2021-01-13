#!/usr/bin/env ruby

require "pp"
require "open3"

if ARGV.length != 1 then
  STDERR.puts "Usage: #{$0} dir_to_be_processed"
  exit(-1)
end
dirfilename = "#{ARGV[0]}/files_to_be_processed.txt"

T = 37
kT = 0.00198717*(273.15 + T)
puts "kT=#{kT}"
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
    initstru_energies = []
    hishapes = []
    seq = ""
    kindata = kinfile.readlines() 
    kindata.each do |line|
      line.strip!
      line_data = line.split(%r{\s+})
      
      if line_data.length != 1 then
        ss_array << line_data[1]
	initstru_energies << line_data[2].to_f
	hishapes << line_data[3]
      elsif line_data.length == 1 then
        seq = line_data[0]
      end
    end

    ################################
    #### calculate abs_hienergy ####
    #pp (ss_array)
    abs_hienergy = Array.new(ss_array.length) { Array.new(ss_array.length) {0.0} }
    i=0
    ss_array.each do|ss1|
      j=0
      ss_array.each do|ss2| 
	last_line = `tail -n 1 #{ARGV[0]}/#{rootname}.hipaths/#{i}_#{j}.hipath`
	last_line.strip!
        last_line_data = last_line.split(%r{\s+})
	#puts initstru_energies[j]
	#puts last_line_data[-2]
        abs_hienergy[i][j] = ((initstru_energies[i] + last_line_data[-2].to_f)*100).round / 100.0 # absoluteB = absoluteS + BarrierEnergy
	j=j+1
      end
      i=i+1
    end
    pp abs_hienergy

    ####### relax the table ########
    0.upto(ss_array.length-1) do |i|
      0.upto(i) do |j|
	if i==j then  
	    # ENSURE values in the diagonal are 0.0
	    #NOTE that the numbers in diagonal are not important, because they will be calculated from the remaining numbers of this row
	    abs_hienergy[i][j]=0.0
	    #M abs_hienergy[i][j]=-100000.0
	else
	    if (abs_hienergy[i][j]>abs_hienergy[j][i]) then
	      abs_hienergy[i][j]=abs_hienergy[j][i]
	    else  # abs_hienergy[j][i] is bigger
	      abs_hienergy[j][i]=abs_hienergy[i][j]
	    end
	end
      end
    end
    
    
    #########################
    #### calculate hited #### 
    #hited = Array.new(ss_array.length) { Array.new(ss_array.length) {0.0} }
    #i=0
    #ss_array.each do|ss1|
    #  j=0
    #  ss_array.each do|ss2| 
    #    last_line = `HiTed '#{hishapes[i]}' '#{hishapes[j]}' -r 1`
	#last_line.strip!
        #last_line_data = last_line.split(%r{\s+})
	##puts last_line_data[-1]
        #hited[i][j] = last_line_data[-1].to_f
	#j=j+1
    #  end
    #  i=i+1
    #end
    #pp hited

    ####### check if the table is symmetrical ########
    #0.upto(ss_array.length-1) do |i|
    #  0.upto(i) do |j|
	#if i==j then  
	 # if (hited[i][j]!=0.0) then
	 #   exit 1
	 # end
	#else
	 # if (hited[i][j]!=hited[j][i]) then
	 #   exit 1
	 # end
	#end
      #end
    #end  
    
    ##########################################################
    ########### Graph of HiTed versus abs_hienergy ###########
    #### generate rw1.dat and rw1.plt
    #### using 'gnuplot rw1.plt' generate rw1.pdf which used the data from rw1.dat
    ##########################################################
    ####### output a .dat file ########    
    #begin
    #  datfile = File.new("#{ARGV[0]}/#{rootname}.dat", "w")
    #rescue
    #  STDERR.print "Could not open file #{ARGV[0]}/#{rootname}.dat!\n"
    #  exit 1
    #end
    #0.upto(ss_array.length-1) do |i|
    #  0.upto(i-1) do |j|
	#datfile.puts("#{hited[i][j]}\t#{abs_hienergy[i][j]}")
    #  end
    #end
    
    
    ####### output a gnuplot file ########
    #begin
    #  pltfile = File.new("#{ARGV[0]}/#{rootname}.plt", "w")
    #rescue
    #  STDERR.print "Could not open file #{ARGV[0]}/#{rootname}.plt!\n"
    #  exit 1
    #end

    #pltfile.puts("set title 'Graph of HiTed versus abs_hienergy (#{rootname})'")
    #pltfile.puts("set xlabel 'HiTed'")
    #pltfile.puts("set ylabel 'abs_hienergy'")
    #pltfile.puts("set term pdf")
    #pltfile.puts("set output '#{rootname}.pdf'")
    #pltfile.puts("plot '#{rootname}.dat' using 1:2 title 'x'")
    

    ##########################################################
    ########### HiTree ########### 
    #### generate rw1.tree.dat
    #### ./ShowTree -f rw1.tree.dat
    #### ps2pdf rw1.tree.dat.ps
    ##########################################################
    ####### output .tree.dat file ######## 
    # >ggcc
    #           GGGGGGCCCCCC
    #      0    ((((....))))   -7.20  [6.5]
    #      1    .((((...))))   -4.20  [7]
    #      2    ((((...)))).   -5.00  [6]
    # S         0         0       6.1       6.9
    # S         1       6.1         0       6.1
    # S         2       6.9       6.1         0
    begin
      treedatfile = File.new("#{ARGV[0]}/#{rootname}.tree.dat", "w")
    rescue
      STDERR.print "Could not open file #{ARGV[0]}/#{rootname}.tree.dat!\n"
      exit 1
    end   

    contains_openchain = false;
    i=0
    treedatfile.puts(">#{rootname}")
    File.foreach("#{ARGV[0]}/#{rootname}.res") do |line|
      line.strip!
      line_data = line.split(%r{\s+})
      if line_data.length != 2 then  #if line_data.length>1 && line_data[1]!="=" && line_data[0]!="Published;" then
	treedatfile.printf("%6d    ",i)
	#treedatfile.puts("#{line_data[0]}    #{line_data[1]}    #{line_data[2]}    #{((-kT*Math.log(line_data[3].to_f))*100).round / 100.0}")
	treedatfile.puts(line)
	i=i+1
	if (line_data[2] == "[_]") then
	    contains_openchain = true;
	end
      elsif line_data.length == 2 and line_data[1]=="#consensus" then
	treedatfile.printf("          %s\n", line_data[0])
      end
    end
    if (!contains_openchain) then
      treedatfile.printf("%6d    ",i)
      treedatfile.puts("#{'.'*seq.length}    0.00    [_]")
    end
    0.upto(ss_array.length-1) do |i|
      treedatfile.print("S");
      treedatfile.printf("%10d",i);
      0.upto(ss_array.length-1) do |j|
	  treedatfile.printf("%10.4g",abs_hienergy[i][j]);
      end
      treedatfile.printf("\n");
    end
    
    ##########################################################
    ########### Kinetic analysis based on Hishapes ###########
    ########### input: rw1.rates.out and rw1.kin
    ########### output: rw1.kin.dat
    ########### using 'gnuplot rw1.kin.plt' generate rw1.kin.ps which used the data from rw1.kin.dat   
    ##########################################################
    

    
    ###################################################
    ####### prepare #{ARGV[0]}/#{rootname}.rates.out file ########
    begin
      ratesout = File.new("#{ARGV[0]}/#{rootname}.rates.out", "w")
    rescue
      STDERR.print "Could not open file rates.out!\n"
      exit 1
    end     
    0.upto(ss_array.length-1) do |i|
	    0.upto(ss_array.length-1) do |j|
	        ratesout.printf("%10.4g",abs_hienergy[i][j]);
	        #Z ratesout.printf("%10.4g", Math.exp(-(abs_hienergy[i][j]-hishape_fenergies[i])/kT));
	    end
	    ratesout.printf("\n");
    end
    ratesout.close
    
    
    ####### output .kin.dat file ########
    system("treekin_hi --p0 #{ss_array.length}=1 --t0=0.001 --t8=10000000000 --ratesfile=#{ARGV[0]}/#{rootname}.rates.out -m H < #{ARGV[0]}/#{rootname}.kin > #{ARGV[0]}/#{rootname}.kin.dat")
    #puts %x[#{cmd}]
    # http://www.der-schnorz.de/2010/09/gnuplot-colors-presentations-papers-and-contrast/
    linestyles = []    
    linecolors=["red","blue","forest-green","magenta","gray","black","dark-red","orange"]    #,"royalblue","dark-orange"
    1.upto(8) do |i|
      1.upto(8) do |j|
	linestyles << "set style line #{(i-1)*8+j} lt #{j} lc rgb \"#{linecolors[(j-1+i-1)%8]}\" lw 3"
      end
    end
    1.upto(8) do |i|
      1.upto(8) do |j|
	linestyles << "set style line #{(i-1+8)*8+j} lt #{j} lc rgb \"#{linecolors[(j-1+i-1)%8]}\" lw 1"
      end
    end
    pp linestyles
    # linestyles    
    # "set style line 1 lt 1 lc rgb \"red\" lw 3",
    # set style line 2 lt 2 lc rgb "blue" lw 3
    # set style line 3 lt 3 lc rgb "forest-green" lw 3
    # set style line 4 lt 4 lc rgb "magenta" lw 3
    # set style line 5 lt 5 lc rgb "dark-orange" lw 3
    # set style line 6 lt 6 lc rgb "royalblue" lw 3
    # set style line 7 lt 7 lc rgb "black" lw 3
    # set style line 8 lt 8 lc rgb "dark-red" lw 3
    # set style line 9 lt 9 lc rgb "orange-red" lw 3
    # set style line 10 lt 10 lc rgb "gray" lw 3
    pp hishapes
    ####### output .kin.plt file ########    
    begin
      kin_plt_file = File.new("#{ARGV[0]}/#{rootname}.kin.plt", "w")
    rescue
      STDERR.print "Could not open file #{ARGV[0]}/#{rootname}.kin.plt!\n"
      exit 1
    end  
    #kin_plt_file.puts("set title 'Hishape based kinetic analysis (#{rootname})'")
    #kin_plt_file.puts("set terminal postscript eps enhanced color")  # dashed 16
    kin_plt_file.puts("set terminal postscript enhanced eps color dashed 16")
    kin_plt_file.puts("set xlabel \"{/Times=12 arbitrary units}\"")
    kin_plt_file.puts("set xrange [0.001:10000000000.0]")
    kin_plt_file.puts("set logscale x")
    kin_plt_file.puts("set ylabel \"{/Times=12 Population density}\"")
    kin_plt_file.puts("set yrange [0:1]")
    kin_plt_file.puts("set term postscript enhanced font 'Time-roman,9'")
    kin_plt_file.puts("set term postscript")
    #kin_plt_file.puts("set output '#{rootname}.kin.pdf'")
    kin_plt_file.puts("set output '#{rootname}.kin.ps'")
    #kin_plt_file.puts("set key right top spacing 1.4") #title 'Legend' box 1
    #kin_plt_file.puts("set key left bottom Left title 'Legend' box 3")
    kin_plt_file.puts("set key right top Left")
    kin_plt_file.puts("set key width 3")
    kin_plt_file.puts("set key height 5")

    #kin_plt_file.puts("set key spacing 1.4")
    #kin_plt_file.puts("set key Left")
    #kin_plt_file.puts("set key reverse")
    #kin_plt_file.puts("set key width 20")
    #kin_plt_file.puts("set key height 15")

    0.upto(linestyles.size-1) do |i|
      kin_plt_file.puts linestyles[i]
    end
    kin_plt_file.puts("plot '#{rootname}.kin.dat' using 1:2 title '#{hishapes[0]}' with lines ls 1, \\")
    2.upto(ss_array.length-1) do |i|  # 
	kin_plt_file.puts("'#{rootname}.kin.dat' using 1:#{i+1} title '#{hishapes[i-1]}' with lines ls #{i}, \\")
    end
#     kin_plt_file.puts("plot '#{rootname}.kin.dat' using 1:#{sorted_id_fenergies[0][0]} title '#{hishapes[sorted_id_fenergies[0][0]]}' with lines linewidth 3, \\")
#     2.upto(8) do |i|  # ss_array.length-1
# 	kin_plt_file.puts("'#{rootname}.kin.dat' using 1:#{sorted_id_fenergies[i+1][0]} title '#{hishapes[sorted_id_fenergies[i-1][0]]}' with lines linewidth 3, \\")
#     end
    kin_plt_file.puts("'#{rootname}.kin.dat' using 1:#{ss_array.length+1} title '#{hishapes[ss_array.length-1]}' with lines ls #{ss_array.length}")  # #{hishapes[ss_array.length-1]}

    kin_plt_file.puts("pause -1 'Hit any key to continue'")
end
