#!/bin/bash
#
homedir=$(pwd)
export homedir
> bqsr_GatherBQSRReports.swarm
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
echo "What parent directory are the BaseRecalibration reports needing merging?"
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
		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir and generating GatherBQSRReport swarm commands" && bash "$scriptdir"/CF4_GatherBQSR_inside.sh )
done
#
cd $homedir
more bqsr_GatherBQSRReports.swarm
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
jobid1=$(swarm -f bqsr_GatherBQSRReports.swarm -g 8 -t 6 -b 4 --gres=lscratch:75 --time 2:00:00 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk/BaseRecalibrator/"$SWARM_NAME"_GatherReports --sbatch "--mail-type=ALL,TIME_LIMIT_90 --job-name "$SWARM_NAME"_GatherBQSRReports")
echo $jobid1

