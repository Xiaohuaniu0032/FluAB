/usr/bin/samtools fastq /data/fulongfei/git_repo/FluAB/data/IonCode_0104_014H3N2_V2_20.bam >/data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.fastq

bwa mem /data/fulongfei/git_repo/FluAB/database/IRMA/modules/FLU/reference/consensus.fasta /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.fastq >/data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.sam

/usr/bin/samtools view -b -o /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.sam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.sorted.bam

perl /data/fulongfei/git_repo/FluAB/scripts/stat_each_segment_reads_count.pl /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.sam /data/fulongfei/git_repo/FluAB/test/IonCode_0104/IonCode_0104.seg.count.txt

