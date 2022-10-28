use strict;
use warnings;


my ($seg_count_file,$outfile) = @ARGV;


my @fluA_HA = qw/A_HA_H1 A_HA_H2 A_HA_H3 A_HA_H4 A_HA_H5 A_HA_H6 A_HA_H7 A_HA_H8 A_HA_H9 A_HA_H10 A_HA_H11 A_HA_H12 A_HA_H13 A_HA_H14 A_HA_H15 A_HA_H16/;
my @fluA_NA = qw/A_NA_N1 A_NA_N2 A_NA_N3 A_NA_N4 A_NA_N5 A_NA_N6 A_NA_N7 A_NA_N8 A_NA_N9/;

my @fluB_HA = qw/B_Victoria_HA B_Yamagata_HA/;
my @fluB_NA = qw/B_NA/;


my %fluA_GT;
for my $HA (@fluA_HA){
	for my $NA (@fluA_NA){
		my $GT = "$HA\t$NA";
		$fluA_GT{$GT} = 1;
	}
}

my %fluB_GT;
for my $HA (@fluB_HA){
	for my $NA (@fluB_NA){
		my $GT = "$HA\t$NA";
		$fluB_GT{$GT} = 1;
	}
}


my %seg_count;
open IN, "$seg_count_file" or die;
while (<IN>){
	chomp;
	my @arr = split /\t/;
	my $reads_num = $arr[1];
	next if ($reads_num <= 100); # segment shoud have >= 100 reads
	$seg_count{$arr[0]} = $arr[1];
}
close IN;


my %gt_count;
foreach my $seg (keys %seg_count){
	my $num = $seg_count{$seg};
	foreach my $seg2 (keys %seg_count){
		if ($seg ne $seg2){
			my $num2 = $seg_count{$seg2};
			my $gt = "$seg\t$seg2";
			my $gt_count = $num + $num2;
			$gt_count{$gt} = $gt_count;
		}
	}
}

my $flag = 0;
my $assign_gt = "NA";
foreach my $gt (sort {$gt_count{$b} <=> $gt_count{$a}} keys %gt_count){
	if (exists $fluA_GT{$gt}){
		$assign_gt = $gt;
		last;
	}elsif (exists $fluB_GT{$gt}){
		$assign_gt = $gt;
		last;
	}else{
		next;
	}
}


my $final_gt;
if ($assign_gt eq "NA"){
	$final_gt = "NA (Please check your data)";
}else{
	if ($assign_gt =~ /B_Yamagata_HA/ || $assign_gt =~ /B_Victoria_HA/){
		$final_gt = (split /\t/, $assign_gt)[0];
		$final_gt =~ s/_HA$//;
	}else{
		my $HA = (split /\t/, $assign_gt)[0];
		$HA =~ s/A_HA_//;

		my $NA = (split /\t/, $assign_gt)[1];
		$NA =~ s/A_NA_//;

		$final_gt = $HA.$NA;
	}
}

print "Final GT is: $final_gt\n";

open O, ">$outfile" or die;
print O "Final GT is: $final_gt\n";
close O;

