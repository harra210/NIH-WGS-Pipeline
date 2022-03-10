#!/bin/bash
BQSR_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/"
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
interval_list="/data/Ostrander/Resources/CanFam4_GSD/Intervals/Intervals.list"
PREFIX="--input "
#
cd $tmpdir
#
> BQSR_samplenames.tmp
> BQSR_directories.tmp
> BQSR_sampletables.tmp
> BQSR_directorytables.tmp
#
cd $BQSR_DIR
#
#Finding Table files
find . -mindepth 2 -maxdepth 3 -name "*recal.table" -printf '%f\n' &> "$tmpdir"/BQSR_sampletables.tmp
find $PWD -mindepth 2 -maxdepth 3 -name "*chrY*" -printf '%h\n' &> "$tmpdir"/BQSR_directorytables.tmp
#
#Finding Dedup Bams
find . -mindepth 1 -maxdepth 2 -name "dedup_*.bam" -printf '%f\n' | sed 's/dedup_//' | sed 's/.bam//' &> "$tmpdir"/BQSR_samplenames.tmp
find $PWD -mindepth 1 -maxdepth 2 -name "dedup_*.bam" -printf '%h\n' &> "$tmpdir"/BQSR_directories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' -r -a tablesamples < BQSR_sampletables.tmp
IFS=,$'\n' read -d '' -r -a tabledirectories < BQSR_directorytables.tmp
IFS=,$'\n' read -d '' -r -a samples < BQSR_samplenames.tmp
#
tablesample=( $(printf "%s\n" ${tablesamples[*]} | sort -V ) )
tabledirectory=( $(printf "%s\n" ${tabledirectories[*]} | sort -n ) )
sample=( $(printf "%s\n" ${samples[*]} | sort -V ) )
declare -a tablesample
declare -a tabledirectory
declare -a sample
#
cd $homedir
#
for ((i = 0; i < ${#tabledirectory[@]}; i++))
do
	echo "cd "${tabledirectory[$i]}"; gatk --java-options \"-Xmx6G\" GatherBQSRReports "${tablesample[*]/#/$PREFIX}" --output ../"${sample[$i]}"_fullBQSR.reports.list" >> bqsr_GatherBQSRReports.swarm
done
