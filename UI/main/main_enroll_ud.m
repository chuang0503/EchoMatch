% main_enroll_ud.m 
%--------------------------------------------------------------------------
% This script is responsible for the user device (UD) side of the
% enrollment phase. It captures a batch of raw ear canal response
% (fft_feature) from the new user, performs feature extraction
% (ceps_response), and then sends the extracted biometric features to the
% authentication engine (AE) for further processing.
%
% Input: 
% user_data_enroll_ud (struct): containing `label`, `fft_feature`, `freqency_vector`; 
% config (struct): containing pre=processing parameter;

% Output: 
% user_data_enroll_ud2ae (struct): containing `label`, `ceps_feature`;
%-------------------------------------------------------------------------
function user_data_enroll_ud2ae = main_enroll_ud(user_data_enroll_ud, config)

% unpack data
label = user_data_enroll_ud.label;
fft_feature = user_data_enroll_ud.fft_feature;
frequency_vector = user_data_enroll_ud.frequency_vector;

% pre-processing
ceps_feature = helper_fft2ceps(fft_feature, frequency_vector, ...
    config.frequency_range_low, config.frequency_range_high, ...
    config.first_K_cepstrum);

% pack data to ae
user_data_enroll_ud2ae = struct();
user_data_enroll_ud2ae.label = label;
user_data_enroll_ud2ae.ceps_feature = ceps_feature;

end