% Script written by Vijay
% This will analyze the LFP recordings for oscillations in windows around two events.
% The events are called as startevent and endevent. Note that the actual
% analysis window is longer than that defined by these two events. This is
% because Hilbert transform doesn't work all that well near the ends of a
% window. So, phase information of the LFP is extracted for a total window
% duration of backwindow+window+fwdwindow, where backwindow is the extra
% window before the startevent and fwdwindow is the extra window after the
% endevent. Phases are read out at spiketimes



% This block extracts startevent and endevent. In this case, startevent =
% goggle and endevent = licktime

nex = actxserver('NeuroExplorer.Application');
doc = nex.OpenDocument('F:\acads\HuShu lab\data\2010_VJ_003\2010-3-10_16-2-53\2010_003_3_10.nex');
temp = doc.Variable('EvS_LE_SMToLBB');
LE_SM = temp.Timestamps()*1E3;
temp = doc.Variable('EvS_LE_SPToLBB');
LE_SP = temp.Timestamps()*1E3;
temp = doc.Variable('EvS_RE_SMToLBB');
RE_SM = temp.Timestamps()*1E3;
temp = doc.Variable('EvS_RE_SPToLBB');
RE_SP = temp.Timestamps()*1E3;
LE = [LE_SM, LE_SP; ones(1,length(LE_SM)), 2*ones(1,length(LE_SP))];
RE = [RE_SM, RE_SP; 3*ones(1,length(RE_SM)), 4*ones(1,length(RE_SP))];
goggle = [LE, RE]';
goggle = sortrows(goggle);
field = doc.Variable('CSC1');
neuron = doc.Variable('Sc1a');
fieldValues = field.ContinuousValues();
fieldtimes = field.Timestamps()*1E3;
temp = doc.Variable('EvE_BothToLBB');
licktimes = temp.Timestamps()*1E3;

%From here on, the code is generic
startevent = goggle(:,1)';
endevent = licktimes;
field = [fieldtimes;fieldValues];
spiketimes = neuron.Timestamps()*1E3;


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
    fieldfortrial = field(:,field(1,:)>(startevent(trial)-backwindow));
    fieldfortrial = fieldfortrial(:,fieldfortrial(1,:)< (endevent(trial)+fwdwindow));
    
    spikesfortrial = spiketimes((spiketimes>(startevent(trial)-backwindow)));
    spikesfortrial = spikesfortrial((spikesfortrial<(endevent(trial) + fwdwindow)));
    spikesfortrial = spikesfortrial - startevent(trial);
    
    spikephasefortrial = 1000*ones(length(spikesfortrial),1);
    spiketimefortrial = zeros(length(spikesfortrial),1); % This could just have been spikesfortrial. But since the sampling rate of LFP is different from that of spikes, we need to define spiketimes wrt the LFP samples
    
    allmode = eemd(fieldfortrial(2,:),0.4,100);
    interestingmode = [];
    for mode = 2:size(allmode,2)
        [f, powerY] = fouriercorrected(allmode(:,mode)',Fs,'hamming');
%         figure, plot(f,powerY);
        index = find(diff(f>3)>0);% There's a lot of power at low frequencies (less than 3Hz) which is not to be included in this calculation
        [c, i] = max(powerY(index+1:end)); 
        if (f(i+index)>= 5) && (f(i+index)<=8)%If the mode has frequency components between 5 and 8 Hz, then it is interesting
            interestingmode = [interestingmode mode];
            freqosc = f(i+index);
        end
    end
    if length(interestingmode) > 1
        fprintf('NOTE: Multiple interesting modes for trial %d \n Lower frequency mode considered \n',trial);
    end
    for i = 1:3
        figure;
        for j = 1:4
            subplot(4,1,j);plot(allmode(:,4*(i-1)+j));
        end        
    end
%     subplot(2,1,1);plot(allmode(:,1));
%     subplot(2,1,2);plot(allmode(:,interestingmode(end)));
    N = size(allmode,1);
    c = linspace(-backwindow,endevent(trial)-startevent(trial)+fwdwindow,N);
    if ~isempty(interestingmode)
        [frequency phase]= ifreq(allmode,timebin,interestingmode(end),0,0);
        index = find(diff(c<(backwindow+windowforeachtrial(trial)))<0);
        if ~isempty(index)
            phaseforeachtrialatendevent(trial) = phase(index)*360/(2*pi);
        end
        freqforeachtrial(trial) = freqosc;
        for ii = 1:length(spikesfortrial)
            idx = find(diff(c<spikesfortrial(ii))<0);
            if ~isempty(idx)
                spikephasefortrial(ii) = phase(idx)*360/(2*pi);
                spiketimefortrial(ii) = c(idx);
            end
        end
    end
    if length(spikephasefortrial)< sizeofspikedetails
        spikephasefortrial = [spikephasefortrial;1000*ones(sizeofspikedetails-length(spikephasefortrial),1)];
        spiketimefortrial = [spiketimefortrial;zeros(sizeofspikedetails-length(spiketimefortrial),1)];
    elseif length(spikephasefortrial) > sizeofspikedetails
        fprintf('Error: Size > sizeofspikedetails');
    end
    spikephaseforalltrials(trial,:) = spikephasefortrial';
    spiketimeforalltrials(trial,:) = spiketimefortrial';
%     plot(relevantspikes,spikephase,'o');set(gca,'YLim',[-180,180]);
end
save('F:\acads\HuShu lab\data\spikedetails_3_10new.mat','spikephaseforalltrials','spiketimeforalltrials');

