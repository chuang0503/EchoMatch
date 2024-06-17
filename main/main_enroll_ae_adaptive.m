% main_enroll_ae.m 
% This script handles the authentication engine (AE) side
% of the enrollment phase. It receives the biometric features from the user
% device (UD), estimates the user's feature probability density function
% (PDF), evaluates the biometric information, generates an invariant
% feature mask, creates a random matrix for BioHashing, generates a random
% key for the new user, and finally creates a fuzzy commitment. It also
% transmits the random matrix for BioHashing back to the UD.
%
% Input: 
% user_data_enroll_ud2ae (struct): containing `label`, `ceps_feature`;
% gallery_data (struct), containing `feature`, `stat_mean`, `stat_std`,
% `prob_density`; 
% config (struct): containing bch/ecc parameter;

% Output: user_data_enrolled_ae (struct): containing `label`, `randmatrix`,
% `key`, `commitment`, `gallery_stat_mean`, `gallery_stat_std` ; 
% analysis (struct): `biometric_information`,
% `feature_mask`, `hashcode`, `legit_bit_err`, `intrude_bit_err`.
%-------------------------------------------------------------------------
function [user_data_enrolled_ae, user_data_enrolled_ud, analysis] = ...
    main_enroll_ae_adaptive(user_data_enroll_ud2ae, gallery_data, config)

assert(numel(user_data_enroll_ud2ae)==1, "Only enroll one user each time")

% retrieve gallery_data pdf and configuration

% receive ud data
label = user_data_enroll_ud2ae.label;
ceps_feature = user_data_enroll_ud2ae.ceps_feature;

% normalize ceps feaeture
feature = (ceps_feature - gallery_data.stat_mean) ./ (gallery_data.stat_std +eps);

[pdf,~] = helper_pdfest(feature);

% bioinformation mask
[bioinfo, bmask] = helper_biofeatmask(pdf,gallery_data.prob_density,config.renyi_alpha);

% biohashing
[legit_hashcode, Q, legit_bit_err] = helper_biohashing_enroll(feature.*bmask, config.ecc_code_size);

% quanlity control
N = config.intruder_sample_number;
intruder_feature = datasample(gallery_data.feature,N,'Replace',true);
intruder_hashcode = helper_biohashing_auth(intruder_feature.*bmask, Q, config.ecc_code_size);
intruder_bit_err = sum(xor(intruder_hashcode,legit_hashcode), 2);

% fuzzy commitment
[commitment, key] = helper_FC_enroll(legit_hashcode, config.bch_n, config.bch_k);

% store at server
user_data_enrolled_ae = struct();
user_data_enrolled_ae.label = label;
user_data_enrolled_ae.key = key;
user_data_enrolled_ae.commitment = commitment;

% store at user
user_data_enrolled_ud = struct();
user_data_enrolled_ud.label = label;
user_data_enrolled_ud.randmatrix = Q;
user_data_enrolled_ud.feature_mask = bmask;
user_data_enrolled_ud.gallery_stat_mean = gallery_data.stat_mean;
user_data_enrolled_ud.gallery_stat_std = gallery_data.stat_std;


% saved for further analysis
analysis = struct();
analysis.label = label;
analysis.enroll_pdf = pdf;
analysis.enroll_bioinfo = bioinfo;
analysis.enroll_hashcode = legit_hashcode;
analysis.enroll_legit_bit_err = legit_bit_err;
analysis.enroll_intruder_bit_err = intruder_bit_err;

end


