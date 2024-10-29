% to do: latency compensation
function [ir,noError] = EarCanalScan(apr,exc_method,outputLevel)
%% Device Settings
% apr = audioPlayerRecorder;
% apr.Device = "USB Sound Device: Audio (hw:2,0)";
% apr.SampleRate=48000;
L = apr.BufferSize;
fs = apr.SampleRate;
nbPlayCh = 2;			% Total number of playback channels
nbRecCh = 2;			% Total number of recorder channels
%% Method Settings (MLS)

% outputLevel = -40;		% Excitation Level (dBFS)


if exc_method == "MLS"
    nbRunsTotal = 2;		% Number of Runs
    nbWarmUps = 1;			% Number of warm-up runs
    durationPerRun = 0.5; 	% Duration per Run (s)
    exc = mls(ceil(durationPerRun*fs), ...
        ExcitationLevel=outputLevel);
    % Add startup silence
    lengthStartSilence = max(ceil(0.1*fs),L);
    startSilence = zeros(lengthStartSilence,nbPlayCh);
    excSequence = [ ...
        startSilence; ...
        repmat(exc,nbRunsTotal,nbPlayCh)];
elseif exc_method == "chirp"
    nbRunsTotal = 1;		% Number of Runs
    nbWarmUps = 0;			% Number of warm-up runs
    durationPerRun = 0.55; 	% Duration per Run (s)
    pauseBetween = 0.05;		% Pause between runs (s)
    sweepRange = [20 22050]; % Sweep start/stop frequency (Hz)
    sweepDur = 0.5;			% Sweep Duration (s)
    irDur = durationPerRun - sweepDur;
    exc = sweeptone( ...
        sweepDur,irDur,fs, ...
        ExcitationLevel=outputLevel, ...
        SweepFrequencyRange=sweepRange);
    % Add startup silence
    lengthStartSilence = max(ceil(0.1*fs),L);
    startSilence = zeros(lengthStartSilence,nbPlayCh);
    excSequence = [ ...
        startSilence; ...
        repmat(exc,nbRunsTotal,nbPlayCh)];
elseif exc_method == "inaudible"
    nbRunsTotal = 1;		% Number of Runs
    nbWarmUps = 0;			% Number of warm-up runs
    durationPerRun = 0.55; 	% Duration per Run (s)
    pauseBetween = 0.05;		% Pause between runs (s)
    sweepRange = [18000 24000]; % Sweep start/stop frequency (Hz)
    sweepDur = 0.5;			% Sweep Duration (s)
    irDur = durationPerRun - sweepDur;
    exc = sweeptone( ...
        sweepDur,irDur,fs, ...
        ExcitationLevel=outputLevel, ...
        SweepFrequencyRange=sweepRange);
    % Add startup silence
    lengthStartSilence = max(ceil(0.1*fs),L);
    startSilence = zeros(lengthStartSilence,nbPlayCh);
    excSequence = [ ...
        startSilence; ...
        repmat(exc,nbRunsTotal,nbPlayCh)];
end
%% Prepare the output signal
% Allocate the input/output buffers
% disp(size(excSequence));
sequenceLength = size(excSequence,1);
bufExc = dsp.AsyncBuffer(sequenceLength+L);
bufRec = dsp.AsyncBuffer(sequenceLength+2*L);

% Copy the excitation to the output buffer (including one extra
% frame of silence to account for minimum latency of one frame)
write(bufExc,excSequence);
write(bufExc,zeros(L,nbPlayCh));
%% Play and capture using the selected device
% Setup the capture device
% setup(apr,zeros(L,nbPlayCh));
noError = true;

% Playback and capture loop
while bufExc.NumUnreadSamples > 0
    x = read(bufExc,L);
    [y,under,over] = apr(x);
    write(bufRec,y);
    if under>0 || over>0
        noError = false;
        break;
    end
end

% Release the audio device
release(apr);

% Get the recording from the input buffer, but throw
% away the first frame (minimum latency is one frame)
read(bufRec,L);
rec = read(bufRec);
recWithoutSilence = rec(size(startSilence,1)+1:end,:);
recWithoutSilence = recWithoutSilence(1:nbRunsTotal*size(exc,1),:);
% disp(size(recWithoutSilence));
% Compute the impulse response of the recording
ir = impzest(exc,recWithoutSilence,WarmupRuns=nbWarmUps);
end