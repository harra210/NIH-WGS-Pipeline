#!/bin/bash
# Variable defining sections
#homedir="/data/harrisac2/Pipeline_CanFam4.0_Testing/JKidd_Pipeline6.0/"
#> bwa_to_picard.swarm
FQ_DIR=$(pwd)
#cd ../
#basedir=$(pwd)
#cd /data/harrisac2/Pipeline_CanFam4.0_Testing/tmp/
#tmpdir=$(pwd)
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
#
cd $tmpdir
#
# In the tmp folder, blanking the used tmp files
> raw_files.tmp
> directories.tmp
> LB.tmp
> samplenames.tmp
> single_dir.tmp
> IDs.tmp
> filenames.tmp
> PU.tmp
# Change to the fastq directory to populate RG header files
#FQ DEBUG
#FQ_DIR="/data/harrisac2/Heidi_TCC/Fastq/Emergency/Test"
#
cd $FQ_DIR
# First find section takes care of the concatenated files. The directory search is shared across the script.
#NISC or Raw Illumina File Searches
#find . -maxdepth 2 -name "*001.fastq.gz" -printf '%f\n' | sed 's/.fastq.gz//' &> samplename.txt
#find $PWD -maxdepth 2 -name "*L00?_R1_001.fastq.gz" -printf '%h\n' &> "$tmpdir"/directories.tmp
#find $PWD -maxdepth 2 -name "*L001_R1_001.fastq.gz" -printf '%h\n' &> "$tmpdir"/single_dir.tmp #NOTE: IF YOU HAVE DUPLICATE L READS, YOU WILL NEED TO EDIT THIS LINE TO ONE THAT IS UNIQUE. OTHERWISE IT WILL CAUSE ALIGNMENT ERRORS!!
#Dog10k Searches
find $PWD -maxdepth 2 -name "*1_clean.fq.gz" -printf '%h\n' &> "$tmpdir"/directories.tmp
find $PWD -maxdepth 2 -name "*1_clean.fq.gz" -printf '%h\n' &> "$tmpdir"/single_dir.tmp
#SRA searches
#find $PWD -maxdepth 2 -name "*1.fastq.gz" -printf '%h\n' &> "$tmpdir"/directories.tmp
#find $PWD -maxdepth 2 -name "*1.fastq.gz" -printf '%h\n' &> "$tmpdir"/single_dir.tmp
#Single End searches
#find . -maxdepth 2 -name "*fq.gz" -printf '%f\n' | sed 's/.fq.gz//' &> samplename.txt
#find $PWD -maxdepth 2 -name "*fq.gz" -printf '%h\n' &> "$tmpdir"/directories.tmp
#find $PWD -maxdepth 2 -name "*fq.gz" -printf '%h\n' &> "$tmpdir"/single_dir.tmp
#
#Paired End One Off
#find . -maxdepth 2 -name "*1.fastq.gz" -printf '%f\n' | sed 's/_1.fastq.gz//' &> samplename.txt
#find $PWD -maxdepth 2 -name "*1.fastq.gz" -printf '%h\n' &> "$tmpdir"/directories.tmp
#find $PWD -maxdepth 2 -name "*1.fastq.gz" -printf '%h\n' &> "$tmpdir"/single_dir.tmp
# Second find section will search the raw files and set them into their respective temp files and then parse the raw_files temp file to create the library file.
#
#
#This section creates the files necessary to input the bam headers later on.
#
cd $tmpdir
#
IFS=,$'\n' read -d '' -r -a singledir < single_dir.tmp
IFS=,$'\n' read -d '' -r -a multidir < directories.tmp
#
#
#DEBUG AREA
#echo ${directory[@]}
#echo ${singledir[*]}
#echo "Sleeping"
#sleep 30
#
for ((i = 0; i < ${#singledir[@]}; i++))
do
#NISC or Raw Illumina Files
#        cd ${singledir[$i]}; find . -maxdepth 2 -name "*L00?_R1_001*" -printf '%f\n' | sort -V >> "$tmpdir"/raw_files.tmp
#Dog10k Version
        cd ${singledir[$i]}; find . -maxdepth 2 -name "*1_clean.fq.gz" -printf '%f\n' | sort -V >> "$tmpdir"/raw_files.tmp
#SRA or One-Offs
#        cd ${singledir[$i]}; find . -maxdepth 2 -name "*1.fastq.gz" -printf '%f\n' | sort -V >> "$tmpdir"/raw_files.tmp
done
#
#for ((i = 0; i < ${#singledir[@]}; i++))
#do
#Dog10k Version
#	cd ${singledir[$i]}; > samplename.txt; find . -maxdepth 1 -name "*_1_clean.fq.gz" -printf '%f\n' | sed 's/_1_clean.fq.gz//' &> samplename.txt
#done
#
for ((i = 0; i < ${#singledir[@]}; i++))
do
#NISC or Raw Illumina Version
#	cd ${singledir[$i]}; > raw_header.txt; find . -maxdepth 2 -name "*L00?_R1_001*" -printf '%f\n' | sed 's/_R1_001.fastq.gz//' | sort -V &> filenames.txt
#Dog10k Version
	cd ${singledir[$i]}; > raw_header.txt; find . -maxdepth 2 -name "*1_clean.fq.gz" -printf '%f\n' | sed 's/_1_clean.fq.gz//' | sort -V &> filenames.txt
#SRA or One-Off Version
#	cd ${singledir[$i]}; > raw_header.txt; find . -maxdepth 2 -name "*_1.fastq.gz" -printf '%f\n' | sed 's/_1.fastq.gz//' | sort -V &> filenames.txt
done
#
#Dog10k Version
awk -F '_' '{print $1}' "$tmpdir"/raw_files.tmp > "$tmpdir"/LB.tmp
#NISC Version
#awk -F '_' '{print $1}' "$tmpdir"/raw_files.tmp > "$tmpdir"/LB.tmp
#
cd $tmpdir
IFS=,$'\n' read -d '' -r -a LB < LB.tmp
IFS=,$'\n' read -d '' -r -a rawname < raw_files.tmp
#IFS=,$'\n' read -d '' -r -a samplename < samplenames.tmp
#
#for ((i = 0; i < ${#multidir[@]}; i++))
#do
#	echo ""${multidir[$i]}":"${samplename[$i]}""
#done
#sleep 30
#
#DEBUG
#echo ${LB[@]}
#echo ${rawname[@]}
#echo ${samplename[@]}
#sleep 30
# Iterate through each directory with fastqs and head the first line of the raw R1 fastq and pipe that into file named raw_header.txt that is placed in the samples folder
#
for ((i = 0; i < ${#multidir[@]}; i++))
do
	cd "${multidir[$i]}"; zcat "${rawname[$i]}" | head -n 1 >> "${multidir[$i]}"/raw_header.txt
#	cd "${directory[$i]}"; gunzip -c "${rawname[$i]}" | awk ' NR==1 {print; exit}' >> "${directory[$i]}"/raw_header.txt
done
#
## DEBUG SECTION
#for ((i = 0; i < ${#multidir[@]}; i++))
#do
#	cd "${multidir[$i]}"; gunzip -c "${rawname[$i]}" | awk ' NR==1 {print; exit}'
#done
#sleep 30
#
# Iterates through each directory again, and then out of that print out just the Flowcell and Sample Tag information and label that as the trimmed_header
#
for ((i = 0; i < ${#singledir[@]}; i++))
do
#NISC or Raw Illumina Headers (Includes Dog10k)
       cd ${singledir[$i]}; awk -F ':' '{print $3,$4,$10}' raw_header.txt > trimmed_header.txt
#One-Off Version
#        cd ${singledir[$i]}; awk -F ':' '{print $1,$5}' raw_header.txt > trimmed_header.txt
#SRA Version
#        cd ${singledir[$i]}; awk -F ' ' '{print $1}' raw_header.txt > trimmed_header.txt
done
#
# Iterate through the directories, and then in each directory create a file labeled LB_header.txt that because the arrays are linked due to the temporary file creation is correct and can be verified manually looking at the original filenames
#
for ((i = 0; i < ${#singledir[@]}; i++))
do
#Comment for Old Illumina
        cd ${singledir[$i]}; printf "${LB[$i]}" > LB_header.txt
done
#
# Iterate through the directories and pasting the two files trimmed_header and LB_header into the pasted_header.txt which will have all of the Read Group information that
for ((i = 0; i < ${#singledir[@]}; i++))
do
#Comment for Old Illumina
        cd ${singledir[$i]}; awk '{print $1"."$2"."$3}' trimmed_header.txt > final_PU.txt
done
#
#IFS=,$'\n' read -d '' -r -a PU < final_PU.txt
for ((i = 0; i < ${#singledir[@]}; i++))
do
	cd ${singledir[$i]}; pwd | awk -F "/" '{print $10}' &> samplename.txt #IMPORTANT: THE AWK PRINT COLUMN NUMBER IS SUSCEPTIBLE TO CHANGING. VERIFY BEFORE CONTINUING
done
#IFS=,$'\n' read -d '' -r -a filename < filenames.txt
#
for ((i = 0; i < ${#multidir[@]}; i++))
do
	while read -r SM
	do
	cd "${multidir[$i]}"; echo "$SM" >> "$tmpdir"/IDs.tmp
	done < "${multidir[$i]}"/samplename.txt
done
#
for ((i = 0; i < ${#singledir[@]}; i++))
do
#Comment for Old Illumina
	cd "${singledir[$i]}"; cat final_PU.txt >> "$tmpdir"/PU.tmp
done
#
for ((i = 0; i < ${#singledir[@]}; i++))
do
#Comment for Old Illumina
	cd "${singledir[$i]}"; cat filenames.txt >> "$tmpdir"/filenames.tmp
done
#sleep 30
IFS=,$'\n' read -d '' -r -a ID < "$tmpdir"/IDs.tmp
IFS=,$'\n' read -d '' -r -a PU < "$tmpdir"/PU.tmp
IFS=,$'\n' read -d '' -r -a samplename < "$tmpdir"/filenames.tmp
#bamname=("${samplename[@]}")
#declare -a bamname
#
#for ((i = 0; i < "${#bamname[@]}"; i++))
#do
#	echo "${bamname[$i]}"_"${ID[$i]}"
#done
#echo ${ID[@]}
#echo ${samplename[@]}
#sleep 15
#unset bamname
#for (( i=0; i<${#samplename[*]}; ++i));
#do
#	bamname+=( "${ID[$i]}""_""${samplename[$i]}" )
#done
#echo ${bamname[@]}
#echo ${!bamname[@]}
#echo ${!samplename[@]}
#echo ${!ID[@]}
#sleep 30
#This finishes the creating of proper arrays.
#
#This section begins creating the swarmfiles for processing.
#
cd $homedir
#
for ((i = 0; i < ${#multidir[@]}; i++))
do
#For NISC samples or RAW Illumina fastqs
#	echo "cd ${multidir[$i]}; bwa-mem2 mem -K 100000000 -t \$SLURM_CPUS_PER_TASK -Y -R '@RG\\tID:"${ID[$i]}"\\tSO:coordinate\\tLB:"${LB[$i]}"\\tPL:ILLUMINA\\tSM:"${ID[$i]}"\\tPU:"${PU[$i]}"' "$CanFam4" "${samplename[$i]}"_R1_001.fastq.gz "${samplename[$i]}"_R2_001.fastq.gz | samtools view -h | samtools sort -@ \$SLURM_CPUS_PER_TASK -T /lscratch/\$SLURM_JOB_ID/${samplename[$i]} -o "${multidir[$i]}"/sort_"${ID[$i]}"_"${samplename[$i]}".bam && samtools flagstat "${multidir[$i]}"/sort_"${ID[$i]}"_"${samplename[$i]}".bam > sort_"${ID[$i]}"_"${samplename[$i]}".flagstat" >> "$homedir"/bwa_to_picard.swarm
#	echo "cd ${multidir[$i]}; bwa-mem2 mem -K 100000000 -t \$SLURM_CPUS_PER_TASK -Y -R '@RG\\tID:"${ID[$i]}"\\tSO:coordinate\\tLB:"${LB[$i]}"\\tPL:ILLUMINA\\tSM:"${ID[$i]}"\\tPU:"${PU[$i]}"' "$CanFam4" "${samplename[$i]}"_1.fastq.gz "${samplename[$i]}"_2.fastq.gz | samtools view -h | samtools sort -@ \$SLURM_CPUS_PER_TASK -T /lscratch/\$SLURM_JOB_ID/${ID[$i]} -o "${multidir[$i]}"/sort_"${ID[$i]}".bam && samtools flagstat "${multidir[$i]}"/sort_"${ID[$i]}".bam > sort_"${ID[$i]}".flagstat" >> "$homedir"/bwa_to_picard.swarm
#
#For Dog10k Genome Samples
	echo "cd ${multidir[$i]}; bwa-mem2 mem -K 100000000 -t \$SLURM_CPUS_PER_TASK -Y -R '@RG\\tID:"${ID[$i]}"\\tSO:coordinate\\tLB:"${LB[$i]}"\\tPL:ILLUMINA\\tSM:"${ID[$i]}"\\tPU:"${PU[$i]}"' "$CanFam4" "${samplename[$i]}"_1_clean.fq.gz "${samplename[$i]}"_2_clean.fq.gz | samtools view -h | samtools sort -@ \$SLURM_CPUS_PER_TASK -T /lscratch/\$SLURM_JOB_ID/${samplename[$i]} -o "${multidir[$i]}"/sort_"${ID[$i]}".bam && samtools flagstat "${multidir[$i]}"/sort_"${ID[$i]}".bam > sort_"${ID[$i]}".flagstat" >> "$homedir"/bwa_to_picard.swarm
#SRA and Special One-Offs
#	echo "cd ${multidir[$i]}; bwa-mem2 mem -K 100000000 -t \$SLURM_CPUS_PER_TASK -Y -R '@RG\\tID:"${samplename[$i]}"\\tSO:coordinate\\tLB:"${ID[$i]}"\\tPL:ILLUMINA\\tSM:"${ID[$i]}"\\tPU:"${ID[$i]}"' "$CanFam4" "${samplename[$i]}"_1.fastq.gz "${samplename[$i]}"_2.fastq.gz | samtools view -h | samtools sort -@ \$SLURM_CPUS_PER_TASK -T /lscratch/\$SLURM_JOB_ID/${samplename[$i]} -o "${multidir[$i]}"/sort_"${samplename[$i]}".bam && samtools flagstat "${multidir[$i]}"/sort_"${samplename[$i]}".bam > sort_"${samplename[$i]}".flagstat" >> "$homedir"/bwa_to_picard.swarm
done
#
#
