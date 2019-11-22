all: stimuli_triplets results.csv

abx_intervals.txt: 
	python src/textgrid_to_abx_item_file_word.py word \
stimuli_raw/textGrid/ stimuli_raw/wav/ > abx_intervals.txt

intervals.csv: abx_intervals.txt
	Rscript --vanilla add_meta_information_to_item_file.Rscript abx_intervals.txt \
phoneme_info.csv intervals.csv

all_triplets.csv.bz2: intervals.csv
	python generate_triplets.py \
--constraints-ab='(language_TGT!=language_OTH)&(language_TGT==language_TGT)&(language_OTH==language_OTH)&(sex_TGT==sex_OTH)&(speaker_TGT!=speaker_OTH)' \
--constraints-ax='(sex_TGT!=sex_X)' intervals.csv all_triplets.csv \
&& bzip2 all_triplets.csv

design.csv: all_triplets.csv.bz2
	bunzip2 -k all_triplets.csv.bz2 \
&& python optimize_design.py --desired-energy .074 --seed 3004 \
all_triplets.csv design.csv \
&& rm all_triplets.csv

pairs.csv: design.csv 
	Rscript --vanilla triplets_to_pairs.Rscript design.csv pairs.csv

distances_by_pair.csv: pairs.csv
	python src/wav_to_distance.py --njobs 1 pairs.csv \
bottleneck_config_shennong.yaml distances_by_pair.csv

triplets.csv: distances_by_pair.csv
	Rscript --vanilla distance_pairs_to_triplets.Rscript \
distances_by_pair.csv triplets.csv

exp_length_stim_list.csv: triplets.csv
	Rscript --vanilla stimuli_selection.Rscript \
triplets.csv exp_length_stim_list.csv

final_stimuli_list.csv:  exp_length_stim_list.csv
	python optimize_design.py --desired-energy .0001 --seed 3005 \
exp_length_stim_list.csv final_stimuli_list.csv

stimuli_triplets: triplets.csv
	python save_triplets_to_wavs.py triplets.csv stimuli_triplets 

lmeds_output/raw: 
	mkdir -p lmeds_output_raw && python \
../../src/anonymize_lmeds_data_filenames.py ${RAW_DATA_PATH} lmeds_output/raw \
${ANON_KEY_PATH}

lmeds_output/csv: lmeds_output/raw
	mkdir -p lmeds_output/csv && python split_output_to_results_files.py \
lmeds_output/raw lmeds_output/raw/responses.csv \
lmeds_output/raw/presurvey.csv lmeds_output/raw/postsurvey.csv \
lmeds_output/raw/postsurvey2.csv

results.csv: lmeds_output/csv triplets.csv
	Rscript --vanilla preprocess.Rscript lmeds_output/csv/presurvey.csv \
lmeds_output/csv/results.csv lmeds_output/csv/postsurvey.csv \
lmeds_output/csv/postsurvey2.csv triplets.csv results.csv




