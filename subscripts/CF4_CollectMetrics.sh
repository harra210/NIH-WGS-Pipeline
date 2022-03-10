#!/bin/bash
SAMPLE_DIR=$(pwd)
#
### Variable Setting Section ###
CanFam4="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
knownsite="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0.BQSR.DB.bed"
interval_list="/data/Ostrander/Alex/Intervals/Curated/CanFam4_GSD/Intervals.list"
#
cd $tmpdir
#
> POST_directories.tmp
> POST_samplenames.tmp
#
cd $SAMPLE_DIR
#
# Search directory for CRAM file
find . -maxdepth 1 -name "*BQSR.cram" -printf '%f\n' | sed 's/.BQSR.cram//' &> "$tmpdir"/POST_samplenames.tmp
find $PWD -maxdepth 1 -name "*BQSR.cram" -printf '%h\n' &> "$tmpdir"/POST_directories.tmp
#
cd $tmpdir
#
# Input the found files into proper arrays
IFS=,$'\n' read -d '' -r -a samplename < POST_samplenames.tmp
IFS=,$'\n' read -d '' -r -a directories < POST_directories.tmp
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
declare -a sample
declare -a directory
#
cd $homedir
#
for ((i = 0; i < ${#directory[@]}; i++))
do
	echo "cd "${directory[$i]}"; gatk CollectInsertSizeMetrics R="$CanFam4" I="${sample[$i]}".BQSR.cram O="${sample[$i]}"_size_metrics.txt H="${sample[$i]}"_size_histogram.pdf && gatk CollectAlignmentSummaryMetrics R="$CanFam4" I="${sample[$i]}".BQSR.cram O="${sample[$i]}".alignment.summary.metrics && gatk --java-options \"-Xmx2g\" GenotypeGVCFs -R "$CanFam4" -V "${sample[$i]}".g.vcf.gz -O knownsites/"${sample[$i]}".knownsites.vcf.gz --include-non-variant-sites --intervals /data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/SRZ189891_722g.simp.header.CanineHDandAxiom_K9_HD.GSD_1.0.vcf.gz" >> POST_CollectMetrics.swarm
done
