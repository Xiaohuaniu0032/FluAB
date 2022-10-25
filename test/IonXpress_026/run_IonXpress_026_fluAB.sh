/usr/bin/samtools fastq /data/fulongfei/git_repo/FluAB/data/MY_FluB_IonXpress_026.bam >/data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.fastq

bwa mem /data/fulongfei/git_repo/FluAB/database/IRMA/modules/FLU/reference/consensus.fasta /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.fastq >/data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.sam

/usr/bin/samtools view -b -o /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.bam /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.sam

/usr/bin/samtools sort -o /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.sorted.bam /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.bam

/usr/bin/samtools index /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.sorted.bam

perl /data/fulongfei/git_repo/FluAB/scripts/stat_each_segment_reads_count.pl /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.sam /data/fulongfei/git_repo/FluAB/test/IonXpress_026/IonXpress_026.seg.count.txt

