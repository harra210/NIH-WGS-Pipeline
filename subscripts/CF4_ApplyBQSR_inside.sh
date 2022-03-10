#!/bin/bash
#
BQSR_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp"
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
knownsite="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0.BQSR.DB.bed"
interval_list="/data/Ostrander/Resources/CanFam4_GSD/Intervals/Intervals.list"
#
cd $tmpdir
#
> BQSR_directories.tmp
> BQSR_samplenames.tmp
#
cd $BQSR_DIR
#
find . -maxdepth 2 -name "dedup_*.bam" -printf '%f\n' | sed 's/dedup_//' | sed 's/.bam//' &> "$tmpdir"/BQSR_samplenames.tmp
find $PWD -maxdepth 2 -name "dedup_*.bam" -printf '%h\n' &> "$tmpdir"/BQSR_directories.tmp
#
cd "$tmpdir"
#
IFS=,$'\n' read -d '' -r -a samplename < BQSR_samplenames.tmp
IFS=,$'\n' read -d '' -r -a directories < BQSR_directories.tmp
#
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
declare -a sample
declare -a directory
#
for ((i = 0; i < ${#directory[@]}; i++))
do
	cd "${directory[$i]}"; mkdir -p BQSR/
done
#
cd $homedir
#
for ((i = 0;i < ${#directory[@]}; i++))
do
       echo "cd "${directory[$i]}"; cp dedup_"${sample[$i]}".bam /lscratch/\$SLURM_JOB_ID/; cp dedup_"${sample[$i]}".bam.bai /lscratch/\$SLURM_JOB_ID && gatk --java-options \"-Xmx4G\" ApplyBQSR -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I /lscratch/\$SLURM_JOB_ID/dedup_"${sample[$i]}".bam -XL "$interval_list" -O "${directory[$i]}"/BQSR/"${sample[$i]}"_chrY_BQSR.bam -bqsr-recal-file "${directory[$i]}"/BQSR/"${sample[$i]}"_fullBQSR.reports.list --preserve-qscores-less-than 6 --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30" >> bqsr_ApplyBQSR.swarm
done
#
while read g
do
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" ApplyBQSR -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I /lscratch/\$SLURM_JOB_ID/dedup_"${sample[$i]}".bam -L "$g" -O "${directory[$i]}"/BQSR/"${sample[$i]}"_"$g"_BQSR.bam --bqsr-recal-file "${directory[$i]}"/BQSR/"${sample[$i]}"_fullBQSR.reports.list --preserve-qscores-less-than 6 --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30" >> bqsr_ApplyBQSR.swarm
done
done < /data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list
#
#for ((i = 0;i < ${#directory[@]}; i++))
#do
#	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" ApplyBQSR -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I dedup_"${sample[$i]}".bam -XL "$interval_list" -O "${directory[$i]}"/BQSR/"${sample[$i]}"_chrY_BQSR.bam -bqsr-recal-file "${directory[$i]}"/BQSR/fullBQSR.reports.list --preserve-qscores-less-than 6 --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30" >> bqsr_ApplyBQSR.swarm
#done
#
#head bqsr_pipelinetest.swarm
#read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptA
#while true; do
#        case "$promptA" in
#                [YyEeSs]* ) break ;;
#                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
#                *) echo "Enter yes or no" ;;
#        esac
#done
#
#echo "BQSR Swarm Job ID: "
#
#jobid1=$(swarm -f bqsr_pipelinetest.swarm -g 8 -t 10 --time 2-0 --gres=lscratch:320 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk/BaseRecalibrator/"$SWARM_NAME"_BQSR --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_BaseRecal")
#echo $jobid1
#

