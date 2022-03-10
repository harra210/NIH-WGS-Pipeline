#!/bin/bash
Reference="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/UU_Cfam_GSD_1.0_ROSY.fa"
Resource="/data/Ostrander/Resources/CanFam4_GSD/BWAMEM2/SRZ189891_722g.simp.header.CanineHDandAxiom_K9_HD.GSD_1.0.vcf.gz"
homedir=$(pwd)
> gvcfs_final.txt
> GenomicsDB_samplemap.txt
> BCFConcat_AutoXPARsamplemap.txt
> BCFConcat_XNonPARsamplemap.txt
> VQSR_SelectVariants.swarm
> VQSR_VariantFiltration.swarm
> VQSR_VariantRecalibrator.swarm
#
cd ../../tmp
tmpdir=$(pwd)
> GDBI_samplenames.txt
> GDBI_directories.txt
> bcftools_AutoXPARsamples.txt
> bcftools_XNonPARsamples.txt
#
cd $homedir
####
echo "Directory of gVCFs to place into GenomicsDB?"
read -ep "Sample gVCF directory: " GVCF_DIR
echo "Output of Genotyped VCF's?"
read -ep "VCF Output: " OUT_DIR
echo "Name of joint-called VCF?"
read -ep "Joint VCF name: " NAME
echo "What do you want to name the swarm?"
read -ep "Swarm name: " SWARM_NAME
#####
cd $OUT_DIR
mkdir -p RAW_AutoandXPAR
cd RAW_AutoandXPAR/
#
RAW_Auto=$(pwd)
#
cd $OUT_DIR
#
mkdir -p RAW_XNonPAR
cd RAW_XNonPAR/
RAW_NONPAR=$(pwd)
#cd $tmpdir
#
cd $OUT_DIR
#
mkdir -p VQSR
cd VQSR/
VQSR_DIR=$(pwd)
mkdir -p Filter
#
cd Filter/
FILTER_DIR=$(pwd)
#####
cd $GVCF_DIR
#
find . -maxdepth 1 -name '*.g.vcf.gz' -printf '%f\n' | sed 's/.g.vcf.gz//' | sort -n &> "$tmpdir"/GDBI_samplenames.txt
find $PWD -maxdepth 1 -name '*.g.vcf.gz' -printf '%h\n' &> "$tmpdir"/GDBI_directories.txt
#
cd $tmpdir
#
IFS=,$'\n' read -d '' -r -a samplename < GDBI_samplenames.txt
#echo "${samplename[@]}" #for debugging purposes
#IFS=,$'\n' read -d '' -r -a directories < GDBI_directories.txt # Used if samples are in multiple directories...rarely used.
#echo "${directories[@]}" #for debugging purposes
#
sample=( $(printf "%s\n" ${samplename[*]} | sort -n ) )
#directory=( $(printf "%s\n" ${directories[*]} | sort -n ) )
#
declare -a sample
#declare -a directory
unset IFS
#
cd $homedir
#
#STANDARD - When all of the gVCFs to import are located in one folder
for sample in "${sample[@]}"
do
        echo ""$GVCF_DIR""$sample".g.vcf.gz" >> gvcfs_final.txt
