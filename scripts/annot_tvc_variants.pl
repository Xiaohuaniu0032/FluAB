use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use FindBin qw/$Bin/;
use List::Util qw(sum);

my ($freebayes_var_xls_file,$name,$drug_aa_list_file,$annot_outfile);

GetOptions(
	"in:s"         => \$freebayes_var_xls_file,   # Need
	"n:s"          => \$name,                     # Need
	"aalist:s"     => \$drug_aa_list_file,        # Need
	"o:s"          => \$annot_outfile,            # Need
	) or die "unknow args\n";


my $outdir = dirname($annot_outfile);
my $log = "$outdir/$name\.annot.log.txt";
open LOG, ">$log" or die;

my $chr = "K03455.1";

my %codon_list; # /data/fulongfei/git_repo/HIVDrug/codon.list
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

my @drug_aa; # by order
my %drug_aa;

open O, ">$annot_outfile" or die;
print O "Sample\tChr\tProtein\tAA.Pos\tDNA.Pos\tRef_codon\tRef_AA_short\tRef_AA_long\tAlt_codon\tAlt_AA\tAlt_AA_depth\tTotal_AA_depth\tAlt_AA_Freq\n";

#Protein AA.Pos  DNA.Pos DNA     AA      AA.Long
#Protease        1       2253-2255       CCT     P       Proline
#Protease        2       2256-2258       CAG     Q       Glutamine
#Protease        3       2259-2261       GTC     V       Valine
#Protease        4       2262-2264       ACT     T       Threonine
#Protease        5       2265-2267       CTT     L       Leucine
#Protease        6       2268-2270       TGG     W       Tryptophan
#Protease        7       2271-2273       CAA     Q       Glutamine
#Protease        8       2274-2276       CGA     R       Arginine
#Protease        9       2277-2279       CCC     P       Proline
#Protease        10      2280-2282       CTC     L       Leucine
#Protease        11      2283-2285       GTC     V       Valine
#Protease        12      2286-2288       ACA     T       Threonine
#Protease        13      2289-2291       ATA     I       Isoleucine
#Protease        14      2292-2294       AAG     K       Lysine
#Protease        15      2295-2297       ATA     I       Isoleucine


open AA, "$drug_aa_list_file" or die;
<AA>;
while (<AA>){
	chomp;
	my @arr = split /\t/;
	my $val = join("\t",@arr);
	push @drug_aa, $val;
}
close AA;



#IonCode_0101    K03455.1        2258    GG      AA      6303    6304    NA      NA      1.00
#IonCode_0101    K03455.1        2282    CGTCACAATAAAGAT TGTTACCATAAAGAT 1785    1867    NA      NA      0.96
#IonCode_0101    K03455.1        2306    ACTAAA  ATTAAG  454     5686    NA      NA      0.08
#IonCode_0101    K03455.1        2306    ACTAAA  ATTAAA  5009    5686    NA      NA      0.88
#IonCode_0101    K03455.1        2315    A       G       381     4601    NA      NA      0.08
#IonCode_0101    K03455.1        2327    T       C       393     4954    NA      NA      0.08
#IonCode_0101    K03455.1        2362    G       A       4474    4541    NA      NA      0.99
#IonCode_0101    K03455.1        2372    AAG     GAA     5642    5682    NA      NA      0.99


# 2258: ['2258:GG:AA:6303:6304:1.00']
# 2282: ['2282:CGTCACAATAAAGAT:TGTTACCATAAAGAT:1785:1867:0.96']
# 2306: ['2306:ACTAAA:ATTAAG:454:5686:0.08']
# 2306: ['2306:ACTAAA:ATTAAA:5009:5686:0.88']
# 2315: ['2315:A:G:381:4601:0.08']

my @var_list;
open VAR, "$freebayes_var_xls_file" or die;
<VAR>;
while (<VAR>){
	chomp;
	my @arr = split /\t/;
	my $var = "$arr[2]\:$arr[3]\:$arr[4]\:$arr[5]\:$arr[6]\:$arr[-1]";
	push @var_list, $var;
}
close VAR;

