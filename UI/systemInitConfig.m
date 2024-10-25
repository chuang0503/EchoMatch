% Background model Setup
%% configuration
function [config, gallery] = systemInitConfig(frequency_range_low, frequency_range_high, first_K_cepstrum, ...
    renyi_alpha, bch_n, bch_k, bch_t)
config = struct();
%% data preparation
s = load("gallery_data_bckmdl.mat", "gallery_data");
gallery = s.gallery_data;
%% system configuration
% feature representation
config.frequency_range_low = frequency_range_low;  %1000
config.frequency_range_high = frequency_range_high; %8000
config.first_K_cepstrum = first_K_cepstrum; %256

% biometric information
config.renyi_alpha = renyi_alpha; %0

% fuzzy commitment
% load('bch_lookup_table.mat', 'bch_table'); 
% typed into panel

config.bch_n = bch_n;
config.bch_k = bch_k;
config.bch_t = bch_t;
config.ecc_code_size =  config.bch_n;
