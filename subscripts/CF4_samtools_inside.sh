#!/bin/bash
#echo "What parent directory are your preprocessed files located?"
#read -e -t 30 FILE_DIR
#echo "What do you want to name your base swarm?"
#read -e -t 30 SWARM_NAME
#
FQ_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#> CF4_mergeDedup.swarm
#basedir=$(pwd)
#cd /data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/
#tmpdir=$(pwd)
#
#Reference Genome Variables
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
#
cd $tmpdir
#
> merge_files.tmp
> merge_dir.tmp
> merge_IDs.tmp
> merge_lsfiles.tmp
> merge_samplename.tmp
#
#DEBUG $FILE_DIR
#FILE_DIR="/data/harrisac2/Heidi_TCC/Fastq/Emergency/Test"
cd $FQ_DIR
#
#Finding files in the subdirectories to populate arrays through
#NISC VERSION
find $PWD -maxdepth 2 -name "*.bam" -printf '%f\n' &> "$tmpdir"/merge_files.tmp
#DOG10K AND SRA VERSION
#find . -maxdepth 2 -name "sort*.bam" -printf '%f\n' | sed 's/sort_//' | sed 's/.bam//' &> "$tmpdir"/merge_files.tmp
#
#Finding subdirectories to iterate through
#NISC VERSION
find $PWD -maxdepth 2 -name "*H2T27DSX3*L001.bam" -printf '%h\n' &> "$tmpdir"/merge_dir.tmp
#DOG10K & SRA VERSION
#find $PWD -maxdepth 2 -name "sort*.bam" -printf '%h\n' &> "$tmpdir"/merge_dir.tmp
#
IFS=,$'\n' read -d '' -r -a lsdir < "$tmpdir"/merge_dir.tmp
#
#DEPRECATED LINE - USED FOR PROOF OF CONCEPT
#find . -name "*.bam" -printf '%f\n' | sort -t "_" -k 5 -V | paste -sd ' ' - >> "$tmpdir"/merge_lsfiles.tmp
#
#NISC VERSION -- DOG10K DOES NOT REQUIRE THIS
for ((i = 0; i < ${#lsdir[@]}; i++))
do
	cd "${lsdir[$i]}";find . -name "*.bam" -printf '%f\n' | sort -t "_" -k 5 -V | paste -sd " " - >> "$tmpdir"/merge_lsfiles.tmp
done
#
cd $tmpdir
#Area where files are sorted to properly fix IDs
##NISC VERSION
awk -F '_' '{print $1"_"$2"_"$3}' merge_files.tmp >> merge_IDs.tmp
#DOG10K AND SRA VERSION
#awk '{print $1}' merge_files.tmp >> merge_IDs.tmp
#awk -F '_' '{print $2"_"$3}' merge_files.tmp >> merge_samplename.tmp #DEPRECATED LINE
#NISC VERSION - DOG10K DOES NOT REQUIRE THIS LINE
awk -F '_' '{print $2}' merge_files.tmp >> merge_samplename.tmp
#
#Creating the proper arrays to populate the swarm file. Note Dog10k version only requires the ID array
IFS=,$'\n' read -d '' -r -a lsfiles < "$tmpdir"/merge_lsfiles.tmp
IFS=,$'\n' read -d '' -r -a ID < "$tmpdir"/merge_IDs.tmp 
IFS=,$'\n' read -d '' -r -a sample < "$tmpdir"/merge_samplename.tmp
#echo ${lsdir[@]}
#echo ${lsfiles[*]}
#echo ${ID[@]}
#echo ${sample[@]}
#sleep 30
#
for ((i = 0; i < ${#lsdir[@]}; i++))
#for i in ${lsfiles[*]}
do
#DEFAULT - DO NOT DELETE LINE
	echo "cd ${lsdir[$i]}; samtools merge /lscratch/\$SLURM_JOB_ID/"${ID[$i]}".bam ${lsfiles[$i]} && samtools sort -@ \$SLURM_CPUS_PER_TASK -T /lscratch/\$SLURM_JOB_ID/"${sample[$i]}" -o /lscratch/\$SLURM_JOB_ID/"${ID[$i]}".bam /lscratch/\$SLURM_JOB_ID/"${ID[$i]}".bam && gatk MarkDuplicates I=/lscratch/\$SLURM_JOB_ID/"${ID[$i]}".bam O=dedup_"${sample[$i]}".bam M="${sample[$i]}".metrics.txt REMOVE_DUPLICATES=false ASSUME_SORTED=true TMP_DIR=/lscratch/\$SLURM_JOB_ID && samtools index dedup_"${sample[$i]}".bam" >> "$homedir"/mergeDedup.swarm
#DOG10K AND SRA SAMPLES VERSION - DO NOT DELETE - COMMENT OUT WHEN DEPENDING ON SAMPLE BATCH
#	echo "cd ${lsdir[$i]}; gatk MarkDuplicates I=sort_"${ID[$i]}".bam O=dedup_"${ID[$i]}".bam M="${ID[$i]}".metrics.txt REMOVE_DUPLICATES=false ASSUME_SORTED=true TMP_DIR=/lscratch/\$SLURM_JOB_ID && samtools index dedup_"${ID[$i]}".bam" >> "$homedir"/mergeDedup.swarm
done
#
#cd $homedir
#
#head CF4_mergeDedup.swarm
#
#read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptA
#while true; do
#        case "$promptA" in
#                [YyEeSs]* ) break ;;
#                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
#                *) echo "Enter yes or no" ;;
#        esac
#done
#
#echo "Swarm Job ID: "
#
#jobid1=$(swarm -f CF4_mergeDedup.swarm -g 36 -t 20 --gres=lscratch:350 --time 2-0 --module samtools,GATK/4.2.0.0 --logdir ~/job_outputs/samtools/"$SWARM_NAME"_merge --sbatch "--mail-type=ALL,TIME_LIMIT_90 --job-name "$SWARM_NAME"_Merge")
#echo $jobid1