done
#
paste "$tmpdir"/GDBI_samplenames.txt gvcfs_final.txt > GenomicsDB_samplemap.txt
#
more GenomicsDB_samplemap.txt
read -sp "`echo -e 'Verify samplemap for correctness! Press Enter to continue of Ctrl+C to abort \n\b'`" -n1 key
#
> GenomicsDBImport_GenotypeGVCFs.swarm
#
#echo "ulimit -u 16384 && gatk --java-options \"-Xmx8g -Xms8g -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID\" GenomicsDBImport --tmp-dir /lscratch/\$SLURM_JOB_ID --L /data/harrisac2/Pipeline_CanFam4.0_Testing/VCF_to_Finish/GenomicsDBImport/Full_intervals.intervals --sample-name-map /data/harrisac2/Pipeline_CanFam4.0_Testing/VCF_to_Finish/GenomicsDBImport/GenomicsDB_samplemap.txt --batch-size 50 --genomicsdb-workspace-path /lscratch/\$SLURM_JOB_ID/db && gatk --java-options \"-Xmx6g -Xms6g -Djava.io.tmpdir=/lscratch/\$SLURM_JOB_ID\" GenotypeGVCFs --tmp-dir /lscratch/\$SLURM_JOB_ID -R $Reference -O "$OUT_DIR""$NAME".RAW.vcf.gz -V gendb:///lscratch/\$SLURM_JOB_ID/db" > GenomicsDBImport_GenotypeGVCFs.swarm
while read i
do
        echo "ulimit -u 16384 && gatk --java-options \"-Xmx7g -Xms7g\" GenomicsDBImport --tmp-dir /lscratch/\$SLURM_JOB_ID/ --L $i --sample-name-map GenomicsDB_samplemap.txt --batch-size 50 --genomicsdb-workspace-path /lscratch/\$SLURM_JOB_ID/"$i" --genomicsdb-shared-posixfs-optimizations && gatk --java-options \"-Xmx6g -Xms6g\" GenotypeGVCFs --tmp-dir /lscratch/\$SLURM_JOB_ID/ -R $Reference -O "$RAW_Auto"/"$NAME"."$i".AutoXPAR.RAW.vcf.gz -V gendb:///lscratch/\$SLURM_JOB_ID/"$i"" >> GenomicsDBImport_GenotypeGVCFs.swarm
done < /data/harrisac2/Pipeline_CanFam4.0_Testing/VCF_to_Finish/GenomicsDBImport/Full_intervals.intervals
#
tail -n 45 GenomicsDBImport_GenotypeGVCFs.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptA
while true; do
        case "$promptA" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#
