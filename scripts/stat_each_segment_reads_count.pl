use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin/;


my ($sam,$outfile) = @ARGV;


open O, ">$outfile" or die;

my %count;

open SAM, "$sam" or die;
while (<SAM>) {
	# body...
	chomp;
	next if /^\@/;
	next if /^$/;
	my @arr = split /\t/;
	my $seg = $arr[2];
	$count{$seg} += 1;
}
close SAM;

foreach my $seg (sort {$count{$b} <=> $count{$a}} keys %count){
	my $count = $count{$seg};
	print O "$seg\t$count\n";
}

close O;