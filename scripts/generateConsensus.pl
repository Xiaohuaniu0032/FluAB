use strict;
use warnings;
use FindBin qw/$Bin/;
use File::Basename;



my ($name,$gvcf,$gt_file,$target,$python2,$outdir) = @ARGV;

my $runsh = "$outdir/generateConsensus.sh";
open O, ">$runsh" or die;


my @seg;

open IN, "$gt_file" or die;
my $gt_line = <IN>;
chomp $gt_line;
my $gt = (split /\:/, $gt_line)[1];

if ($gt ne "NA"){
	while (<IN>){
		chomp;
		my @arr = split /\t/, $_;
		my $seg = $arr[0];
		push @seg, $seg;

		if (!-d "$outdir/$seg"){
			`mkdir $outdir/$seg`;
		}

		my $cons_fa = "$outdir/$seg/$seg\_consensus.fasta";
		my $this_dir = $Bin;
		my $root_dir = dirname($this_dir);
		my $gvcf_to_fasta = "$root_dir/bin/generateConsensus/gvcf_to_fasta.py";
		my $cmd = "$python2 $gvcf_to_fasta -m 1 -n 0.5 -p 0.6 -v $gvcf -o $cons_fa -c $seg -d 10 -r $target";
		print O "$cmd\n\n";
	}
}
close IN;
close O;


`chmod 755 $runsh`;
`sh $runsh`;

# 合并fasta
if ($gt ne "NA"){
	my $cons = "$outdir/$name\.consensus.fasta";
	open O, ">$cons" or die;

	for my $seg (@seg){
		my $fa = "$outdir/$seg/$seg\_consensus.fasta";
		if (-e $fa){
			print "Find $seg cons.fa: $fa\n";
			open FA, "$fa" or die;
			while (<FA>){
				chomp;
				print O "$_\n";
			}
			close FA;
		}
	}
	close O;
}


# -m: MAJOR_ALLELE_ONLY
# -n: The minimum variant frequency of a variant that is not a HP-INDEL to put it in the FASTA.
# -p: The minimum variant frequency of a HP-INDEL to put it in the FASTA.
# -a: ALIAS_CONTIG (Optional)
# -c: PROCESS_CONTIG (Required) [Process the contig in input_fasta_file only]

# http://10.69.40.7/report/564/#generateConsensus-section