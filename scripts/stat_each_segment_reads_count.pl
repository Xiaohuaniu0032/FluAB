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
	my $flag = $arr[1];
	if ($flag == 0 || $flag == 16){
		# 0 => mapped
		# 16 => REVERSE
		my $seg = $arr[2];
		$count{$seg} += 1;
	}else{
		# 4 => unmap
		# 2048 => SUPPLEMENTARY
		# 2064 => REVERSE,SUPPLEMENTARY
		# 256 => SECONDARY
		next;
	}
}
close SAM;

foreach my $seg (sort {$count{$b} <=> $count{$a}} keys %count){
	my $count = $count{$seg};
	print O "$seg\t$count\n";
}

close O;