jobid1=$(swarm -f GenomicsDBImport_GenotypeGVCFs.swarm -g 10 -t 5 -b 12 --time 8:00:00 --module GATK/4.2.0.0 --gres=lscratch:150 --logdir ~/job_outputs/gatk4/GenomicsDBImport/"$SWARM_NAME" --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_GDBI")
#
echo
echo
echo "GenomicsDBImport AutoandXPAR Swarm Job ID #:"
echo $jobid1
echo
echo
sleep 3
#
> GenomicsDBImport_GenotypeGVCFs_XNonPAR.swarm
while read i
do
	echo "ulimit -u 16384 && gatk --java-options \"-Xmx7g -Xms7g\" GenomicsDBImport --tmp-dir /lscratch/\$SLURM_JOB_ID/ --L $i --sample-name-map GenomicsDB_samplemap.txt --batch-size 50 --genomicsdb-workspace-path /lscratch/\$SLURM_JOB_ID/"$i" --genomicsdb-shared-posixfs-optimizations && gatk --java-options \"-Xmx6g -Xms6g\" GenotypeGVCFs --tmp-dir /lscratch/\$SLURM_JOB_ID/ -R $Reference -O "$RAW_NONPAR"/"$NAME"."$i".chrX.NONPAR.RAW.vcf.gz -V gendb:///lscratch/\$SLURM_JOB_ID/"$i"" >> GenomicsDBImport_GenotypeGVCFs_XNonPAR.swarm
done < /data/harrisac2/Pipeline_CanFam4.0_Testing/VCF_to_Finish/GenomicsDBImport/XNonPAR_intervals.intervals
#
tail -n 45 GenomicsDBImport_GenotypeGVCFs_XNonPAR.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptB
while true; do
        case "$promptB" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#read -sp "`echo -e 'Verify swarmfile for correctness! Press enter to continue or Ctrl+C to abort \n\b'`" -n1 key
#
jobid2=$(swarm -f GenomicsDBImport_GenotypeGVCFs_XNonPAR.swarm -g 10 -t 5 -b 12 --time 8:00:00 --module GATK/4.2.0.0 --gres=lscratch:150 --logdir ~/job_outputs/gatk4/GenomicsDBImport/"$SWARM_NAME"_XNonPAR --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_GDBI_XNonPAR")
#
echo
echo
echo "GenomicsDBImport XNonPAR Swarm Job ID #:"
echo $jobid2
echo
echo
sleep 3
#
cd $tmpdir
#
while read i
do
	echo ""$RAW_Auto"/"$NAME"."$i".AutoXPAR.RAW.vcf.gz" >> bcftools_AutoXPARsamples.txt
done < /data/harrisac2/Pipeline_CanFam4.0_Testing/VCF_to_Finish/GenomicsDBImport/Full_intervals.intervals
#
IFS=,$'\n' read -d '' -r -a Autovcf < bcftools_AutoXPARsamples.txt
sortedAutovcf=( $(printf "%s\n" ${Autovcf[*]} | sort -V ) )
declare -a sortedAutovcf
unset IFS
#
cd $homedir
> bcftools_concatAutoXPAR.swarm
#
printf "%s\n" "${sortedAutovcf[@]}" > BCFConcat_AutoXPARsamplemap.txt
#
tail -n 25 BCFConcat_AutoXPARsamplemap.txt
#
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
echo "cd $homedir; bcftools concat -a -D --threads \$SLURM_CPUS_PER_TASK -f BCFConcat_AutoXPARsamplemap.txt -O z -o "$VQSR_DIR"/"$NAME".AutoXPAR.vcf.gz && gatk IndexFeatureFile -I "$VQSR_DIR"/"$NAME".AutoXPAR.vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID" >> bcftools_concatAutoXPAR.swarm
#
more bcftools_concatAutoXPAR.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptC
while true; do
        case "$promptC" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#
jobid3=$(swarm -f bcftools_concatAutoXPAR.swarm -g 32 -t 8 --time 24:00:00 --gres=lscratch:150 --module bcftools,GATK/4.2.0.0 --logdir ~/job_outputs/BCFtools/Concat/"$SWARM_NAME"_AutoXPAR --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_AutoXPAR_Concat --dependency=afterany:"$jobid1","$jobid2"")
#
echo
echo
echo "AutoXPAR Concat Swarm Job ID #:"
echo $jobid3
echo
echo
sleep 3
#
cd $tmpdir
#
while read i
do
        echo ""$RAW_NONPAR"/"$NAME"."$i".chrX.NONPAR.RAW.vcf.gz" >> bcftools_XNonPARsamples.txt
done < /data/harrisac2/Pipeline_CanFam4.0_Testing/VCF_to_Finish/GenomicsDBImport/XNonPAR_intervals.intervals
#
IFS=,$'\n' read -d '' -r -a NonPARvcf < bcftools_XNonPARsamples.txt
sortedNonPARvcf=( $(printf "%s\n" ${NonPARvcf[*]} | sort -V ) )
declare -a sortedNonPARvcf
unset IFS
#
cd $homedir
> bcftools_concatXNonPAR.swarm
#
printf "%s\n" "${sortedNonPARvcf[@]}" > BCFConcat_XNonPARsamplemap.txt
#
tail -n 25 BCFConcat_XNonPARsamplemap.txt
#
read -sp "`echo -e 'Press any key to continue or Ctrl+C to abort \n\b'`" -n1 key
#
echo "cd $homedir; bcftools concat -a -D --threads \$SLURM_CPUS_PER_TASK -f BCFConcat_XNonPARsamplemap.txt -O z -o "$VQSR_DIR"/"$NAME".chrX.NONPAR.vcf.gz && gatk IndexFeatureFile -I "$VQSR_DIR"/"$NAME".chrX.NONPAR.vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID" >> bcftools_concatXNonPAR.swarm
#
more bcftools_concatXNonPAR.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptD
while true; do
        case "$promptD" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#
jobid4=$(swarm -f bcftools_concatXNonPAR.swarm -g 32 -t 8 --time 24:00:00 --gres=lscratch:150 --module bcftools,GATK/4.2.0.0 --logdir ~/job_outputs/BCFtools/Concat/"$SWARM_NAME"_XNonPAR --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_XNonPAR_Concat --dependency=afterok:"$jobid2"")
#
echo
echo
echo "XNonPAR Concat Swarm Job ID #: "
echo $jobid4
echo
echo
sleep 3
#
#####
# Auto and X PAR SelectVariants
#####
echo "cd "$VQSR_DIR"; gatk --java-options \"-Xmx4g\" SelectVariants -V "$NAME".AutoXPAR.vcf.gz -O "$NAME".AutoXPAR.SNPs.vcf.gz -select-type SNP && gatk --java-options \"-Xmx4g\" SelectVariants -V "$NAME".AutoXPAR.vcf.gz -O "$NAME".AutoXPAR.nonSNPs.vcf.gz -xl-select-type SNP && gatk --java-options \"-Xmx4g\" SelectVariants -V "$NAME".chrX.NONPAR.vcf.gz -O "$NAME".chrX.NONPAR.SNPs.vcf.gz -select-type SNP && gatk --java-options \"-Xmx4g\" SelectVariants -V "$NAME".chrX.NONPAR.vcf.gz -O "$NAME".chrX.NONPAR.nonSNPs.vcf.gz -xl-select-type SNP" > VQSR_SelectVariants.swarm
#
more VQSR_SelectVariants.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptE
while true; do
        case "$promptE" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#
jobid5=$(swarm -f VQSR_SelectVariants.swarm -g 8 -t 10 --time 24:00:00 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk4/SelectVariants/"$SWARM_NAME" --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_SelectVariants --dependency=afterok:"$jobid3"")
#
echo
echo
echo "SelectVariants Swarm Job ID #:"
echo "$jobid5"
echo
echo
sleep 3
#
#####
# VariantFiltration - For Indels
#####
#
echo "cd "$VQSR_DIR"; gatk --java-options \"-Xmx4g\" VariantFiltration -V "$NAME".AutoXPAR.nonSNPs.vcf.gz -O Filter/"$NAME".AutoXPAR.nonSNPs.filtered.vcf.gz --verbosity ERROR -filter \"QD < 2.0\" --filter-name \"QD2\" -filter \"FS > 200.0\" --filter-name \"FS200\" -filter \"ReadPosRankSum < -2.0\" --filter-name \"ReadPosRankSum-2\" -filter \"SOR > 10.0\" --filter-name \"SOR-10\" && gatk --java-options \"-Xmx4g\" VariantFiltration -V "$NAME".chrX.NONPAR.nonSNPs.vcf.gz -O Filter/"$NAME".chrX.NONPAR.nonSNPs.filtered.vcf.gz --verbosity ERROR -filter \"QD < 2.0\" --filter-name \"QD2\" -filter \"FS > 200.0\" --filter-name \"FS200\" -filter \"ReadPosRankSum < -2.0\" --filter-name \"ReadPosRankSum-2\" -filter \"SOR > 10.0\" --filter-name \"SOR-10\"" > VQSR_VariantFiltration.swarm
#
more VQSR_VariantFiltration.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptF
while true; do
        case "$promptF" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#
jobid6=$(swarm -f VQSR_VariantFiltration.swarm -g 8 -t 10 --time 12:00:00 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk4/VariantFiltration/"$SWARM_NAME" --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_VariantFiltration --dependency=afterok:"$jobid5"")
#
echo
echo
echo "VariantFiltration Swarm Job ID #:"
echo "$jobid6"
echo
echo
sleep 3
#
#####
# VariantRecalibrator
#####
#
echo "cd "$VQSR_DIR"; gatk --java-options \"-Xmx59g\" VariantRecalibrator -R "$Reference" -V "$NAME".AutoXPAR.SNPs.vcf.gz -O "$NAME".AutoXPAR.SNPs.recal -resource:array,known=false,training=true,truth=true,prior=12.0 "$Resource" --use-annotation QD --use-annotation MQ --use-annotation MQRankSum --use-annotation ReadPosRankSum --use-annotation FS --use-annotation SOR --use-annotation DP --trust-all-polymorphic true -mode SNP --rscript-file "$NAME".AutoXPAR.SNPs.plots.R --tranches-file "$NAME".AutoXPAR.SNPs.tranches -tranche 100.00 -tranche 99.9 -tranche 99.0 -tranche -98.0 -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 --tmp-dir /lscratch/\$SLURM_JOB_ID/ && gatk --java-options \"-Xmx59g\" ApplyVQSR -R "$Reference" -V "$NAME".AutoXPAR.SNPs.vcf.gz -O Filter/"$NAME".AutoXPAR.SNPs.filtered.vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID/ --truth-sensitivity-filter-level 99.0 --tranches-file "$NAME".AutoXPAR.SNPs.tranches --recal-file "$NAME".AutoXPAR.SNPs.recal -mode SNP && gatk --java-options \"-Xmx59g\" VariantRecalibrator -R "$Reference" -V "$NAME".chrX.NONPAR.SNPs.vcf.gz -O "$NAME".chrX.NONPAR.SNPs.recal -resource:array,known=false,training=true,truth=true,prior=12.0 "$Resource" --use-annotation QD --use-annotation MQ --use-annotation MQRankSum --use-annotation ReadPosRankSum --use-annotation FS --use-annotation SOR --use-annotation DP --trust-all-polymorphic true -mode SNP --max-gaussians 4 --rscript-file "$NAME".X.output.plots.R --tranches-file "$NAME".X.SNP.output.tranches -tranche 100.00 -tranche 99.9 -tranche 99.0 -tranche -98.0 -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 --tmp-dir /lscratch/\$SLURM_JOB_ID/ && gatk --java-options \"-Xmx59g\" ApplyVQSR -R "$Reference" -V "$NAME".AutoXPAR.SNPs.vcf.gz -O Filter/"$NAME".AutoXPAR.SNPs.filtered.vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID/ --truth-sensitivity-filter-level 99.0 --tranches-file "$NAME".AutoXPAR.SNPs.tranches --recal-file "$NAME".AutoXPAR.SNPs.recal -mode SNP && gatk --java-options \"-Xmx59g\" ApplyVQSR -R "$Reference" -V "$NAME".chrX.NONPAR.SNPs.vcf.gz -O Filter/"$NAME".chrX.NONPAR.SNPs.filtered.vcf.gz --tmp-dir /lscratch/\$SLURM_JOB_ID/ --truth-sensitivity-filter-level 99.0 --tranches-file "$NAME".X.SNP.output.tranches --recal-file "$NAME".chrX.NONPAR.SNPs.recal -mode SNP" > VQSR_VariantRecalibrator.swarm
#
more VQSR_VariantRecalibrator.swarm
#
read -p "Does the formatting of the swarmfile appear correct? (yes or no) " promptG
while true; do
        case "$promptG" in
                [YyEeSs]* ) break ;;
                [NnOo]* ) echo "Verify that the inputs are correct and try again"; exit;;
                *) echo "Enter yes or no" ;;
        esac
done
#
jobid7=$(swarm -f VQSR_VariantRecalibrator.swarm -g 72 -t 12 --time 3-0 --gres=lscratch:250 --module GATK/4.2.0.0 --logdir ~/job_outputs/gatk4/VariantRecalibrator/"$SWARM_NAME" --sbatch "--mail-type=ALL,TIME_LIMIT_80 --job-name "$SWARM_NAME"_VariantRecal --dependency=afterok:"$jobid6"")
#
echo
echo
echo "VariantRecalibrator Swarm Job ID #:"
echo $jobid7
