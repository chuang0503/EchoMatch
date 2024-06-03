function [commitment, key] = helper_FC_enroll(biohash_code, n, k)
    % biometricData: 原始二进制生物特征数据
    % n: 码字长度
    % k: 信息长度
    % t: 纠错能力
    
    % 确保输入的biometricData为二进制
    binaryData = biohash_code;

    % 生成随机二进制密钥
    key = randi([0, 1], 1, k);

    % 使用BCH码编码密钥
    bchEncoder = comm.BCHEncoder(n, k);
    encodedKey = step(bchEncoder, key')';

    % 创建承诺值，通过XOR操作将二进制数据与编码密钥结合
    commitment = xor(binaryData(1:n), encodedKey);
end
