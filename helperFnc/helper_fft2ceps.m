function data_ceps = helper_fft2ceps(fft_raw,freqVec,LOW_FREQ,HIGH_FREQ)
Nfft = length(freqVec);
freq_activate = (freqVec>LOW_FREQ & freqVec<HIGH_FREQ)';
fft_norm = fft_raw .* freq_activate;
fft_norm = fft_norm ./ sum(fft_norm,2);

data_ceps = dct(log(max(fft_norm,eps)),Nfft,2);
end