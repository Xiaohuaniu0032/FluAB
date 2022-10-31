# bam->fastq
/usr/bin/samtools fastq /data/fulongfei/git_repo/FluAB/data/Buffalo/FluA/IonCode_0103_013H3N2_V2_50.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.fastq

# bwa align
bwa mem /data/fulongfei/git_repo/FluAB/database/Update_Ref/BWA_INDEX/FluAB.fasta /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.fastq >/data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.sam

/usr/bin/samtools view -b -o /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.sam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.sorted.bam

# Seg count
perl /data/fulongfei/git_repo/FluAB/scripts/stat_each_segment_reads_count.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.sam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.seg.count.txt

# Genotyping
perl /data/fulongfei/git_repo/FluAB/scripts/fluAB_genotype.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.seg.count.txt /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.genotype.txt

# samtools depth
/usr/bin/samtools depth -a -b /data/fulongfei/git_repo/FluAB/scripts/FluAB.target.bed /data/fulongfei/git_repo/FluAB/test/IonCode_0103/BWA/IonCode_0103.sorted.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.samtools_depth.txt

# TMAP
/data/fulongfei/git_repo/FluAB/bin/variantCaller/bin/tmap mapall -f /data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB/FluAB.fasta -r /data/fulongfei/git_repo/FluAB/data/Buffalo/FluA/IonCode_0103_013H3N2_V2_50.bam -o 2 -n 10 -i bam -u -v -q 50000 --prefix-exclude 5 -Y -J 25 --end-repair 15 --context stage1 map4 >/data/fulongfei/git_repo/FluAB/test/IonCode_0103/TMAP/IonCode_0103.bam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0103/TMAP/IonCode_0103.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/TMAP/IonCode_0103.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0103/TMAP/IonCode_0103.sorted.bam

# variantCaller
/data/fulongfei/git_repo/FluAB/bin/variantCaller/bin/tvc --output-dir /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller --reference /data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB/FluAB.fasta --input-bam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/TMAP/IonCode_0103.sorted.bam --num-threads 12 --target-file /data/fulongfei/git_repo/FluAB/scripts/FluAB.target.bed --trim-ampliseq-primers off --parameters-file /data/fulongfei/git_repo/FluAB/bin/variantCaller/pluginMedia/configs/germline_low_stringency.json --error-motifs-dir /data/fulongfei/git_repo/FluAB/bin/variantCaller/share/TVC/sse

/data/fulongfei/git_repo/FluAB/bin/variantCaller/bin/tvcutils unify_vcf --novel-tvc-vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller/small_variants.vcf --output-vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller/TSVC_variants.vcf --reference-fasta /data/fulongfei/git_repo/FluAB/database/Update_Ref/FluAB/FluAB.fasta --novel-assembly-vcf /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller/indel_assembly.vcf --tvc-metrics /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller/tvc_metrics.json --input-depth /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller/depth.txt --min-depth 10

# generateConsensus
# /usr/bin/python2 /data/fulongfei/git_repo/FluAB/bin/generateConsensus/gvcf_to_fasta.py -m 1 -n 0.5 -p 0.6 -v /data/fulongfei/git_repo/FluAB/test/IonCode_0103/variantCaller/TSVC_variants.genome.vcf -o /data/fulongfei/git_repo/FluAB/test/IonCode_0103/generateConsensus/IonCode_0103_consensus.fasta -c B_Yamagata_HA -d 10 -r /data/fulongfei/git_repo/FluAB/scripts/FluAB.target.bed

