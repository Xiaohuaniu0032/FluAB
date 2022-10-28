use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin/;

my ($bam,$name,$outdir,$samtools,$bwa,$python2);

GetOptions(
	"bam:s"   =>  \$bam,     # Need
	"n:s"     =>  \$name,    # Need
	"od:s"    =>  \$outdir,  # Need
	"samtools:s"  => \$samtools,
	"bwa:s"       => \$bwa,
	"py2:s"       => \$python2,
	) or die "unknown args\n";


if (not defined $samtools){
	$samtools = "/usr/bin/samtools";
}

if (not defined $bwa){
	$bwa = "/usr/bin/bwa";
}

if (not defined $python2){
	$python2 = "/usr/bin/python2";
}

my $runsh = "$outdir/run\_$name\_fluAB.sh";

open SH, ">$runsh" or die;


if (!-d "$outdir/BWA"){
	`mkdir $outdir/BWA`;
}

print SH "# bam->fastq\n";
# samtools fastq
my $fq = "$outdir/BWA/$name\.fastq";
my $cmd = "$samtools fastq $bam >$fq";
print SH "$cmd\n\n";


# bwa aln
print SH "# bwa align\n";
#my $IRMA_ref = "$Bin/database/IRMA/modules/FLU/reference/consensus.fasta";
my $bwa_ref = "$Bin/database/Update_Ref/BWA_INDEX/FluAB.fasta";
my $sam = "$outdir/BWA/$name\.sam";
$cmd = "bwa mem $bwa_ref $fq >$sam";
print SH "$cmd\n\n";

# SAM->BAM
my $new_bam = "$outdir/BWA/$name\.bam";
$cmd = "$samtools view -b -o $new_bam $sam";
print SH "$cmd\n\n";

# Sort BAM
my $sort_bam = "$outdir/BWA/$name\.sorted.bam";
$cmd = "$samtools sort -o $sort_bam $new_bam";
print SH "$cmd\n\n";

# Index *.sorted.bam
$cmd = "$samtools index $sort_bam";
print SH "$cmd\n\n";


# 统计每个segment数量
print SH "# Seg count\n";
my $seg_count = "$outdir/$name\.seg.count.txt";
$cmd = "perl $Bin/scripts/stat_each_segment_reads_count.pl $sam $seg_count";
print SH "$cmd\n\n";

# genotype
print SH "# Genotyping\n";
my $gt_results = "$outdir/$name\.genotype.txt";
$cmd = "perl $Bin/scripts/fluAB_genotype.pl $seg_count $gt_results";
print SH "$cmd\n\n";



print SH "# TMAP\n";
# TMAP align uBAM
if (!-d "$outdir/TMAP"){
	`mkdir $outdir/TMAP`;
}
my $tmap_ref = "$Bin/database/Update_Ref/FluAB/FluAB.fasta";
my $tmap = "$Bin/bin/variantCaller/bin/tmap";
my $aln_bam = "$outdir/TMAP/$name\.bam";
$cmd = "$tmap mapall -f $tmap_ref -r $bam -o 2 -n 10 -i bam -u -v -q 50000 --prefix-exclude 5 -Y -J 25 --end-repair 15 --context stage1 map4 \>$aln_bam";
print SH "$cmd\n\n";

# samtools sort
$sort_bam = "$outdir/TMAP/$name\.sorted.bam";
$cmd = "$samtools sort -o $sort_bam $aln_bam";
print SH "$cmd\n\n";

# index
$cmd = "$samtools index $sort_bam";
print SH "$cmd\n\n";


print SH "# variantCaller\n";
# variantCaller
# http://10.69.40.7/report/493/#SARS_CoV_2_variantCaller-section
if (!-d "$outdir/variantCaller"){
	`mkdir $outdir/variantCaller`;
}

my $tvc = "$Bin/bin/variantCaller/bin/tvc";
my $sse_dir = "$Bin/bin/variantCaller/share/TVC/sse";
my $target = "$Bin/scripts/FluAB.target.bed";
my $json = "$Bin/bin/variantCaller/pluginMedia/configs/germline_low_stringency.json";
$cmd = "$tvc --output-dir $outdir/variantCaller --reference $tmap_ref --input-bam $sort_bam --num-threads 12 --target-file $target --trim-ampliseq-primers off --parameters-file $json --error-motifs-dir $sse_dir";
print SH "$cmd\n\n";

my $tvcutils = "$Bin/bin/variantCaller/bin/tvcutils";
my $novel_tvc_vcf = "$outdir/variantCaller/small_variants.vcf";
my $TSVC_variants_vcf = "$outdir/variantCaller/TSVC_variants.vcf";
my $novel_assembly_vcf = "$outdir/variantCaller/indel_assembly.vcf";
my $tvc_metrics = "$outdir/variantCaller/tvc_metrics.json";
my $depth_file = "$outdir/variantCaller/depth.txt";

$cmd = "$tvcutils unify_vcf --novel-tvc-vcf $novel_tvc_vcf --output-vcf $TSVC_variants_vcf --reference-fasta $tmap_ref --novel-assembly-vcf $novel_assembly_vcf --tvc-metrics $tvc_metrics --input-depth $depth_file --min-depth 10";
print SH "$cmd\n\n";


print SH "# generateConsensus\n";
# generateConsensus
if (!-d "$outdir/generateConsensus"){
	`mkdir $outdir/generateConsensus`;
}

my $gvcf_to_fasta = "$Bin/bin/generateConsensus/gvcf_to_fasta.py";
my $gvcf = "$outdir/variantCaller/TSVC_variants.genome.vcf";
my $cons_fa = "$outdir/generateConsensus/$name\_consensus.fasta";
$cmd = "$python2 $gvcf_to_fasta -m 1 -n 0.5 -p 0.6 -v $gvcf -o $cons_fa -c B_Yamagata_HA -d 10 -r $target";
print SH "$cmd\n\n";


# -m: MAJOR_ALLELE_ONLY
# -n: The minimum variant frequency of a variant that is not a HP-INDEL to put it in the FASTA.
# -p: The minimum variant frequency of a HP-INDEL to put it in the FASTA.
# -a: ALIAS_CONTIG (Optional)
# -c: PROCESS_CONTIG (Required) [Process the contig in input_fasta_file only]

# http://10.69.40.7/report/564/#generateConsensus-section


# -o: --output-type [the output type. 0-SAM 1-BAM(compressed) 2-BAM(uncompressed)]
# -n: --num-threads
# -u: --rand-read-name 
# -v: --verbose [print verbose progress information]
# -q: --reads-queue-size [the queue size for the reads]
# --prefix-exclude: specify how many letters of prefix of name to be excluded when do randomize by name
# -Y: --sam-flowspace-tags [include flow space specific SAM tags when available]
# -J: --max-adapter-bases-for-soft-clipping [specifies to perform 3' soft-clipping (via -g) if at most this # of adapter bases were found (ZB tag)]
# --end-repair: specifies to perform end repair [>2 - specify %% Mismatch above which to trim end alignment]
# --context: realign with context-dependent gap scores



# 基于比对结果进行分型


# 再次比对到分型参考序列


# 变异检测freebayes

# generateConsensus组装一致性序列

# BLAST比对一致性序列.辅助分型


# 汇总结果

close SH;