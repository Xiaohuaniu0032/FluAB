/usr/bin/samtools fastq /data/fulongfei/git_repo/FluAB/data/IonCode_0103_013H3N2_V2_50.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.fastq

bwa mem /data/fulongfei/git_repo/FluAB/database/IRMA/modules/FLU/reference/consensus.fasta /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.fastq >/data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.sam

/usr/bin/samtools view -b -o /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.sam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.sorted.bam

perl /data/fulongfei/git_repo/FluAB/scripts/stat_each_segment_reads_count.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.sam /data/fulongfei/git_repo/FluAB/test/IonCode_0103/IonCode_0103.seg.count.txt
