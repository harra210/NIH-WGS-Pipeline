#!/bin/bash
#
homedir=$(pwd)
> haplotypecaller.swarm
export homedir
#
cd ../tmp
tmpdir=$(pwd)
export tmpdir
> Basedirectories.tmp
#
cd $homedir
#
cd scripts/
scriptdir=$(pwd)
#
echo "What parent directory are the BQSR bam files that you want to call haplotypes on?"
read -e -t 30 FILE_DIR
echo "What do you want to name your base swarm?"
read -e -t 30 SWARM_NAME
#
cd $FILE_DIR
#
find $PWD -mindepth 1 -maxdepth 1 -type d &> "$tmpdir"/Basedirectories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' basedir < Basedirectories.tmp
#
cd $FILE_DIR
#
for dir in ${basedir[@]};
	do
		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir and generating HaplotypeCaller swarm commands" && bash "$scriptdir"/CF4_HaplotypeCaller_inside.sh )
done
#
cd $homedir
head -n 40 haplotypecaller.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptA
while true; do
        case "$promptA" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no";;
        esac
done
#
echo "Swarm Job ID: "
#
jobid1=$(swarm -f haplotypecaller.swarm -g 8 -t 6 -b 10 --gres=lscratch:120 --time 24:00:00 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk/HaplotypeCaller/"$SWARM_NAME"_HC --sbatch "--mail-type=ALL,TIME_LIMIT_90 --job-name "$SWARM_NAME"_HC")
echo $jobid1

