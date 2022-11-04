use strict;
use warnings;

my ($annot_vcf,$outfile) = @ARGV;

open O, ">$outfile" or die;

print O "Chr\tPos\tRef\tAlt\tQUAL\tAF\tDepth\tAnnotation\tHGVS.c\tHGVS.p\n";


open IN, "$annot_vcf" or die;
while (<IN>){
	chomp;
	next if /^$/;
	if (/^\#/){
		next;
	}else{
		my @arr = split /\t/, $_;
		my $chr = $arr[0];
		my $pos = $arr[1];
		my $ref = $arr[3];
		my $alt = $arr[4];
		my $qual = int($arr[5]);
		
		my $format_line = $arr[7];
		my @format_line = split /\;/, $format_line;
		my $AF = $format_line[0];
		$AF =~ s/AF=//; # 0.995;
		$AF = $AF * 100; # 99.5%

		my $DP = $format_line[2]; # raw depth
		$DP =~ s/DP=//;

		my $ANN_line;
		for my $item (@format_line){
			if ($item =~ /^ANN/){
				$ANN_line = $item;
			}
		}

		my @ANN = split /\|/, $ANN_line;

		my $Annotation = $ANN[1];
		my $HGVS_c = $ANN[9];
		my $HGVS_p = $ANN[10];

		if (defined $ANN_line){
			# with snpEff results
			print O "$chr\t$pos\t$ref\t$alt\t$qual\t$AF\t$DP\t$Annotation\t$HGVS_c\t$HGVS_p\n";
		}
	}
}
close IN;
close O;