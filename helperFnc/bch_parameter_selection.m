% BCH code parameters
n = 255; % code length
k = 123; % message length
t = 2;  % error-correcting capability

induced_noise = 20;

% Generate a BCH encoder and decoder
bchEncoder = comm.BCHEncoder(n, k);
bchDecoder = comm.BCHDecoder(n, k);

% Generate a random message
msg = randi([0 1], k, 1);

% Encode the message
codeword = bchEncoder(msg);

% Introduce errors (example: 2-bit errors)
errorPattern = zeros(n, 1);
errorPattern(randperm(n,induced_noise)) = 1; % Introduce errors at positions 10 and 20

% Transmit the codeword through a noisy channel (add errors)
receivedCodeword = xor(codeword, errorPattern);

% Decode the received codeword
[decodedMsg, err] = bchDecoder(receivedCodeword);

% Check if the decoding is successful
numErrors = sum(err);
isDecodingSuccessful = isequal(msg, decodedMsg);

% Display the results
fprintf('Original Message:      %s\n', num2str(msg'));
fprintf('Encoded Codeword:      %s\n', num2str(codeword'));
fprintf('Received Codeword:     %s\n', num2str(receivedCodeword'));
fprintf('Decoded Message:       %s\n', num2str(decodedMsg'));
fprintf('Number of Errors Detected: %d\n', numErrors);
fprintf('Decoding Successful:   %d\n', isDecodingSuccessful);
