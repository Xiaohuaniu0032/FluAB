# bam->fastq
/usr/bin/samtools fastq /data/fulongfei/git_repo/FluAB/data/Buffalo/FluB/IonCode_0101_004FluB_V2_50.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.fastq

# bwa align
bwa mem /data/fulongfei/git_repo/FluAB/database/Update_Ref/BWA_INDEX/FluAB.fasta /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.fastq >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.sam

/usr/bin/samtools view -b -o /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.sam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.sorted.bam

# Seg count
perl /data/fulongfei/git_repo/FluAB/scripts/stat_each_segment_reads_count.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.sam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.seg.count.txt

# Genotyping
perl /data/fulongfei/git_repo/FluAB/scripts/fluAB_genotype.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.seg.count.txt /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.genotype.txt

# samtools depth
/usr/bin/samtools depth -a -b /data/fulongfei/git_repo/FluAB/scripts/FluAB.target.bed /data/fulongfei/git_repo/FluAB/test/IonCode_0101/BWA/IonCode_0101.sorted.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.samtools_depth.txt

# summary table
perl /data/fulongfei/git_repo/FluAB/scripts/summary_table.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.samtools_depth.txt /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.genotype.txt /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.summary_table.xls

# TMAP
/data/fulongfei/git_repo/FluAB/bin/variantCaller/bin/tmap mapall -f /data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB/FluAB.fasta -r /data/fulongfei/git_repo/FluAB/data/Buffalo/FluB/IonCode_0101_004FluB_V2_50.bam -o 2 -n 10 -i bam -u -v -q 50000 --prefix-exclude 5 -Y -J 25 --end-repair 15 --context stage1 map4 >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/TMAP/IonCode_0101.bam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0101/TMAP/IonCode_0101.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/TMAP/IonCode_0101.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0101/TMAP/IonCode_0101.sorted.bam

# variantCaller
/data/fulongfei/git_repo/FluAB/bin/variantCaller/bin/tvc --output-dir /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller --reference /data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB/FluAB.fasta --input-bam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/TMAP/IonCode_0101.sorted.bam --num-threads 12 --target-file /data/fulongfei/git_repo/FluAB/scripts/FluAB.target.bed --trim-ampliseq-primers off --parameters-file /data/fulongfei/git_repo/FluAB/bin/variantCaller/pluginMedia/configs/germline_low_stringency.json --error-motifs-dir /data/fulongfei/git_repo/FluAB/bin/variantCaller/share/TVC/sse

/data/fulongfei/git_repo/FluAB/bin/variantCaller/bin/tvcutils unify_vcf --novel-tvc-vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/small_variants.vcf --output-vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/TSVC_variants.vcf --reference-fasta /data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB/FluAB.fasta --novel-assembly-vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/indel_assembly.vcf --tvc-metrics /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/tvc_metrics.json --input-depth /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/depth.txt --min-depth 10

# generateConsensus
perl /data/fulongfei/git_repo/FluAB/scripts/generateConsensus.pl IonCode_0101 /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/TSVC_variants.genome.vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.genotype.txt /data/fulongfei/git_repo/FluAB/scripts/FluAB.target.bed /usr/bin/python2 /data/fulongfei/git_repo/FluAB/test/IonCode_0101/generateConsensus

# extract HA vcf for annnot
perl /data/fulongfei/git_repo/FluAB/scripts/extract_HA_variants.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.genotype.txt /data/fulongfei/git_repo/FluAB/test/IonCode_0101/variantCaller/TSVC_variants.vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101_HA.vcf

# annot HA var
/data/fulongfei/git_repo/FluAB/bin/jre1.8.0_351/bin/java -jar /data/fulongfei/git_repo/FluAB/bin/snpEff/snpEff.jar -c /data/fulongfei/git_repo/FluAB/bin/snpEff/snpEff.config FluAB /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101_HA.vcf >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.snpEff.annot.vcf

# Final variant annot file
perl /data/fulongfei/git_repo/FluAB/scripts/format_snpEff.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.snpEff.annot.vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.variants.snpEff.xls

