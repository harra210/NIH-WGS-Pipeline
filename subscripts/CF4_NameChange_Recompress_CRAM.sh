#!/bin/bash
SAMPLE_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/"
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
knownsite="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0.BQSR.DB.bed"
interval_list="/data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list"
#
cd $tmpdir
#
> CRAM_directories.tmp
> CRAM_samplenames.tmp
> CRAM_changednames.tmp
> RC_directories.tmp
> RC_samplenames.tmp
#
cd $SAMPLE_DIR
#
#Search the directory for BQSR file to convert to CRAM file
find . -maxdepth 1 -name "*BQSR.bam" -printf '%f\n' | sed 's/_BQSR.bam//' &> "$tmpdir"/CRAM_samplenames.tmp
find $PWD -maxdepth 1 -name "*BQSR.bam" -printf '%h\n' &> "$tmpdir"/CRAM_directories.tmp
#
#Search the directory for gVCF file to be compressed
#find . -maxdepth 2 -name "*_g.vcf.gz" -printf '%f\n' | sed 's/_g.vcf.gz//' &> "$tmpdir"/RC_samplenames.tmp
#find $PWD -maxdepth 2 -name "*g.vcf.gz" -printf '%h\n' &> "$tmpdir"/RC_directories.tmp
#
cd $tmpdir
#Input all of the found files into proper arrays
IFS=,$'\n' read -d '' -r -a samplename < CRAM_samplenames.tmp
IFS=,$'\n' read -d '' -r -a directories < CRAM_directories.tmp
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
declare -a sample
declare -a directory
#
#Section will prompt user to create a name for each sample. This will create a variable that will be overwritten after each iteration.
echo "What is the Ostrander Lab Name for this sample?"
read -ep "Sample Name: " changedname
#
cd $homedir
#
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; cp "${sample[$i]}"_BQSR.bam /lscratch/\$SLURM_JOB_ID/"${sample[$i]}"_BQSR.bam && cp "${sample[$i]}"_g.vcf.gz /lscratch/\$SLURM_JOB_ID/"${sample[$i]}"_g.vcf.gz && mv "${directory[$i]}"/BQSR/"${sample[$i]}"_fullBQSR.reports.list "${directory[$i]}" && gatk --java-options \"-Xmx6G\" PrintReads -R $CanFam4 -I /lscratch/\$SLURM_JOB_ID/"${sample[$i]}"_BQSR.bam -O "$changedname".BQSR.cram -OBM true -OBI false && samtools index -@ \$SLURM_CPUS_PER_TASK -c "$changedname".BQSR.cram && zcat /lscratch/\$SLURM_JOB_ID/"${sample[$i]}"_g.vcf.gz | bgzip -@6 -l 9 -c > "$changedname".g.vcf.gz && tabix -p vcf -f "$changedname".g.vcf.gz && md5sum "$changedname".g.vcf.gz > "$changedname".g.vcf.gz.md5 && rm dedup_"${sample[$i]}".bam && rm dedup_"${sample[$i]}".bam.bai && rm "${sample[$i]}"_BQSR.bam && rm "${sample[$i]}"_BQSR.bai && rm "${sample[$i]}"_g.vcf.gz && rm "${sample[$i]}"_g.vcf.gz.tbi && rm -R HC/ && rm -R BQSR/ && rm sort*.bam" >> BQSR_Recompress.swarm
done
