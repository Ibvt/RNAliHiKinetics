#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
#use File::Basename qw( fileparse );
use File::Path qw( make_path );
use File::Spec;
use POSIX;
use threads;
use threads::shared;
#use String::Util 'trim';

# function of this file: calculate the hipath from ss-file.
 
my $data_file=$ARGV[0]."/"."files_to_be_processed.txt";
open(DAT, $data_file) || die("Could not open file!");
my @raw_data=<DAT>; 
close(DAT);

print "Starting main program\n";
my @childs;
my $wrestler;
foreach $wrestler (@raw_data)
{
    my $rootname;
    my $extension;
    chomp($wrestler);
    ($rootname,$extension)=split(/\./,$wrestler);

    my $path_directory = $ARGV[0]."/".$rootname.'.hipaths';
    if ( !-d $path_directory ) {
	make_path $path_directory or die "Failed to create path: $path_directory";
    }

    my $filename = $ARGV[0]."/".$rootname.'.kin';
    my $line_number = -1;
    my $buffer;
    open(FILE, $filename) or die "Can't open `$filename': $!";
    while (sysread FILE, $buffer, 4096) {
        $line_number += ($buffer =~ tr/\n//);
    }
    close FILE;
    print "The number of lines in $filename is $line_number.\n";

    open my $file, '<', $filename; 
    my $first_line = <$file>; 
    close $file;
    #$first_line = trim($first_line);
    $first_line =~ s/^\s+|\s+$//g ;
    #print int(124000*length($first_line)**(-1.5));
    my $kvalue = sprintf("%d", 124000*length($first_line)**(-1.5));
    #print $nIntValue;

    #my $num = 1;
    my $i=0;
    for ($i=0;$i<$line_number;$i++)
    {
	my $pid = fork();
	if($pid){
		push(@childs, $pid);
	}elsif ($pid == 0){
	    my $j=0;
	    for ($j=0;$j<$line_number;$j++)
	    {
                print "RNAalihipath -f ${ARGV[0]}/${rootname}.aln -k ${kvalue} -F ${ARGV[0]}/${rootname}.ssfiles/${i}_${j}.ss -t 1 > $path_directory/${i}_${j}.hipath\n";
		unless (-e "$path_directory/${i}_${j}.hipath") {
		    system "RNAalihipath -f ${ARGV[0]}/${rootname}.aln -k ${kvalue} -F ${ARGV[0]}/${rootname}.ssfiles/${i}_${j}.ss -t 1 > $path_directory/${i}_${j}.hipath";
		}
	    }
	    exit 0;
	}else{
	    die "couldnt fork: $!\n";
	}
	#$num++;
    }
}


 
print "waitpid\n";
foreach (@childs) {
        my $tmp = waitpid($_, 0);
        print "done with pid $tmp\n";
}
 
print "End hipath calculation\n";
 
