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
% new_user_enroll_ud (struct): containing `label`, `feature`,
% `prob_density`
% gallery (struct), containing `feature`, `prob_density`
% config (struct): containing bch/ecc parameter
% runmode: "analysis": generate extra data /"compact": generate needed data

% Output:
% new_user_enroll_ae (struct):
%   "compact": `label`, `randmatrix`, `key`, `commitment`
%   "analysis": (extra) `biometric_information`, `feature_mask`, `hashcode`,
%   `legit_bit_err`, `intrude_bit_err`
%-------------------------------------------------------------------------
function new_user_enroll_ae = ...
    main_enroll_ae(new_user_enroll_ud, gallery, config, runmode)

assert(runmode=="compact"|runmode=="analysis", "Define a mode")
assert(numel(new_user_enroll_ud)==1, "Only enroll one user")

% initiate output struct
new_user_enroll_ae = struct();

% retrieve gallery pdf and configuration

% receive ud data
label = new_user_enroll_ud.label;
feature = new_user_enroll_ud.feature;
pdf = new_user_enroll_ud.prob_density;

% bioinformation mask
[bioinfo, bmask] = helper_biofeatmask(pdf,gallery.prob_density,config.renyi_alpha);

% biohashing
[legit_hashcode, Q, legit_bit_err] = helper_biohashing_enroll(feature.*bmask, config.ecc_code_size);

% quanlity control
N = size(feature,1);
intruder_feature = datasample(gallery.feature,N,'Replace',true);
intruder_hashcode = helper_biohashing_auth(intruder_feature.*bmask, Q);
intruder_bit_err = sum(xor(intruder_hashcode,legit_hashcode), 2);

% fuzzy commitment
[commitment, key] = helper_FC_enroll(legit_hashcode, config.bch_n, config.bch_k);

% store at server
% new_user_enroll_ae (struct):
%   "compact": `label`, `randmatrix`, `key`, `commitment`
%   "analysis": (extra) `biometric_information`, `feature_mask`, `hashcode`,
%   `legit_bit_err`, `intrude_bit_err`
if runmode == "compact"
    new_user_enroll_ae.label = label;
    new_user_enroll_ae.randmatrix = Q;
    new_user_enroll_ae.key = {key};
    new_user_enroll_ae.commitment = {commitment};
elseif runmode == "analysis"
    new_user_enroll_ae.label = label;
    new_user_enroll_ae.randmatrix = Q;
    new_user_enroll_ae.key = {key};
    new_user_enroll_ae.commitment = {commitment};

    new_user_enroll_ae.bioinfo = bioinfo;
    new_user_enroll_ae.feature_mask = {bmask};
    new_user_enroll_ae.hashcode = {legit_hashcode};
    new_user_enroll_ae.legit_bit_err = legit_bit_err;
    new_user_enroll_ae.intruder_bit_err = intruder_bit_err;
else
    disp("Incorrect mode!")
end
end


