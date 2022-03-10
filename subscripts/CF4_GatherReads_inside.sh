#!/bin/bash
#
BQSR_DIR=$(pwd)
homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp"
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
knownsite="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0.BQSR.DB.bed"
interval_list="/data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list"
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
cd $homedir
#
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" PrintReads -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I "${sample[$i]}"_BQSR.bam -O "${sample[$i]}"_BQSR.cram" >> PrintReads.swarm
done
#
