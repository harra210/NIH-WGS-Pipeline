#!/bin/bash
HC_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/"
#
cd $tmpdir
#
> HC_tabixname.tmp
> HC_samplenames.tmp
> HC_directories.tmp
> HC_Basesamplenames.tmp
#> BQSR_directorytables.tmp
#
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
interval_list="/data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list"
PREFIX="-I "
#
cd $HC_DIR
#
#Finding Table files
find . -mindepth 2 -maxdepth 3 -name "*chrY.g.vcf.gz" -printf '%f\n' | sed 's/_chrY.g.vcf.gz//' &> "$tmpdir"/HC_tabixname.tmp
find . -mindepth 2 -maxdepth 3 -name "*g.vcf.gz" -printf '%f\n' &> "$tmpdir"/HC_samplenames.tmp
find $PWD -maxdepth 2 -name "*chrY*g.vcf.gz" -printf '%h\n' &> "$tmpdir"/HC_directories.tmp
#
#Finding Dedup Bams
#cd ../
#bqsr_base=$(pwd)
find . -maxdepth 2 -name "*_BQSR.bam" -printf '%f\n' | sed 's/_BQSR.bam//' &> "$tmpdir"/HC_Basesamplenames.tmp
#find $PWD -maxdepth 2 -name "dedup_*.bam" -printf '%h\n' &> "$tmpdir"/BQSR_directories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' -r -a tabsample < HC_tabixname.tmp
IFS=,$'\n' read -d '' -r -a samples < HC_samplenames.tmp
IFS=,$'\n' read -d '' -r -a basenames < HC_Basesamplenames.tmp
IFS=,$'\n' read -d '' -r -a directories < HC_directories.tmp
#
tabixsample=( $(printf "%s\n" ${tabsample[*]} | sort -V ) )
sample=( $(printf "%s\n" ${samples[*]} | sort -V ) )
basenames=( $(printf "%s\n" ${basenames[*]} | sort -V ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
#
declare -a tabixsample
declare -a samples
declare -a basenames
declare -a directory
#
cd $homedir
#
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx6G\" GatherVcfsCloud "${sample[*]/#/$PREFIX}" -O ../"${basenames[$i]}"_g.vcf.gz && tabix -p vcf -f ../"${tabixsample[$i]}"_g.vcf.gz" >> hc_gathergvcfs.swarm
done
#
#more bqsr_gatherBQSRreports.swarm
#read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#echo "Swarm JobID:"
#
#jobid1=$(swarm -f bqsr_gatherBQSRreports.swarm -g 10 -t 8 --time 8:00:00 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk/GatherBQSRReports/"$SWARM_NAME"_Gather --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_Gather")
#
#echo $jobid1
