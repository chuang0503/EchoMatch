%% simulation configuration
config = struct();
%% simulation configuration
% data split
config.gallery_user_number = 41;
config.new_user_number = 1;
config.new_user_enroll_size = 8;
config.intruder_sample_number = 8;
%% system configuration
% feature representation
config.frequency_range_low = 1000;
config.frequency_range_high = 8000;
config.first_K_cepstrum = 256;

% biometric information
config.renyi_alpha = 0;

% fuzzy commitment
load('bch_lookup_table.mat', 'bch_table');
disp(bch_table);
k = input("raw no.");
config.bch_n = bch_table.n(k);
config.bch_k = bch_table.k(k);
config.bch_t = bch_table.t(k);
config.ecc_code_size =  config.bch_n;

%% clear variables
clear bch_table k