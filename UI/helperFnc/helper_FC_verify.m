function [decodedKey_batch, err] = helper_FC_verify(biohash_code_new, commitment, n, k)
    % inputData: 验证时的输入数据（二进制向量）
    % commitment: 存储的承诺值
    % n: 码字长度
    % k: 信息长度

    % 确保输入的inputData为二进制
    binaryInput = biohash_code_new;
    numTrial = size(binaryInput,1);

    % 通过XOR操作将输入数据与承诺值结合，检索编码密钥
    encodedKey_batch = xor(binaryInput(:,1:n), commitment);

    % 使用BCH码解码密钥
    bchDecoder = comm.BCHDecoder(n, k);
    
    decodedKey_batch = zeros(numTrial,k);
    for i = 1:numTrial
        encodedKey = encodedKey_batch(i,:);
        [decodedKey, err] = step(bchDecoder, encodedKey');
        decodedKey = decodedKey';
        decodedKey_batch(i,:) = decodedKey;
    end
    
end
