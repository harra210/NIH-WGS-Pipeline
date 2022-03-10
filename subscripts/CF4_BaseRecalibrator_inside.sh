#!/bin/bash
#
BQSR_DIR=$(pwd)
#
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/"
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
for ((i = 0; i < ${#directory[@]}; i++))
do
	cd "${directory[$i]}"; mkdir -p BQSR; cd BQSR; mkdir -p tables
done
#
cd $homedir
#
while read g
do
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" BaseRecalibrator -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I dedup_"${sample[$i]}".bam --known-sites "$knownsite" -L "$g" -O "${directory[$i]}"/BQSR/tables/"${sample[$i]}"_"$g"_recal.table" >> "$homedir"/bqsr_BaseRecalibrator.swarm
done
done < /data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list
#
for ((i = 0;i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" BaseRecalibrator -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I dedup_"${sample[$i]}".bam --known-sites "$knownsite" -XL "$interval_list" -O "${directory[$i]}"/BQSR/tables/"${sample[$i]}"_chrY_recal.table" >> "$homedir"/bqsr_BaseRecalibrator.swarm
done
#
