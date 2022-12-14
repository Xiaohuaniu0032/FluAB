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


# samtools depth
print SH "# samtools depth\n";
my $samtools_depth_file = "$outdir/$name\.samtools_depth.txt";
my $target = "$Bin/scripts/FluAB.target.bed";
$cmd = "$samtools depth -a -b $target $sort_bam \>$samtools_depth_file";
print SH "$cmd\n\n";

# summary table
print SH "# summary table\n";
my $summary_table = "$outdir/$name\.summary_table.xls";
$cmd = "perl $Bin/scripts/summary_table.pl $samtools_depth_file $gt_results $summary_table";
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
my $json = "$Bin/bin/variantCaller/pluginMedia/configs/germline_low_stringency.20221108.json";
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

my $gvcf = "$outdir/variantCaller/TSVC_variants.genome.vcf";

$cmd = "perl $Bin/scripts/generateConsensus.pl $name $gvcf $gt_results $target $python2 $outdir/generateConsensus";
print SH "$cmd\n\n";


# 提取HA序列VCF
print SH "# extract HA vcf\n";
my $HA_vcf_file = "$outdir/$name\_HA.vcf";
$cmd = "perl $Bin/scripts/extract_HA_variants.pl $gt_results $TSVC_variants_vcf $HA_vcf_file";
print SH "$cmd\n\n";


# 注释HA变异位点
#print SH "# annot HA var\n";
my $annot_vcf = "$outdir/$name\.snpEff.annot.vcf";
my $java = "$Bin/bin/jre1.8.0_351/bin/java";
$cmd = "$java -jar $Bin/bin/snpEff/snpEff.jar -c $Bin/bin/snpEff/snpEff.config FluAB $HA_vcf_file >$annot_vcf";
#print SH "$cmd\n\n";


# 提取HA片段AA坐标信息用于后续注释
print SH "# extract HA AA pos info\n";
my $aa_list = "$outdir/$name\.HA.aa.list";
$cmd = "perl $Bin/scripts/make_HA_aa_list.pl $gt_results $Bin/codon.list $bwa_ref $Bin/CDS.txt $aa_list";
print SH "$cmd\n\n";

# 格式化注释文件.展示变异位点注释详细信息.
print SH "\# Final variant annot file\n";
my $var_annot_file = "$outdir/$name\.variants.snpEff.xls";
$cmd = "perl $Bin/scripts/format_snpEff.pl $annot_vcf $var_annot_file";
#print SH "$cmd\n\n";



# http://gmod.org/wiki/GFF3
# https://pcingola.github.io/SnpEff/se_build_db_gff_gtf/#gff-genome-sequence
# https://pcingola.github.io/SnpEff/se_build_db/


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


close SH;

`chmod 755 $runsh`;