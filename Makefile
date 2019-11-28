all: stimuli_triplets results.csv

abx_intervals.txt: 
	python 1_stimuli/textgrid_to_abx_item_file_word.py word \
stimuli/stimuli_raw/textGrid/ stimuli/stimuli_raw/wav/ > abx_intervals.txt

intervals.csv:
	Rscript --vanilla 1_stimuli/add_meta_information_to_item_file.Rscript abx_intervals.txt \
phoneme_info.csv intervals.csv

all_triplets.csv.bz2: 
	python 1_stimuli/generate_triplets.py \
--constraints-ab='(language_TGT!=language_OTH)&(language_TGT==language_TGT)&(language_OTH==language_OTH)&(sex_TGT==sex_OTH)&(speaker_TGT!=speaker_OTH)' \
--constraints-ax='(sex_TGT!=sex_X)' intervals.csv all_triplets.csv \
&& bzip2 all_triplets.csv

design.csv: 
	bunzip2 -k all_triplets.csv.bz2 \
&& python 1_stimuli/optimize_design.py --desired-energy .074 --seed 3004 \
all_triplets.csv design.csv \
&& rm all_triplets.csv

pairs.csv: 
	Rscript --vanilla 1_stimuli/triplets_to_pairs.Rscript design.csv pairs.csv

distances_by_pair.csv: 
	python 1_stimuli/wav_to_distance.py --njobs 1 pairs.csv \
bottleneck_config_shennong.yaml distances_by_pair.csv

triplets.csv: 
	Rscript --vanilla 1_stimuli/distance_pairs_to_triplets.Rscript \
distances_by_pair.csv triplets.csv

exp_length_pairs.csv: 
	Rscript --vanilla 1_stimuli/stimuli_selection.Rscript \
1_stimuli/distances_by_pair.csv exp_length_pairs.csv \
&&	Rscript --vanilla 1_stimuli/distance_pairs_to_triplets.Rscript \
exp_length_pairs.csv exp_length_triplets.csv

final_stimuli_list.csv:  exp_length_stim_list.csv
	python 1_stimuli/optimize_design.py --desired-energy .0001 --seed 3005 \
exp_length_triplets.csv final_stimuli_list.csv

stimuli_triplets: triplets.csv
	python 1_stimuli/save_triplets_to_wavs.py triplets.csv stimuli_triplets 

run_brms_mods: 
	Rscript --vanilla 2_validation/run_brms_mods.R new_144 dinst2_30subjs \
	2_validation/model_fits_rds/

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




