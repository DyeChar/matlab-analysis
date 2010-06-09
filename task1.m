function [ sqd_errors groundtruthw interestingmode fieldtimesw] = task1( phaseoffset_rad, Nstd, NE )
% phaseoffset_rad = [0,2*pi) = ex. rand()*2*pi
% Nstd = 0.4
% NE = 200
% score = 1 - mean squared error

Fs = 623.5232;
backwindow = 500;
fwdwindow = 500;
%window = 2500;
trial = 1;
% field(:,1) time in ms, increments about 1.58 every time
% field(:,2) ranges from -.5 to .5, normalized LFP?

fieldtimes = 0:1.58:10000; % create timestamps where LFP was recorded
%timebin = (max(fieldtimes) - min(fieldtimes))/length(fieldtimes);%Time bin of sampling


startevent_ms = 2000;
endevent_ms = startevent_ms + 2500;

event_mask = ( fieldtimes >= startevent_ms ) & ( fieldtimes <= endevent_ms );
ground_truth = sin_Hz(fieldtimes, 7, phaseoffset_rad).*event_mask;

fieldSin = ground_truth + sin_Hz(fieldtimes, 20, rand()*2*pi);

fieldValues = fieldSin;
Z = max(fieldValues)-min(fieldValues);

fieldValues = fieldValues/Z;
groundtruth = ground_truth/Z;

% Add noise
if true
    fieldValues = .2 * ( rand( size( fieldValues ) ) - .5 ) + fieldValues;
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
        
if length(indx_interest) > 1
    fprintf('NOTE: Multiple interesting modes for trial %d \n Lower frequency mode considered \n',trial);
end

% figure;
% for i = 1:length(indx_interest)
%     subplot(length(indx_interest),1,i); plot(allmode(:,indx_interest(i)));
% end
interestingmode = allmode(:,indx_interest(1));
sqd_errors = ( interestingmode - groundtruthw ) .^ 2;
