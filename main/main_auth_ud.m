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
% new_user_auth_ud (struct): containing `label`, `feature`, `randmatrix`,
% `feature_mask`
% config (struct): containing `ecc_code_size`

% Output:
% new_user_auth_ud_to_ae (struct): containing `label`, `hashcode`
%--------------------------------------------------------------------------
function new_user_auth_ud_to_ae = main_auth_ud(new_user_auth_ud, config)

% unpack data
label = new_user_auth_ud.label;
feature = new_user_auth_ud.feature;
randmatrix = new_user_auth_ud.randmatrix;
feature_mask = new_user_auth_ud.feature_mask;

% Invariant feature vector + hashing
hashcode = helper_biohashing_auth(feature .* feature_mask, randmatrix, config.ecc_code_size);

% pack data into struct
new_user_auth_ud_to_ae = struct();
new_user_auth_ud_to_ae.label = label;
new_user_auth_ud_to_ae.hashcode = hashcode;

end