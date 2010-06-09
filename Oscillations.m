function [spikephaseforeachtrial,spiketimeforeachtrial] = Oscillations( LE_SM, LE_SP, RE_SM, RE_SP, field12, licktimes, spiketimes )
% LE_SM - Left eye S- (no reward) trials - time stamps for start of trials
% LE_SP - Left eye S+ (rewarded) trials
% RE_SM - Right eye S- (no reward) trials
% RE_SP - Right eye S+ (rewarded) trials 
% field12 - [times; values] where
%		times - time stamps at each sampling point
%		values - voltage at each time stamp
% licktimes - timestamps of first lick of every trial
% spiketimes

%nex = actxserver('NeuroExplorer.Application');
%doc = nex.OpenDocument('F:\acads\HuShu lab\data\2010_VJ_003\2010-3-10_16-2-53\2010_003_3_10.nex');
%'F:\acads\HuShu lab\data\2010_VJ_003\2010-2-28_16-59-55\2010_003_2_28.nex'
%'F:\acads\HuShu lab\data\2010_VJ_003\2010-3-1_11-0-6\2010_003_3_1.nex'


%temp = doc.Variable('EvS_LE_SMToLBB');
%LE_SM = temp.Timestamps()*1E3;
%temp = doc.Variable('EvS_LE_SPToLBB');
%LE_SP = temp.Timestamps()*1E3;
%temp = doc.Variable('EvS_RE_SMToLBB');
%RE_SM = temp.Timestamps()*1E3;
%temp = doc.Variable('EvS_RE_SPToLBB');
%RE_SP = temp.Timestamps()*1E3;

LE = [LE_SM, LE_SP; ones(1,length(LE_SM)), 2*ones(1,length(LE_SP))];
RE = [RE_SM, RE_SP; 3*ones(1,length(RE_SM)), 4*ones(1,length(RE_SP))];
goggle = [LE, RE]';
goggle = sortrows(goggle);
%goggle(:,1) = [];
%save('trialdetails_3_10new.mat','goggle');


field12times=field12(1,:);
field12Values=field12(2,:);

%field12 = doc.Variable('CSC1');
%neuron = doc.Variable('Sc1a');
%spiketimes = neuron.Timestamps()*1E3;
%field12Values = field12.ContinuousValues();
%field12times = field12.Timestamps()*1E3;
%field12 = [field12times;field12Values];
%temp = doc.Variable('EvS_BothToLBB');
%goggle = temp.Timestamps()*1E3;
%temp = doc.Variable('EvE_BothToLBB');
%licktimes = temp.Timestamps()*1E3;
waitbeforelick = licktimes - goggle(:,1)';
%assert( size(waitbeforelick)==[1 342] )

numberoftrials = length(goggle);
timebin = (max(field12times) - min(field12times))/length(field12times);
Fs = 1000/timebin;
windowrefgoggle = 1300;%window of time past evokedresptime that you are interested in the LFP
binsrefgoggle = floor(windowrefgoggle/timebin);
evokedresptime = 200; % The first 200ms is excluded (visually evoked potential)

fprintf('Doing something 1.\n');
fflush(stdout);
field12refgoggle1 = zeros(numberoftrials,binsrefgoggle);
for i = 1:numberoftrials
    fieldrefgoggle = field12(:,(field12(1,:)>(goggle(i)+evokedresptime)));
    if length(fieldrefgoggle) < binsrefgoggle
        field12refgoggle1(i,:) = [fieldrefgoggle(2,:) zeros(1,(binsrefgoggle-length(fieldrefgoggle)))];
    else
        fieldrefgoggle = fieldrefgoggle(:,1:binsrefgoggle);
        field12refgoggle1(i,:) = fieldrefgoggle(2,:);
    end    
end

groupsize = 1;
numberoftrialsgroup = numberoftrials/groupsize;


fprintf('Doing something 2.\n')
fflush(stdout);
field12refgoggle = zeros(numberoftrialsgroup,binsrefgoggle);
waitbeforelickgroup = zeros(1,numberoftrialsgroup);
for i = 1:(numberoftrialsgroup)
    field12refgoggle(i,:) = mean(field12refgoggle1((groupsize*(i-1)+1):(groupsize*(i-1)+groupsize),:),1);
    waitbeforelickgroup(i) = mean(waitbeforelick(1,(groupsize*(i-1)+1):(groupsize*(i-1)+groupsize)),1);
end
    
NFFT = 2^nextpow2(binsrefgoggle); % Next power of 2 from length of y
phaseforeachtrial = 1000*ones(numberoftrialsgroup,1);
freqforeachtrial = zeros(numberoftrialsgroup,1);
sizeofspikedetails = 40;
spikephaseforeachtrial = 500*ones(numberoftrialsgroup,sizeofspikedetails);
spiketimeforeachtrial = zeros(numberoftrialsgroup,sizeofspikedetails);

