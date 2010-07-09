function [ sqd_errors groundtruthw interestingmode fieldtimesw ...
    fieldtimes fieldValues groupName] = calcError( phaseoffset_rad, Nstd, NE, trial_duration )
% Example parameter values:
% phaseoffset_rad = [0,2*pi) = ex. rand()*2*pi
% Nstd = 0.4
% NE = 200
% trial_duration = 1000

Fs = 623.5232;
backwindow = 500;
fwdwindow = 500;
%window = 2500;

fieldtimes = 0:1000/Fs:10000; % create timestamps where LFP was recorded
%timebin = (max(fieldtimes) - min(fieldtimes))/length(fieldtimes);%Time bin of sampling


startevent_ms = 2000;
endevent_ms = startevent_ms + trial_duration;

event_mask = ( fieldtimes >= startevent_ms ) & ( fieldtimes <= endevent_ms );
ground_truth = sin_Hz(fieldtimes, 6.5+rand(), phaseoffset_rad).*event_mask;


fieldValues = ground_truth;
Z = max(fieldValues)-min(fieldValues);

fieldValues = fieldValues/Z;
groundtruth = ground_truth/Z;

load('bandstoppedLFPnoise.mat');
sample_noise = invnoisespec;

L = length(sample_noise);
NFFT = 2^nextpow2(L); % Next power of 2 from length of signal
Y = fft(sample_noise,NFFT);
f = Fs/2*linspace(0,1,NFFT/2+1);

% rebuild signal
rebuilt = ifft( (real(Y)+i*imag(Y)), NFFT);
rebuilt = rebuilt(1:L);

if false % set to true of you want to plot
    plot(f,2*abs(Y(1:NFFT/2+1)/L)) 
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
end

% make sure that the sample noise is as long as the fieldtimes
if length(fieldtimes) > length(sample_noise)
    indexnoise = ceil( length(fieldtimes)/length(sample_noise) );
    sample_noise = repmat(sample_noise,1,indexnoise);
end
% take a random section of sample_noise of length(fieldtimes)
roffset = ceil( rand()*( length(sample_noise) - length(fieldtimes) ));
sample_noise = sample_noise(roffset:roffset+length(fieldtimes)-1);
% scale it, since we also scale the ground truth
sample_noise = sample_noise / ( max(sample_noise)-min(sample_noise) );

whitenoiseweight = .5; %.5;
realnoiseweight = 1; %2.5;

whitenoise = ( rand( size( fieldValues ) ) - .5 );

fieldnoise = whitenoiseweight*whitenoise + realnoiseweight*sample_noise;

groupName = ['Nstd=' num2str(Nstd) ',NE=' num2str(NE) ...
    ',white=' num2str(whitenoiseweight) ',realnoise=' num2str(realnoiseweight)...
    ',trialdur=' num2str(trial_duration) ];

% Add noise
if true
    fieldValues = fieldnoise + fieldValues;
    Z = max(fieldValues) - min(fieldValues);
    fieldValues = fieldValues / Z;
    groundtruth = groundtruth / Z;
end
field = [fieldtimes; fieldValues];

% create versions that correspond to event window
win_mask = (fieldtimes >(startevent_ms-backwindow) & fieldtimes < (endevent_ms+fwdwindow) );
groundtruthw = groundtruth( win_mask )';
fieldtimesw = fieldtimes(win_mask)';

[allmode,indx_interest] ...
            = findInterestingModes( field, startevent_ms, endevent_ms, Fs, backwindow, fwdwindow, Nstd, NE );
        
% if length(indx_interest) > 1
%     fprintf('NOTE: Multiple interesting modes for trial %d \n Lower frequency mode considered \n',trial);
% end

% figure;
% for i = 1:length(indx_interest)
%     subplot(length(indx_interest),1,i); plot(allmode(:,indx_interest(i)));
% end
interestingmode = allmode(:,indx_interest(end));
sqd_errors = ( interestingmode - groundtruthw ) .^ 2;
