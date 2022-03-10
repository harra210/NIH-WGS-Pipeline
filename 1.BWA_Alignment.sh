#!/bin/bash
#
homedir=$(pwd)
> bwa_to_picard.swarm
export homedir
#
cd ../tmp
tmpdir=$(pwd)
export tmpdir
#
cd $homedir
#
cd scripts/
scriptdir=$(pwd)
#
cd $tmpdir
> Basedirectories.tmp
#
echo "This script will process raw FASTQ files into individual sorted bam files for later merging. This script is extremely resource-heavy and may result in long queue times while scheduling your job. Is running this script your intention?"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) break;;
                No ) exit;;
        esac
done
#
echo "What parent directory are your fastq files that you want to align?"
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
for dir in ${basedir[@]};
	do
#		( echo "$dir" )
#		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir and expanding" )
		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir and generating alignment swarm" && bash "$scriptdir"/CF4_BWA.sh )
done
#sleep 30
#
cd $homedir
more bwa_to_picard.swarm
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
jobid1=$(swarm -f bwa_to_picard.swarm -g 120 -t 32 --gres=lscratch:300 --time 2-0 --module bwa-mem2/2-2.0,samtools --logdir ~/job_outputs/bwa_to_picard/"$SWARM_NAME"_FQ --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_FQ")
echo $jobid1
