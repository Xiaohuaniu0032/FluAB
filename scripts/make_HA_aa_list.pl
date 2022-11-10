use strict;
use warnings;


my ($gt_file,$codon_table_file,$ref,$cds_file,$outfile) = @ARGV;

open O, ">$outfile" or die;
print O "Protein\tAA.Pos\tDNA.Pos\tDNA\tAA\tAA.Long\n";


# 读取HA分型
my $this_seg;
open GT, "$gt_file" or die;
my $gt_line = <GT>;
my @gt_info = split /\:/, $gt_line;
my $gt = $gt_info[1];
if ($gt ne "NA"){
	my $line = <GT>;
	my @line = split /\t/, $line;
	$this_seg = $line[0];
}else{
	$this_seg = "NA";
}

if ($this_seg eq "NA"){
	exit 1;
}

# 读取codon table
my %codon_aa;
open IN, "$codon_table_file" or die;
while (<IN>){
        chomp;
        next if /^\#/;
        next if /^$/;
        next if /^Amino/; # skip header
        # Isoleucine      I       ATT, ATC, ATA
        my @arr = split /\t/;
        my $aa  = "$arr[1]\t$arr[0]";
        my $dna = $arr[2];
        my @dna = split /\,/, $dna;
        for my $dna (@dna){
                $dna =~ s/^\s+//;
                $codon_aa{$dna} = $aa; # AAT => "I \t Isoleucine"
        }
}
close IN;



# 读取ref
my %ha_fasta_tmp;
my $seq_name;
open IN, "$ref" or die;
while (<IN>){
	chomp;
	next if /^$/;
	if (/^\>/){
		$seq_name = $_;
		$seq_name =~ s/^\>//;
	}else{
		push @{$ha_fasta_tmp{$seq_name}}, $_;
	}
}
close IN;

my %ha_fasta_final;
foreach my $header (keys %ha_fasta_tmp){
	my @seq = @{$ha_fasta_tmp{$header}};
	my $seq = join("",@seq);
	$ha_fasta_final{$header} = $seq;
}


# 该HA对应的fasta序列
my $seq = $ha_fasta_final{$this_seg};
my $seq_len = length($seq);


# 读取CDS.txt
my %cds_info;
open CDS, "$cds_file" or die;
while (<CDS>){
	chomp;
	my @arr = split /\,/, $_;
	my $seg = $arr[0];
	my $pos = $arr[2];
	my @pos_info = split /\_/, $pos;
	my $cds_start = $pos_info[0];
	my $cds_end   = $pos_info[1];

	$cds_info{$seg} = "$cds_start\t$cds_end";
}
close CDS;


# 该HA片段的CDS start pos
my $this_seg_pos_info = $cds_info{$this_seg};
my @this_seg_pos_info = split /\t/, $this_seg_pos_info;


# 起始AA
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3410141/
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6069205/

# IAV: Signal peptide (17 amino acids)
# IBV: the signal peptide, the distal ∼15 amino acids of the ectodomain

my $start_pos;
if ($this_seg =~ /A_HA/){
	$start_pos = $this_seg_pos_info[0] + 51;
}else{
	# B_Victoria_HA / B_Yamagata_HA
	# https://www.eurosurveillance.org/content/10.2807/1560-7917.ES.2020.25.41.1900652
	# K162/N163/D164
	$start_pos = $this_seg_pos_info[0] + 45;
}

# 终止AA
my $end_pos;
if ($this_seg_pos_info[1] ne "X"){
	$end_pos = $this_seg_pos_info[1];
}else{
	$end_pos = $seq_len;
}



my $ha_aa_len = $end_pos - $start_pos + 1;
my $aa_num = $ha_aa_len / 3; # 编码AA个数
print "$this_seg\t$aa_num\(AA\)\n";

my $idx = 0;
my $POS;
while ($idx < $aa_num){
	$POS = $start_pos + $idx * 3 - 1;
	my $ref_start = $POS + 1;
	my $ref_end   = $ref_start + 2;
	my $NT_region = "$ref_start\_$ref_end";
	my $NT = substr($seq,$POS,3);
	my $AA = $codon_aa{$NT};
	my @AA = split /\t/, $AA;
	$idx += 1;
	print O "$this_seg\t$idx\t$NT_region\t$NT\t$AA[0]\t$AA[1]\n";
}
close O;





