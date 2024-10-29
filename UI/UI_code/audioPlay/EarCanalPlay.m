% to do: visualization
function [rec,noError] = EarCanalPlay(apr,audioFile,outputLevel)
%% Device Settings
% apr = audioPlayerRecorder; 
% apr.Device = "USB Sound Device: Audio (hw:2,0)";
% apr.SampleRate=48000;
% Device = apr.Device;
L = apr.BufferSize;
fs = apr.SampleRate;
% nbPlayCh = 2;			% Total number of playback channels
% nbRecCh = 2;			% Total number of recorder channels
%% Method Settings (Normal audio content: music/speech)
afr = dsp.AudioFileReader(audioFile,"SamplesPerFrame",L);
% Allocate the input/output buffers
sequenceLength = afr.TotalSamples;
% bufExc = dsp.AsyncBuffer(sequenceLength+L);
bufRec = dsp.AsyncBuffer(sequenceLength+2*L);

% Copy the excitation to the output buffer (including one extra
% frame of silence to account for minimum latency of one frame)
% write(bufExc,zeros(L,nbPlayCh));
%% Play and capture using the selected device
% Setup the capture device
% setup(apr,zeros(L,nbPlayCh));
noError = true;
scale = 10^(outputLevel/20);
% Playback and capture loop
while ~isDone(afr)
    x = afr();
    x = x .* scale;
    [y,under,over] = apr(x);
    if under>0 || over>0
        noError = false;
        break;
    else
        % write(bufExc,x);
        write(bufRec,y);
    end
end
% write(bufExc,zeros(L,nbPlayCh));

% Release the audio device
release(apr);
release(afr);
%% Compute the results
read(bufRec,L);
rec = read(bufRec);
% dis = read(bufExc);
% Get the recording from the input buffer, but throw
% away the first frame (minimum latency is one frame)