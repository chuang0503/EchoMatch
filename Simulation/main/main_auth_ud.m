% main_auth_ud.m
% -------------------------------------------------------------------------
% This script manages the user device (UD) side of the
% authentication phase. It captures a new biometric data point from the
% user, performs feature extraction (not included), apply feature mask, and
% applies BioHashing to generate a hashcode. The hashcode and the claimed
% identity are then sent to the authentication engine (AE) for
% verification.
%--------------------------------------------------------------------------
% Input:
% user_data_auth_ud (struct): containing `label`, `fft_feature`; 
% user_data_enrolled_ud (struct): containing `randmatrix`, `feature_mask`, 
% `gallery_stat_mean` `gallery_stat_std`;
% config (struct): containing `ecc_code_size`

% Output:
% user_data_auth_ud2ae (struct): containing `label`, `hashcode`
%--------------------------------------------------------------------------
function user_data_auth_ud2ae = main_auth_ud(user_data_auth_ud, ...
    user_data_enrolled_ud, config)

% unpack data
label = user_data_auth_ud.label;
fft_feature = user_data_auth_ud.fft_feature;
frequency_vector = user_data_auth_ud.frequency_vector;

randmatrix = user_data_enrolled_ud.randmatrix;
feature_mask = user_data_enrolled_ud.feature_mask;
gallery_stat_mean = user_data_enrolled_ud.gallery_stat_mean;
gallery_stat_std = user_data_enrolled_ud.gallery_stat_std;

% pre-processing
ceps_feature = helper_fft2ceps(fft_feature, frequency_vector, ...
    config.frequency_range_low, config.frequency_range_high, ...
    config.first_K_cepstrum);

% normalization
feature = (ceps_feature - gallery_stat_mean) ./ (gallery_stat_std +eps);

% Invariant feature vector + hashing
hashcode = helper_biohashing_auth(feature .* feature_mask, randmatrix, config.ecc_code_size);

% pack data into struct
user_data_auth_ud2ae = struct();
user_data_auth_ud2ae.label = label;
user_data_auth_ud2ae.hashcode = hashcode;

end