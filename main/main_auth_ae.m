% main_auth_ae.m
%--------------------------------------------------------------------------
% This script deals with the authentication engine (AE) side of the
% authentication phase. It receives the hashcode and claimed identity from
% the user device (UD), applies the hashcode to the fuzzy commitment,
% decode the ECC into key, compares it with the stored key, and makes an
% authentication decision. The decision is then transmitted back to the UD.
%--------------------------------------------------------------------------
% Input:
% new_user_auth_ud_to_ae (struct): containing `label`, `hashcode`
% new_user_enroll_ae (table): containing `label`, `commitment`, `key`
% config (struct): containing bcg/ecc parameter

% Output:
% `decision` (bool array)
%--------------------------------------------------------------------------
function decision = main_auth_ae(new_user_auth_ud_to_ae, ...
    new_user_enroll_ae, config)

% unpack data

% new from ud/config
label_claim = new_user_auth_ud_to_ae.label;
hashcode_new = new_user_auth_ud_to_ae.hashcode;

% size
trial_number = size(hashcode_new,1);
bchDecoder = comm.BCHDecoder(config.bch_n,config.bch_k);

% find info stored in ae
user_id = find(new_user_enroll_ae.label==label_claim, 1);
if isempty(user_id)
    error("User not enrolled!")
else
    stored_data = table2struct(new_user_enroll_ae(user_id,:));
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
decision = any(xor(decoded_batch,key),2);

end