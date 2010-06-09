% The following variables should be defined before this script is called:
% LE_SM - Left eye S- (no reward) trials - time stamps for start of trials
% LE_SP - Left eye S+ (rewarded) trials
% RE_SM - Right eye S- (no reward) trials
% RE_SP - Right eye S+ (rewarded) trials 
% fieldtimes - time stamps at each sampling point
% fieldValues - voltage at each time stamp
% licktimes - timestamps of first lick of every trial
% spiketimes
% Nstd
% NE


LE = [LE_SM, LE_SP; ones(1,length(LE_SM)), 2*ones(1,length(LE_SP))];
RE = [RE_SM, RE_SP; 3*ones(1,length(RE_SM)), 4*ones(1,length(RE_SP))];
goggle = [LE, RE]';
goggle = sortrows(goggle);

%From here on, the code is generic
startevent = goggle(:,1)';
endevent = licktimes;
field = [fieldtimes;fieldValues];

windowforeachtrial = endevent-startevent;

numberoftrials = length(startevent);
timebin = (max(fieldtimes) - min(fieldtimes))/length(fieldtimes);%Time bin of sampling
Fs = 1000/timebin; % Sampling rate

backwindow = 500;%window of time before startevent that you are interested in the LFP
fwdwindow = 500;%window of time after endevent that you are interested in the LFP
  

phaseforeachtrialatendevent = 1000*ones(numberoftrials,1);
freqforeachtrial = zeros(numberoftrials,1);
sizeofspikedetails = 40;%Default size of spikephaseforalltrials.
spikephaseforalltrials = 1000*ones(numberoftrials,sizeofspikedetails);
spiketimeforalltrials = zeros(numberoftrials,sizeofspikedetails);

for trial = 2:2%numberoftrials
    
    fprintf('Analyzing trial %d \n',trial);
    startevent_ms = startevent(trial);
    endevent_ms = endevent(trial);
    
    [ allmode,interestingmode,freqosc ] = ...
        findInterestingModes( field, startevent_ms, endevent_ms, ...
        Fs, backwindow, fwdwindow, Nstd, NE );
    
    if length(interestingmode) > 1
        fprintf('NOTE: Multiple interesting modes for trial %d \n Lower frequency mode considered \n',trial);
    end
    %     plot(relevantspikes,spikephase,'o');set(gca,'YLim',[-180,180]);
    
    fieldfortrial = field(:,field(1,:)>(startevent_ms-backwindow));
    fieldfortrial = fieldfortrial(:,fieldfortrial(1,:)< (endevent_ms+fwdwindow));

    spikesfortrial = spiketimes((spiketimes>(startevent_ms-backwindow)));
    spikesfortrial = spikesfortrial((spikesfortrial<(endevent_ms + fwdwindow)));
    spikesfortrial = spikesfortrial - startevent_ms;

    spikephasefortrial = 1000*ones(length(spikesfortrial),1);
    spiketimefortrial = zeros(length(spikesfortrial),1); % This could just have been spikesfortrial. But since the sampling rate of LFP is different from that of spikes, we need to define spiketimes wrt the LFP samples
    
    if length(spikephasefortrial)< sizeofspikedetails
        spikephasefortrial = [spikephasefortrial;1000*ones(sizeofspikedetails-length(spikephasefortrial),1)];
        spiketimefortrial = [spiketimefortrial;zeros(sizeofspikedetails-length(spiketimefortrial),1)];
    elseif length(spikephasefortrial) > sizeofspikedetails
        fprintf('Error: Size > sizeofspikedetails');
    end

    %  ******   Calculate the phase that the spikes occur and readjust spike times   ******
    N = size(allmode,1);
    c = linspace(-backwindow,endevent_ms-startevent_ms+fwdwindow,N);
    if ~isempty(interestingmode)
        [frequency phase]= ifreq(allmode,timebin,interestingmode(end),0,0);
        index = find(diff(c<(backwindow+windowforeachtrial(trial)))<0);
        if ~isempty(index)
            phaseforeachtrialatendevent = phase(index)*360/(2*pi);
        end
        freqforeachtrial = freqosc;
        for ii = 1:length(spikesfortrial)
            idx = find(diff(c<spikesfortrial(ii))<0);
            if ~isempty(idx)
                spikephasefortrial(ii) = phase(idx)*360/(2*pi);
                spiketimefortrial(ii) = c(idx);
            end
        end
    end

    spikephaseforalltrials(trial,:) = spikephasefortrial';
    spiketimeforalltrials(trial,:) = spiketimefortrial';
end