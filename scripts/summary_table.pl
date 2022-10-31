use strict;
use warnings;

my ($depth_file,$gt_file,$outfile) = @ARGV;


my %depth;
open DEPTH, "$depth_file" or die;
while (<DEPTH>){
	chomp;
	my @arr = split /\t/, $_;
	my $h = $arr[0];
	my $pos = $arr[1];
	my $depth = $arr[2];
	$depth{$h}{$pos} = $depth;
}
close DEPTH;


# 统计参考序列长度
my %seg_len;
foreach my $h (keys %depth){
	my @pos = keys %{$depth{$h}};
	my $len = scalar(@pos);
	$seg_len{$h} = $len;
}

# 统计比对到的reads数



# 统计平均深度
my %seg_meanDepth;
foreach my $h (keys %depth){
	my $total_base = 0;
	my $base_n = 0;
	foreach my $p (sort {$a <=> $b} keys %{$depth{$h}}){
		$base_n += 1;
		my $depth = $depth{$h}{$p};
		$total_base += $depth;
	}

	my $mean_depth;
	if ($total_base == 0){
		$mean_depth = "NA";
	}else{
		$mean_depth = int($total_base/$base_n);
	}

	$seg_meanDepth{$h} = $mean_depth;
}


# 统计25X碱基百分比
my %depth_25X_ratio;
foreach my $h (keys %depth){
	my $base_n = 0;
	my $cov_large_cutoff = 0;
	foreach my $p (sort {$a <=> $b} keys %{$depth{$h}}){
		$base_n += 1;
		my $depth = $depth{$h}{$p};
		if ($depth >= 25){
			$cov_large_cutoff += 1;
		}
	}

	my $ratio;
	if ($cov_large_cutoff == 0){
		$ratio = "NA";
	}else{
		$ratio = sprintf "%.2f", $cov_large_cutoff / $base_n * 100; 
	}

	$ratio = $ratio."%";
	$depth_25X_ratio{$h} = $ratio;
}



# 输出每个seg的信息
open O, ">$outfile" or die;
print O "Segment";

open GT, "$gt_file" or die;
my $gt_line = <GT>;
my $gt = (split /\:/, $gt_line)[1];

if ($gt ne "NA"){
	my %seg_reads_count;
	my @seg;
	while (<GT>){
		chomp;
		my @arr = split /\t/, $_;
		$seg_reads_count{$arr[0]} = $arr[1];
		push @seg, $arr[0];
	}
	close GT;

	for my $seg (@seg){
		print O "\t$seg";
		print O "\n";
	}


	# Consensus Length
	print O "Consensus Length";
	for my $seg (@seg){
		my $n = $seg_len{$seg};
		print O "\t$n";
		print O "\n";
	}
	
	# Mapped Reads

	# Mean Depth

	# Ratio (depth>=25X) 

}