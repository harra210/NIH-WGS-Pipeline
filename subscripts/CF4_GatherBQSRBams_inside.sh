#!/bin/bash
BQSR_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/"
#
cd $tmpdir
#
> BQSR_samplenames.tmp
> BQSR_directories.tmp
> BQSR_sampletables.tmp
> BQSR_directorytables.tmp
#
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
interval_list="/data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list"
PREFIX="-I "
#
cd $BQSR_DIR
#
#Finding Table files
find . -mindepth 2 -maxdepth 3 -name "*BQSR.bam" -printf '%f\n' &> "$tmpdir"/BQSR_sampletables.tmp
find $PWD -maxdepth 3 -name "*chrY*BQSR.bam" -printf '%h\n' &> "$tmpdir"/BQSR_directorytables.tmp
#
#Finding Dedup Bams
#cd ../
#bqsr_base=$(pwd)
find . -maxdepth 2 -name "dedup_*.bam" -printf '%f\n' | sed 's/dedup_//' | sed 's/.bam//' &> "$tmpdir"/BQSR_samplenames.tmp
find $PWD -maxdepth 2 -name "dedup_*.bam" -printf '%h\n' &> "$tmpdir"/BQSR_directories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' -r -a samples < BQSR_samplenames.tmp
IFS=,$'\n' read -d '' -r -a directories < BQSR_directories.tmp
IFS=,$'\n' read -d '' -r -a tablesamples < BQSR_sampletables.tmp
IFS=,$'\n' read -d '' -r -a tabledirectories < BQSR_directorytables.tmp
#
sample=( $(printf "%s\n" ${samples[*]} | sort -V ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
tablesample=( $(printf "%s\n" ${tablesamples[*]} | sort -V ) )
tabledirectory=( $(printf "%s\n" ${tabledirectories[*]} | sort -n ) )
#
declare -a sample
declare -a directory
declare -a tablesample
declare -a tabledirectory
#
cd $homedir
#
for ((i = 0; i < ${#tabledirectory[@]}; i++))
do
	echo "cd "${tabledirectory[$i]}"; gatk --java-options \"-Xmx6G\" GatherBamFiles --CREATE_INDEX true "${tablesample[*]/#/$PREFIX}" -O ../"${sample[$i]}"_BQSR.bam && cd "${directory[$i]}"/; samtools depth "${sample[$i]}"_BQSR.bam | awk '{sum+=\$3} END {print sum/NR}' > "${sample[$i]}".coverageALL; samtools depth -r chrX "${sample[$i]}"_BQSR.bam | awk '{sum+=\$3} END {print sum/NR}' > "${sample[$i]}".coveragechrX" >> bqsr_gatherBQSRBams.swarm
done
#
#more bqsr_gatherBQSRreports.swarm
#read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#echo "Swarm JobID:"
#
#jobid1=$(swarm -f bqsr_gatherBQSRreports.swarm -g 10 -t 8 --time 8:00:00 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk/GatherBQSRReports/"$SWARM_NAME"_Gather --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_Gather")
#
#echo $jobid1
