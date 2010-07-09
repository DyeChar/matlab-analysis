function intertrials = intertrialActivity(fieldtimes, fieldValues, starttimes, licktimes, startborder, lickborder)
% Example call:
%   intertrials = intertrialActivity( fieldtimes, fieldValues, ...
%           [LE_SM,LE_SP,RE_SM,RE_SP], licktimes, 500, 500 )

% align the start times and licktimes so [licktimes(i) starttimes(i)]
%   defines an intertrial period
starttimes = sort(starttimes(2:end));
licktimes =  sort(licktimes(1:end-1));

intertrials = cell(0,3);

for i = 1:length(starttimes)
    start = licktimes(i) + lickborder;
    finish = starttimes(i) - startborder;
    if start < finish
        j = size(intertrials,1)+1;
        intertrials{j,1} = fieldtimes( (fieldtimes > start) & (fieldtimes < finish));
        intertrials{j,2} = fieldValues( (fieldtimes > start) & (fieldtimes < finish));
        intertrials{j,3} = max(intertrials{j,1}) - min(intertrials{j,1});
    end
end
