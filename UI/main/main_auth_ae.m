% main_auth_ae.m
%--------------------------------------------------------------------------
% This script deals with the authentication engine (AE) side of the
% authentication phase. It receives the hashcode and claimed identity from
% the user device (UD), applies the hashcode to the fuzzy commitment,
% decode the ECC into key, compares it with the stored key, and makes an
% authentication user_auth_decision. The user_auth_decision is then transmitted back to the UD.
%--------------------------------------------------------------------------
% Input:
% user_data_auth_ud2ae (struct): containing `label`, `hashcode`
% user_data_enrolled_ae (table): containing `label`, `commitment`, `key`
% config (struct): containing bcg/ecc parameter

% Output:
% `user_auth_decision` (bool array)
%--------------------------------------------------------------------------
function user_auth_decision = main_auth_ae(user_data_auth_ud2ae, ...
    user_data_enrolled_ae, config)

% unpack data

% new from ud/config
label_claim = user_data_auth_ud2ae.label;
hashcode_new = user_data_auth_ud2ae.hashcode;

% size
trial_number = size(hashcode_new,1);
bchDecoder = comm.BCHDecoder(config.bch_n,config.bch_k);

% find info stored in ae
user_id = find(user_data_enrolled_ae.label==label_claim, 1);
if isempty(user_id)
    error("User not enrolled!")
else
    stored_data = table2struct(user_data_enrolled_ae(user_id,:));
    commitment = stored_data.commitment;
    key = stored_data.key;
end

% verify the user
encoded_batch = xor(commitment, hashcode_new);
decoded_batch = zeros(trial_number,config.bch_k);
for i = 1:trial_number
    encoded_key = encoded_batch(i,:);
    [decoded_key, ~] = step(bchDecoder, encoded_key');
    decoded_batch(i,:) = decoded_key';
end

% ouput
user_auth_decision = any(xor(decoded_batch,key),2);

end