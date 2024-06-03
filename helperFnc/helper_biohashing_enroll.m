% bioHashing enroll
function [biohash_code, Q, estBER] = helper_biohashing_enroll(feat_batch, code_size)

% data size
enroll_num = size(feat_batch,1);
feature_size = size(feat_batch,2);

% user specific information
randomProj = randn(feature_size, code_size); % matrix, tau=0
[Q,~] = qr(randomProj);
% Q = Q(1:feature_size,1:code_size*2);

% hashed code
projectedCode = feat_batch * Q; % batch * code_size
quantCode = projectedCode>=0;

biohash_code = sum(quantCode) > (enroll_num/2);

ber = sum(xor(quantCode,biohash_code)) / enroll_num;

estBER = mean(ber);


end
