use strict;
use warnings;

my $ref = "/data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB.fasta";

my %fasta;
my @header_name;
my %header_name;
my $header_name;

open IN, "$ref" or die;
while (<IN>){
	chomp;
	next if /^$/;
	if (/^\>/){
		$header_name = (split /\s+/, $_)[0];
		$header_name =~ s/^\>//;
		if (!exists $header_name{$header_name}){
			$header_name{$header_name} += 1;
			push @header_name, $header_name;
		}
	}else{
		push @{$fasta{$header_name}}, $_;
	}
}
close IN;

open O, ">FluAB.target.bed" or die;

foreach my $seq_name (@header_name){
	my @seq = @{$fasta{$seq_name}};
	my $seq = join("",@seq);
	my $seq_len = length($seq);
	print O "$seq_name\t0\t$seq_len\t$seq_name\_1\_982\n";
}
close O;
