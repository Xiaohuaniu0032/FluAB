## FluAB

### Influenza A/B genotyping, consensus fasta making and variant calling.




### Usage


#### Methods

1. TMAP uBAM file
2. Genotyping
3. Do variant calling using variantCaller 
4. Generate consensus fasta sequences for each segment


### Test



#### Reference fasta file

We first use IRMA's default reference fasta file, then replace some segments with nextclade's flu segments.

1. For fluA, we use CY121680 (from nextclade) to replace IRMA's default A_HA_H1;
we use CY163680 (from nextclade) to replace IRMA's default A_HA_H3;

2. For fluB, we removed IRMA's default B_HA, then add two segments: B_Victoria_HA for B/V subtype and B_Yamagata_HA for B/Y subtype.


