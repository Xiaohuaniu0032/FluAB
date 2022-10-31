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
	#next if ($reads_num <= 100); # segment shoud have >= 100 reads
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


# 分型算法
# 根据HA+NA序列数多少分型
my $flag = 0;
my $assign_gt = "NA";
foreach my $gt (sort {$gt_count{$b} <=> $gt_count{$a}} keys %gt_count){
	if (exists $fluA_GT{$gt}){
		# fluA
		$assign_gt = $gt;
		last;
	}elsif (exists $fluB_GT{$gt}){
		# fluB
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
		#$final_gt =~ s/_HA$//;
	}else{
		my $HA = (split /\t/, $assign_gt)[0];
		#$HA =~ s/A_HA_//;

		my $NA = (split /\t/, $assign_gt)[1];
		#$NA =~ s/A_NA_//;

		#$final_gt = $HA.$NA;
		$final_gt = "$HA\t$NA";
	}
}

#print "Final GT is: $final_gt\n";

open O, ">$outfile" or die;
#print O "Final GT is: $final_gt\n";

# 根据genotype,输出各个片段的reads数
if ($final_gt eq "NA"){
	# 没有成功分型
	print O "GT:NA\n";
	print O "# I can not determine this sample's genotype.\n";
	print O "# Please check *.seg.count.txt file to check.\n";
}else{
	if ($final_gt =~ /B_Yamagata/){
		my @final_gt = split /\_/, $final_gt;
		my $GT = "$final_gt[0]\/$final_gt[1]"; # B/Yamagata
		print O "GT:$GT\n";

		my @seg = qw/B_Yamagata_HA B_NA B_PB1 B_PB2 B_PA B_NP B_NS B_MP/;
		for my $seg (@seg){
			my $n;
			if (exists $seg_count{$seg}){
				$n = $seg_count{$seg};
			}else{
				$n = 0;
			}

			print O "$seg\t$n\n";
		}
	}elsif ($final_gt =~ /B_Victoria_HA/){
		my @final_gt = split /\_/, $final_gt;
		my $GT = "$final_gt[0]\/$final_gt[1]"; # B/Victoria
		print O "GT:$GT\n";

		my @seg = qw/B_Victoria_HA B_NA B_PB1 B_PB2 B_PA B_NP B_NS B_MP/;
		for my $seg (@seg){
			my $n;
			if (exists $seg_count{$seg}){
				$n = $seg_count{$seg};
			}else{
				$n = 0;
			}

			print O "$seg\t$n\n";
		}
	}else{
		# fluA
		my @final_gt = split /\t/, $final_gt; # A_HA_H3 A_NA_N2
		my $HA = $final_gt[0];
		$HA =~ s/A_HA_//;
		my $NA = $final_gt[1];
		$NA =~ s/A_NA_//;

		my $GT = $HA.$NA; # H3N2
		print O "GT:$GT\n";

		my @seg;
		push @seg, $final_gt[0]; # HA
		push @seg, $final_gt[1]; # NA

		push @seg, "A_PB1";
		push @seg, "A_PB2";
		push @seg, "A_PA";
		push @seg, "A_NP";
		push @seg, "A_NS";
		push @seg, "A_MP";

		for my $seg (@seg){
			my $n;
			if (exists $seg_count{$seg}){
				$n = $seg_count{$seg};
			}else{
				$n = 0;
			}

			print O "$seg\t$n\n";
		}
	}
}

close O;

