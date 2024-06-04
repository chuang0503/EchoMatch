% bioHashing enroll
function biohash_code = helper_biohashing_auth(feat_batch, Q, code_size)


% hashed code
projectedCode = feat_batch * Q; % batch * code_size
projectedCode = projectedCode(:,1:code_size);
quantCode = projectedCode>=0;

biohash_code = quantCode;

end
