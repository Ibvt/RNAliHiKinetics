# RNAliHiKinetics
RNA folding kinetics for aligned RNAs

#under Ubuntu_14_06 with installed RNAHelCes and RNAlihishapes
prestep: convert stockholm to aln: http://www.ibi.vu.nl/programs/convertalignwww/
Step 1: RNAalihishapes RF00500_seed.aln -k 100 > RF00500_seed.res
Step 2: ./1_generate_kin.rb    RF00500
        ./2_generate_ssfile.rb RF00500
        ./3_generate_hipath.pl RF00500
        ./4_hipath_generate_dat_plt.rb RF00500
Step 3: replace [_] with [\_]
Step 4: gnuplot RF00500_seed.kin.plt; okular RF00500_seed.kin.ps
                RF00500_seed.plt; okular RF00500_seed.ps
                ./ShowTree -f RF00500_seed.tree.dat