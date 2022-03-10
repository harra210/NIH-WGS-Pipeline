#!/bin/bash
#
homedir=$(pwd)
> bqsr_gatherBQSRBams.swarm
export homedir
#
cd ../tmp
tmpdir=$(pwd)
export tmpdir
> BQSRBasedirectories.tmp
#
cd $homedir
#
cd scripts/
scriptdir=$(pwd)
#
echo "What parent directory are the sorted bam files that you want to merge?"
read -e -t 30 FILE_DIR
echo "What do you want to name your base swarm?"
read -e -t 30 SWARM_NAME
#
cd $FILE_DIR
#
find $PWD -mindepth 1 -maxdepth 1 -type d &> "$tmpdir"/BQSRBasedirectories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' basedir < BQSRBasedirectories.tmp
#
cd $FILE_DIR
#
for dir in ${basedir[@]};
	do
		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir and generating GatherBQSRReport commands" && bash "$scriptdir"/CF4_GatherBQSRBams_inside.sh )
done
#
cd $homedir
more bqsr_gatherBQSRBams.swarm
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
jobid1=$(swarm -f bqsr_gatherBQSRBams.swarm -g 8 -t 6 --gres=lscratch:75 --time 24:00:00 --module GATK/4.2.0.0,samtools --logdir ~/job_outputs/gatk/BaseRecalibrator/"$SWARM_NAME"_GatherBams --sbatch "--mail-type=ALL,TIME_LIMIT_90 --job-name "$SWARM_NAME"_GatherBams")
echo $jobid1

