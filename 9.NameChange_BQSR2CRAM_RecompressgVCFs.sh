#!/bin/bash
#
homedir=$(pwd)
> BQSR_Recompress.swarm
export homedir
#
cd ../tmp
tmpdir=$(pwd)
export tmpdir
> Sample_Basedirectories.tmp
#
cd $homedir
#
cd scripts/
scriptdir=$(pwd)
#
echo "What parent directory are the files that you want to turn to CRAM and compress??"
read -e -t 30 FILE_DIR
echo "What do you want to name your base swarm?"
read -e -t 30 SWARM_NAME
#
cd $FILE_DIR
#
find $PWD -mindepth 1 -maxdepth 1 -type d &> "$tmpdir"/Sample_Basedirectories.tmp
#
cd $tmpdir
#
IFS=,$'\n' read -d '' basedir < Sample_Basedirectories.tmp
#
read -sp "`echo -e 'This script will rename samples to Ostrander Lab Standard names. Input the correct name when prompted. Press any key to continue or Ctrl+C to cancel \n\b'`" -n1 key
#
#
cd $FILE_DIR
#
for dir in ${basedir[@]};
	do
		( [ -d "$dir" ] && cd "$dir" && echo "Entering into $dir" && bash "$scriptdir"/CF4_NameChange_Recompress_CRAM.sh )
done
#
cd $homedir
more BQSR_Recompress.swarm
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
jobid1=$(swarm -f BQSR_Recompress.swarm -g 8 -t 6 --gres=lscratch:150 --time 5-0 --module GATK/4.2.0.0,samtools --logdir ~/job_outputs/gatk/PrintReads/"$SWARM_NAME"_PR --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_PR")
echo $jobid1

