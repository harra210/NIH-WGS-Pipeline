#!/bin/bash
HC_DIR=$(pwd)
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#tmpdir="/data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/"
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
knownsite="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0.BQSR.DB.bed"
interval_list="/data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list"
#
cd $tmpdir
#
> HC_directories.tmp
> HC_samplenames.tmp
#
cd $HC_DIR
#
find . -maxdepth 1 -name "*BQSR.bam" -printf '%f\n' | sed 's/_BQSR.bam//' &> "$tmpdir"/HC_samplenames.tmp
find $PWD -maxdepth 1 -name "*BQSR.bam" -printf '%h\n' &> "$tmpdir"/HC_directories.tmp
#
cd "$tmpdir"
#
IFS=,$'\n' read -d '' -r -a samplename < HC_samplenames.tmp
IFS=,$'\n' read -d '' -r -a directories < HC_directories.tmp
#
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
declare -a sample
declare -a directory
#
for ((i = 0; i < ${#directory[@]}; i++))
do
	cd "${directory[$i]}"; mkdir -p HC/
done
#
cd $homedir
#
while read g
do
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" HaplotypeCaller -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I "${sample[$i]}"_BQSR.bam -L "$g" -O "${directory[$i]}"/HC/"${sample[$i]}"_"$g".g.vcf.gz -ERC GVCF" >> haplotypecaller.swarm
done
done < /data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list
#
for ((i = 0;i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk --java-options \"-Xmx4G\" HaplotypeCaller -R "$CanFam4" --tmp-dir /lscratch/\$SLURM_JOB_ID -I "${sample[$i]}"_BQSR.bam -XL "$interval_list" -O "${directory[$i]}"/HC/"${sample[$i]}"_chrY.g.vcf.gz -ERC GVCF" >> haplotypecaller.swarm
done
#
#more haplotypecaller.swarm
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
#jobid1=$(swarm -f haplotypecaller.swarm -g 8 -t 10 --time 2-0 --gres=lscratch:50 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk/HaplotypeCaller/"$SWARM_NAME"_HC --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_HC")
#echo $jobid1
#
