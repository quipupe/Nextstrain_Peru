#!/bin/bash
#Number of sequences
grep -c ">" data/sequences.fasta;
#Alignment
augur align --sequences data/sequences.fasta --reference-sequence config/coronavirus.gb --output results/aligned.fasta --nthreads 8;

#Tree reconstruction
augur tree --alignment results/aligned.fasta --output results/tree_raw.nwk --nthreads 8;

#Tree calibration
augur refine --tree results/tree_raw.nwk --alignment results/aligned.fasta --metadata data/metadata.tsv --output-tree results/tree.nwk --output-node-data results/branch_lengths.json --timetree --coalescent opt --clock-rate 0.0008 --clock-std-dev 0.0002 --date-confidence --date-inference marginal --clock-filter-iqd 4 --divergence-units mutations --root hCoV-19/Wuhan/WH01/2019 hCoV-19/Wuhan/IPBCAMS-WH-01/2019 --keep-polytomies;

#Frequencies
augur frequencies --metadata data/metadata.tsv --tree results/tree.nwk --method kde -o auspice/Nextstrain_Peru_tip-frequencies.json --proportion-wide 0.1 --pivot-interval 1 --minimal-frequency 0.1 --minimal-clade-size 1;

#Traits
augur traits --tree results/tree.nwk --metadata data/metadata.tsv --output results/traits.json --columns division --confidence;

#Ancestral reconstruction 
augur ancestral --tree results/tree.nwk --alignment results/aligned.fasta --output-node-data results/nt_muts.json --inference joint; 

#Translation
augur translate --tree results/tree.nwk --ancestral-sequences results/nt_muts.json --reference-sequence config/coronavirus.gb --output results/aa_muts.json;

#Export results
augur export v2 --tree results/tree.nwk --metadata data/metadata.tsv --node-data results/branch_lengths.json results/traits.json results/nt_muts.json results/aa_muts.json --colors config/colors.tsv --lat-longs config/lat_longs.tsv --auspice-config config/auspice_config.json --output auspice/Nextstrain_Peru.json --include-root-sequence;
