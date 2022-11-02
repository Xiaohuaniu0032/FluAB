use strict;
use warnings;


my ($HA_vcf,$ref_fa,$CDS_file,$outfile) = @ARGV;

my %codon_list;

$codon_list{"ATT"} = "I";
$codon_list{"ATC"} = "I";
$codon_list{"ATA"} = "I";

$codon_list{"CTT"} = "L";
$codon_list{"CTC"} = "L";
$codon_list{"CTA"} = "L";
$codon_list{"CTG"} = "L";
$codon_list{"TTA"} = "L";
$codon_list{"TTG"} = "L";

$codon_list{"GTT"} = "V";
$codon_list{"GTC"} = "V";
$codon_list{"GTA"} = "V";
$codon_list{"GTG"} = "V";

$codon_list{"TTT"} = "F";
$codon_list{"TTC"} = "F";

$codon_list{"ATG"} = "M";

$codon_list{"TGT"} = "C";
$codon_list{"TGC"} = "C";

$codon_list{"GCT"} = "A";
$codon_list{"GCC"} = "A";
$codon_list{"GCA"} = "A";
$codon_list{"GCG"} = "A";

$codon_list{"GGT"} = "G";
$codon_list{"GGC"} = "G";
$codon_list{"GGA"} = "G";
$codon_list{"GGG"} = "G";

$codon_list{"CCT"} = "P";
$codon_list{"CCC"} = "P";
$codon_list{"CCA"} = "P";
$codon_list{"CCG"} = "P";

$codon_list{"ACT"} = "T";
$codon_list{"ACC"} = "T";
$codon_list{"ACA"} = "T";
$codon_list{"ACG"} = "T";

$codon_list{"TCT"} = "S";
$codon_list{"TCC"} = "S";
$codon_list{"TCA"} = "S";
$codon_list{"TCG"} = "S";
$codon_list{"AGT"} = "S";
$codon_list{"AGC"} = "S";

$codon_list{"TAT"} = "Y";
$codon_list{"TAC"} = "Y";

$codon_list{"TGG"} = "W";

$codon_list{"CAA"} = "Q";
$codon_list{"CAG"} = "Q";

$codon_list{"AAT"} = "N";
$codon_list{"AAC"} = "N";

$codon_list{"CAT"} = "H";
$codon_list{"CAC"} = "H";

$codon_list{"GAA"} = "E";
$codon_list{"GAG"} = "E";

$codon_list{"GAT"} = "D";
$codon_list{"GAC"} = "D";

$codon_list{"AAA"} = "K";
$codon_list{"AAG"} = "K";

$codon_list{"CGT"} = "R";
$codon_list{"CGC"} = "R";
$codon_list{"CGC"} = "R";
$codon_list{"CGG"} = "R";
$codon_list{"AGA"} = "R";
$codon_list{"AGG"} = "R";

$codon_list{"TAA"} = "Stop";
$codon_list{"TAG"} = "Stop";
$codon_list{"TGA"} = "Stop";


# 判断VCF行数.如果分型失败,VCF只有1行header
my $vcf_line = (split /\s/, `wc -l $HA_vcf`)[0];


# 读取CDS.txt
# A_HA_H1,CY121680,21..1721,codon_start=1
# A_HA_H3,CY163680,18..1718,codon_start=1
# B_Victoria_HA,KX058884,34..1791,codon_start=1
# B_Yamagata_HA,JN993010,1..1755,codon_start=1

my %ha_cds_info;
open CDS, "$CDS_file" or die;
while (<CDS>){
	chomp;
	my @arr = split /\,/, $_;
	my $ha = $arr[0];
	my $codon_start = (split /\=/, $arr[3])[1]; # may be 1/2/3
	$ha_cds_info{$ha} = "$arr[2]\t$codon_start";
}
close CDS;

# 读取参考序列
my %ref_fasta;




# 当前HA片段的ref fasta




# 当前HA片段的cds信息


my $cds_seq = substr();

my $cds_seq_len = length($cds_seq);
my $aa_num = $cds_seq_len / 3;

my $last_idx = $cds_seq_len - 3; # 0-based



if ($vcf_line >= 2){
	#存在变异位点

	open VCF, "$HA_vcf" or die;
	<VCF>;
	while (<VCF>){
		chomp;
		my @arr = split /\t/;
		my $chr = $arr[0];
		my $pos = $arr[1];
		my $ref = $arr[3];
		my $alt = $arr[]
	}
	my $i = 0;
	if ($i <= $last_idx){


		$i += 3;
	}


}
