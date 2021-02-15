# RNAliHiKinetics
RNA folding kinetics for aligned RNAs

prestep1: install RNAliHeliCes and RNAliHiPath (https://github.com/Ibvt/RNAliHeliCes)

             ./configure CFLAGS="-fno-stack-protector" CPPFLAGS="-std=c++98" CXXFLAGS="-std=c++98 -fno-stack-protector"
             make (Please replace automake-1.14 with your version (e.g. 1.15) by typing "sed -i -e 's/1.14/1.15/g' Makefile" if necessary.)
             sudo make install

prestep2: install treekin_hi under directory Treekin-0.3.1_hi

             ./configure
             make
             sudo make install

(if necessary) convert stockholm to aln: http://www.ibi.vu.nl/programs/convertalignwww/

Taking RF00500 as an example alignment, we can run the program as follows,

Step 1: RNAliHeliCes RF00500/RF00500_seed.aln -k 100 > RF00500/RF00500_seed.res

Step 2: 

        ./1_generate_kin.rb    RF00500

        ./2_generate_ssfile.rb RF00500
        
        ./3_generate_hipath.pl RF00500
        
        ./4_hipath_generate_dat_plt.rb RF00500

Step 3: replace [_] with [\\\_] in RF00500/RF00500_seed.kin.plt

Step 4:                      

             cd RF00500;
             
             gnuplot RF00500_seed.kin.plt;
             
             okular RF00500_seed.kin.ps;
             
             #(optional) cd ..; ./ShowTree -f RF00500/RF00500_seed.tree.dat