for my $pol_aa (@drug_aa){
	#print "$pol_aa\n";
	my @val = split /\t/, $pol_aa;
	my $pos = $val[2]; # 2253-2255
	my @pos = split /\-/, $pos;
	
	my $ref_codon = $val[3]; # CCT
	my @ref_codon = split //, $ref_codon;
	my $first_ref_base = $ref_codon[0];
	my $second_ref_base = $ref_codon[1];
	my $third_ref_base = $ref_codon[2];
	
	my $aa = $val[4]; # P

	my $first_codon_pos = $pos[0];
	my $second_codon_pos = $first_codon_pos + 1;
	my $third_codon_pos = $first_codon_pos + 2;

	#print "pol_aa: $pol_aa\n";
	#print "pol_aa_first: $first_codon_pos\n";
	#print "pol_aa_second: $second_codon_pos\n";
	#print "pol_aa_third: $third_codon_pos\n";

	for my $var (@var_list){
		#print "$var\n";
		# 2258: ['2258:GG:AA:6303:6304:1.00']
		# 2282: ['2282:CGTCACAATAAAGAT:TGTTACCATAAAGAT:1785:1867:0.96']
		# 2306: ['2306:ACTAAA:ATTAAG:454:5686:0.08']
		# 2306: ['2306:ACTAAA:ATTAAA:5009:5686:0.88']
		# 2315: ['2315:A:G:381:4601:0.08']
		my @var = split /\:/, $var;
		
		my $ref_allele = $var[1];
		my $ref_allele_len = length($ref_allele);
		
		my $alt_allele = $var[2];
		my $alt_allele_len = length($alt_allele);

		my $alt_depth = $var[3];
		
		my $total_depth = $var[-2];
		my $alt_freq = $var[-1];

		my $start_pos = $var[0];
		my $end_pos = $start_pos + $ref_allele_len - 1;

		my @alt_base = split //, $alt_allele;

		my %alt_pos;
		for my $pos ($start_pos..$end_pos){
			$alt_pos{$pos} = 1;
		}



		my @alt_codon;
		if (exists $alt_pos{$first_codon_pos} and exists $alt_pos{$second_codon_pos} and exists $alt_pos{$third_codon_pos}){
			# 突变完整包含该AA codon
			
			# Protease        93      2529-2531       ATT     I       Isoleucine
			# Protease        94      2532-2534       GGT     G       Glycine
			# IonCode_0101    K03455.1        2529    ATTGGTTGC       CTCGGGTGT       173     3436    NA      NA      0.05
			# 2529,2537

			my $idx = 0;
			for my $alt_base (@alt_base){
				my $p = $start_pos + $idx;
				if ($p == $first_codon_pos){
					push @alt_codon, $alt_base;
				}
				if ($p == $second_codon_pos){
					push @alt_codon, $alt_base;
				}
				if ($p == $third_codon_pos){
					push @alt_codon, $alt_base;
				}
				$idx += 1;
			}
		}elsif (exists $alt_pos{$first_codon_pos} and !exists $alt_pos{$second_codon_pos} and !exists $alt_pos{$third_codon_pos}){
			# 突变只包含AA codon 第1位
			
			# Protease        3       2259-2261       GTC     V       Valine
			# IonCode_0101    K03455.1        2258    GG      AA      6303    6304    NA      NA      1.00
			
			my $idx = 0;
			for my $alt_base (@alt_base){
				my $p = $start_pos + $idx;
				if ($p == $first_codon_pos){
					push @alt_codon, $alt_base;
				}
				$idx += 1;
			}
			push @alt_codon, $second_ref_base;
			push @alt_codon, $third_ref_base;
		}elsif (!exists $alt_pos{$first_codon_pos} and exists $alt_pos{$second_codon_pos} and !exists $alt_pos{$third_codon_pos}){
			# 突变只包含AA codon 第2位
			
			# Protease        37      2361-2363       AGT     S       Serine
			# IonCode_0101    K03455.1        2362    G       A       4474    4541    NA      NA      0.99
			push @alt_codon, $first_ref_base;
			
			my $idx = 0;
			for my $alt_base (@alt_base){
				my $p = $start_pos + $idx;
				if ($p == $second_codon_pos){
					push @alt_codon, $alt_base;
				}
				$idx += 1;
			}
			push @alt_codon, $third_ref_base;
		}elsif (!exists $alt_pos{$first_codon_pos} and !exists $alt_pos{$second_codon_pos} and exists $alt_pos{$third_codon_pos}){
			# 突变只包含AA codon 第3位
			
			# Protease        2       2256-2258       CAG     Q       Glutamine
			# IonCode_0101    K03455.1        2258    GG      AA      6303    6304    NA      NA      1.00
			push @alt_codon, $first_ref_base;
			push @alt_codon, $second_ref_base;

			my $idx = 0;
			for my $alt_base (@alt_base){
				my $p = $start_pos + $idx;
				if ($p == $third_codon_pos){
					push @alt_codon, $alt_base;
				}
				$idx += 1;
			}
		}elsif (exists $alt_pos{$first_codon_pos} and exists $alt_pos{$second_codon_pos} and !exists $alt_pos{$third_codon_pos}){
			# 突变只包含AA codon 1/2位
			
			# Protease        41      2373-2375       AGA     R       Arginine
			# IonCode_0101    K03455.1        2372    AAG     GAA     5642    5682    NA      NA      0.99
			my $idx = 0;
			for my $alt_base (@alt_base){
				my $p = $start_pos + $idx;
				if ($p == $first_codon_pos){
					push @alt_codon, $alt_base;
				}
				if ($p == $second_codon_pos){
					push @alt_codon, $alt_base;
				}
				$idx += 1;
			}
			push @alt_codon, $third_ref_base;
		}elsif(!exists $alt_pos{$first_codon_pos} and exists $alt_pos{$second_codon_pos} and exists $alt_pos{$third_codon_pos}){
			# 突变只包含AA codon 2/3位
			
			# Protease        71      2463-2465       GCT     A       Alanine
			# IonCode_0101    K03455.1        2464    CT      TC      529     7237    NA      NA      0.07
			push @alt_codon, $first_ref_base;
			my $idx = 0;
			for my $alt_base (@alt_base){
				my $p = $start_pos + $idx;
				if ($p == $second_codon_pos){
					push @alt_codon, $alt_base;
				}
				if ($p == $third_codon_pos){
					push @alt_codon, $alt_base;
				}
				$idx += 1;
			}
		}else{
			#print "[Warnings:Skip] $pol_aa NOT covered by $var\n";
		}

		if (@alt_codon){
			my $alt_codon = join("",@alt_codon);
			next if ($alt_codon eq $ref_codon);
			if ($alt_codon eq $ref_codon){
				print LOG "[Skip]: alt_codon $alt_codon Same as ref_codon: $ref_codon\n";
				next;
			}
			#print "[Matched_variants]: $var\n";
			#print "[Final_codon]: $alt_codon\n";
			print LOG "[Matched_variants]: $var\n";
			print LOG "[Final_codon]: $alt_codon\n";
			my $alt_AA = $codon_list{$alt_codon};
			#print "$alt_codon\t$alt_AA\n";
			print O "$name\t$chr\t$pol_aa\t$alt_codon\t$alt_AA\t$alt_depth\t$total_depth\t$alt_freq\n";
		}
	}
}
close O;
close LOG;
