# RNAliHiKinetics
RNA folding kinetics for aligned RNAs

## Dependencies
RNAliHiKinetics needs RNAliHelices and RNAliHipath whose installation is described below. Additional dependencies are:

compile time:
* C++ compiler (for example GCC g++)
* C compiler (for example GCC)
* GNU make >= 3.81

compile time and runtime:
* Boost Libraries (>1.58): program_options, date_time
* LAPACK 

## Installation
RNAliHiKinetics depends on RNAliHeliCes and RNAliHiPath (https://github.com/Ibvt/RNAliHeliCes), which can be installed as follows:

```sh
git clone https://github.com/Ibvt/RNAliHeliCes
./configure CFLAGS="-fno-stack-protector" CPPFLAGS="-std=c++98" CXXFLAGS="-std=c++98 -fno-stack-protector"
make
sudo make install
```
Next is to clone and install RNAliHiKinetics and to install treekin_hi from the Treekin-0.3.1_hi subdirectory
```sh
git clone https://github.com/Ibvt/RNAliHiKinetics
cd RNAliHiKinetics/Treekin-0.3.1_hi
./configure
make
sudo make install
```

## Test run
Note: RNAliHeliCes expects the input alignment in ClustalW (aln) format. To convert the format of your alignment please go to http://www.ibi.vu.nl/programs/convertalignwww/.


Taking RF00500 as an example alignment, we can run the program as follows,

### Step 1: Run RNAliHeliCes on the alignment
```RNAliHeliCes RF00500/RF00500_seed.aln -k100 -x0 > RF00500/RF00500_seed.res```

### Step 2: Perform RNAliHiKinetics simulation steps
```sh
./1_generate_kin.rb    RF00500
./2_generate_ssfile.rb RF00500
./3_generate_hipath.pl RF00500
./4_hipath_generate_dat_plt.rb RF00500
```

### Step 3: Visualise results 
```sh
cd RF00500;
gnuplot RF00500_seed.kin.plt;
display RF00500_seed.kin.png;
#(optional) cd ..; ./ShowTree -f RF00500/RF00500_seed.tree.dat
```

## Citations
  [1] Huang J, Voß B. Simulation of Folding Kinetics for Aligned RNAs. Genes (Basel). 2021 Feb 26;12(3):347. doi: 10.3390/genes12030347. PMID: 33652983.
