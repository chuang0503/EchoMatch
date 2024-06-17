function [commitment, key, k] = helper_FC_enroll_adaptive(biohash_code, n, tmin, tmax)
% biometricData: 原始二进制生物特征数据
% n: 码字长度
% k: 信息长度
% t: 纠错能力

% 确保输入的biometricData为二进制
binaryData = biohash_code;

% 使用合适的纠错能力

T = bchnumerr(n);
t_list = T(:,3);
k_list = T(:,2);

idx = find(t_list>tmin&&t_list<tmax,1);
k = k_list(idx);
t = t_list(idx);


% 生成随机二进制密钥
key = randi([0, 1], 1, k);

% 使用BCH码编码密钥
bchEncoder = comm.BCHEncoder(n, k);
encodedKey = step(bchEncoder, key')';

% 创建承诺值，通过XOR操作将二进制数据与编码密钥结合
commitment = xor(binaryData(1:n), encodedKey);
end
