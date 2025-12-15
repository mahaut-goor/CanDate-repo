Here are all the scripts and data used for the estimation of molucular age.

############################## BAM2FASTA
1) if you have .bam files, you should first extract the mt reads and create the consensus
==> Use the script /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/bam2MTfasta.sh

Optionnaly, you can also extract some statistics such as coverage, number of reads & depths of coverage using /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/getStatsMT.sh

############################## ALIGN + TRIMM
2) The first step for tip dating is to align the sample consensus to the database of radiocarbon dated samples (which is already aligned) 
==> Use /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/runMafftTrimal.sh

############################## CREATE XML
3) After aligning the taregt sequence to the database, we will create the xml file that can then be used in beast
==> Use /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/ParseXmlST.py

############################## ESTIMATE TIPS 
4) Uisng the created xml, we can run the chains fro the tip dating analysis
==> Use /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/tip_dating_v2.sh

############################## COMBINE LOGS & TREES
5) Then we can combine the logs & treefiles into -combined.logs
==> Use /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/combineLogsTrees.sh

############################## EXTRACT TIP AGES
6) use this script to extract the tip ages from the logsfiles 
==> use /dss/dsshome1/09/re98gan/ANALYSIS/tip_dating/bam2tipDating_pipeline/ExtractTipDate.sh
