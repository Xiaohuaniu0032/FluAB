/usr/bin/samtools fastq /data/fulongfei/git_repo/FluAB/data/IonCode_0101_004FluB_V2_50.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.fastq

bwa mem /data/fulongfei/git_repo/FluAB/database/IRMA/modules/FLU/reference/consensus.fasta /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.fastq >/data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.sam

/usr/bin/samtools view -b -o /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.sam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.sorted.bam

perl /data/fulongfei/git_repo/FluAB/scripts/stat_each_segment_reads_count.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.sam /data/fulongfei/git_repo/FluAB/test/IonCode_0101/IonCode_0101.seg.count.txt