for trial = 1:1%numberoftrialsgroup
	fprintf('Beginning trial %d\n',trial)
	fflush(stdout);
    
	% relevantspikes = in window
    relevantspikes = spiketimes((spiketimes>(goggle(trial)+evokedresptime)));
    relevantspikes = relevantspikes((relevantspikes<(goggle(trial) + evokedresptime + windowrefgoggle)));
    relevantspikes = relevantspikes - goggle(trial);
    spikephase = 1000*ones(length(relevantspikes),1); % default to 1000
    spiketimetrial = zeros(length(relevantspikes),1); % what time does the spike occur in trial
    
    findInterestingModes( fieldfortrial, spikesfortrial );
   
	% perform the EMD step of the Hilbert-Huang transform 
    allmode = eemd(field12refgoggle(trial,:),0.4,100);
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
    N = size(allmode,1);

	% generates N linearly spaced points between evokedresptime and evokedresptime+(N-1)*timebin
    c = linspace(evokedresptime,evokedresptime+(N-1)*timebin,N);

	% calculate the phase that the spikes occur
    if ~isempty(interestingmode)b
        for i = 1:length(interestingmode)
            [frequency phase]= ifreq(allmode,timebin,interestingmode(i),0,0);
            for j = groupsize*(trial-1)+1:groupsize*(trial-1)+groupsize
                j
                index = find(diff(c<waitbeforelick(j))<0);
                if ~isempty(index)
                    phaseforeachtrial(j) = phase(index)*360/(2*pi);
                end
                freqforeachtrial(j) = freqosc;
                for ii = 1:length(relevantspikes)
                    idx = find(diff(c<relevantspikes(ii))<0);
                    if ~isempty(idx)
                        spikephase(ii) = phase(idx)*360/(2*pi);
                        spiketimetrial(ii) = c(idx);
                    end
                end
            end            
        end
    end
    if length(spikephase)< sizeofspikedetails
        spikephase = [spikephase;1000*ones(sizeofspikedetails-length(spikephase),1)];
        spiketimetrial = [spiketimetrial;zeros(sizeofspikedetails-length(spiketimetrial),1)];
    elseif length(spikephase) > sizeofspikedetails
        'Size > 20'
    end
    spikephaseforeachtrial(trial,:) = spikephase';
    spiketimeforeachtrial(trial,:) = spiketimetrial';
    plot(relevantspikes,spikephase,'o');set(gca,'YLim',[-180,180]);
end
%save('F:\acads\HuShu lab\data\spikedetails_3_10new.mat','spikephaseforeachtrial','spiketimeforeachtrial');


%load('F:\acads\HuShu lab\data\spikedetails_3_10.mat');
%load('F:\acads\HuShu lab\data\trialdetails_3_10.mat');

% index = find(spikephaseforeachtrial ~= 1000);
% tempphase = spikephaseforeachtrial(index);
% temptime = spiketimeforeachtrial(index);
% % index = find(temptime <350);idx = find(temptime >= 350);
% % tempp1 = tempphase(index);tempt1 = temptime(index);
% % tempphase = tempphase(idx);
% % temptime = temptime(idx);
% % index = find(temptime <500);idx = find(temptime >= 500);
% % tempp2 = tempphase(index);tempt2 = temptime(index);
% % tempphase = tempphase(idx);
% % temptime = temptime(idx);
% % index = find(temptime <650);idx = find(temptime >= 650);
% % tempp3 = tempphase(index);tempt3 = temptime(index);
% % tempphase = tempphase(idx);
% % temptime = temptime(idx);
% % index = find(temptime <850);idx = find(temptime >= 850);
% % tempp4 = tempphase(index);tempt4 = temptime(index);
% % tempphase = tempphase(idx);
% % temptime = temptime(idx);
% % index = find(temptime <1000);
% % tempp5 = tempphase(index);tempt5 = temptime(index);
% % [b,bint] = regress([tempp2;tempp3],[tempt2;tempt3])
% 
% [b,bint] = regress(st1(idx),[ones(length(idx),1) s1(idx)])
% 
% % plot(s1(idx),st1(idx),'o');
% % plot(spiketimeforeachtrial(index),spikephaseforeachtrial(index),'o');hold on
% f = fittype({'1','x'},'coefficients',{'a','b'});
% gfit = fit(s1(idx),st1(idx),f);
% plot(gfit);
% 
% % Dependence for LE and RE
% index = find(mod(goggle,2) == 0);
% spikephaseforlefttrials = spikephaseforeachtrial(index,:);
% spiketimeforlefttrials = spiketimeforeachtrial(index,:);
% index = find(mod(goggle,2) ~= 0);
% spikephaseforrighttrials = spikephaseforeachtrial(index,:);
% spiketimeforrighttrials = spiketimeforeachtrial(index,:);
% index = find(spikephaseforlefttrials ~= 1000);
% [b,bint] = regress(spikephaseforlefttrials(index),spiketimeforlefttrials(index))
% index = find(spikephaseforrighttrials ~= 1000);
% [b,bint] = regress(spikephaseforrighttrials(index),spiketimeforrighttrials(index))

%Phase-trial relation
%spikephaseforeachtrial = spikephaseforeachtrial';
%spiketimeforeachtrial = spiketimeforeachtrial';
%newtime = spiketimeforeachtrial.*(spiketimeforeachtrial>0 & spiketimeforeachtrial<300);
%newphase = spikephaseforeachtrial.*(spiketimeforeachtrial>0 & spiketimeforeachtrial<300);
%newtime = newtime >0;
%newtime1 = zeros(size(newtime));
%for i = 1:size(newtime,1)
%    for j = 1:size(newtime,2)
%        newtime1(i,j) = (i==1).*j*newtime(i,j);
%    end
%end
%index = find(newtime1~=0);
%newtime2 = newtime1(index);newphase2 = newphase(index);
%index = find(newphase2~=0);
%plot(newtime2(index),newphase2(index),'o');ylim([-180 180]);
%[b,bint] = regress(newphase2(index),[ones(length(index),1) newtime2(index)])
