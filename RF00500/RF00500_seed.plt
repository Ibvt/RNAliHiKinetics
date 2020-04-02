set title 'Graph of HiTed versus abs_hienergy (RF00500_seed)'
set xlabel 'HiTed'
set ylabel 'abs_hienergy'
set term pdf
set output 'RF00500_seed.pdf'
plot 'RF00500_seed.dat' using 1:2 title 'x'
