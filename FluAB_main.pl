use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin/;

my ($bam,$name,$outdir,$samtools,$bwa);

GetOptions(
	"bam:s"   =>  \$bam,     # Need
	"n:s"     =>  \$name,    # Need
	"od:s"    =>  \$outdir,  # Need
	"samtools:s"  => \$samtools,
	"bwa:s"       => \$bwa,
	) or die "unknown args\n";


if (not defined $samtools){
	$samtools = "/usr/bin/samtools";
}

if (not defined $bwa){
	$bwa = "/usr/bin/bwa";
}

my $runsh = "$outdir/run\_$name\_fluAB.sh";

open SH, ">$runsh" or die;


# samtools fastq
my $fq = "$outdir/$name\.fastq";
my $cmd = "$samtools fastq $bam >$fq";
print SH "$cmd\n\n";


# bwa aln
my $IRMA_ref = "$Bin/database/IRMA/modules/FLU/reference/consensus.fasta";
my $sam = "$outdir/$name\.sam";
$cmd = "bwa mem $IRMA_ref $fq >$sam";
print SH "$cmd\n\n";

# SAM->BAM
my $new_bam = "$outdir/$name\.bam";
$cmd = "$samtools view -b -o $new_bam $sam";
print SH "$cmd\n\n";

# Sort BAM
my $sort_bam = "$outdir/$name\.sorted.bam";
$cmd = "$samtools sort -o $sort_bam $new_bam";
print SH "$cmd\n\n";

# Index *.sorted.bam
$cmd = "$samtools index $sort_bam";
print SH "$cmd\n\n";


# 统计每个segment数量
my $seg_count = "$outdir/$name\.seg.count.txt";
$cmd = "perl $Bin/scripts/stat_each_segment_reads_count.pl $sam $seg_count";
print SH "$cmd\n\n";


# 基于比对结果进行分型


# 再次比对到分型参考序列


# 变异检测freebayes

# generateConsensus组装一致性序列

# BLAST比对一致性序列.辅助分型


# 汇总结果

close SH;