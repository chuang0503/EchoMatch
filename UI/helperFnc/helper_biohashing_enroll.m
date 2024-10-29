% bioHashing enroll
function [biohash_code, Q, bit_error] = helper_biohashing_enroll(feat_batch, code_size)

% data size
enroll_num = size(feat_batch,1);
feature_size = size(feat_batch,2);

% user specific information
randomProj = randn(feature_size); % matrix, tau=0
[Q,~] = qr(randomProj);
% Q = Q(1:feature_size,1:code_size*2);

% hashed code
projectedCode = feat_batch * Q; % batch * code_size
projectedCode = projectedCode(:,1:code_size);
quantCode = projectedCode>=0;

biohash_code = sum(quantCode) > (enroll_num/2);

bit_error = sum(xor(quantCode,biohash_code), 2);


end
