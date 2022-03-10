#!/bin/bash
#
homedir=$(pwd)
> mergeDedup.swarm
export homedir
#
cd ../tmp
tmpdir=$(pwd)
export tmpdir
> SamtoolsBasedirectories.tmp
#
cd $homedir
#
cd scripts/
scriptdir=$(pwd)
#
#
echo "What parent directory are the sorted bam files that you want to merge?"
read -e -t 30 FILE_DIR
echo "What do you want to name your base swarm?"
read -e -t 30 SWARM_NAME
#
cd $FILE_DIR
#
find $PWD -mindepth 1 -maxdepth 1 -type d &> "$tmpdir"/SamtoolsBasedirectories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' basedir < SamtoolsBasedirectories.tmp
#
cd $FILE_DIR
#
for dir in ${basedir[@]};
	do
		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir and expanding" && bash "$scriptdir"/CF4_samtools_inside.sh )
done
#
cd $homedir
more mergeDedup.swarm
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
jobid1=$(swarm -f mergeDedup.swarm -g 36 -t 20 --gres=lscratch:350 --time 2-0 --module samtools,GATK/4.2.0.0 --logdir ~/job_outputs/samtools/"$SWARM_NAME"_merge --sbatch "--mail-type=ALL,TIME_LIMIT_90 --job-name "$SWARM_NAME"_Merge")
echo $jobid1

