use strict;
use warnings;

my ($gt_file,$TSVC_variants_vcf,$outfile) = @ARGV;

open O, ">$outfile" or die;

open IN, "$gt_file" or die;
my $gt_line = <IN>;
my $gt = (split /\:/, $gt_line)[1]; # gt may be NA

if ($gt ne "NA"){
	my $HA_line = <IN>;
	my $HA = (split /\t/, $HA_line)[0];
	# 提取HA片段的VCF用于注释
	open VCF, "$TSVC_variants_vcf" or die;
	while (<VCF>){
		chomp;
		if (/^\#\#/){
			#print O "$_\n";
			next;
		}elsif (/^\#CHROM/){
			print O "$_\n";
		}else{
			my @arr = split /\t/, $_;
			my $chr = $arr[0];
			if ($chr eq $HA){
				print O "$_\n";
			}
		}
	}
	close VCF;
}
close IN;
close O;