function plot_trial_lfp( fieldtimes, fieldValues, starttimes, licktimes, trial_num )

window = 500;

starttimes = sort( starttimes );
licktimes = sort( licktimes );
start = starttimes(trial_num) - window;
finish = licktimes(trial_num) + window;


times = fieldtimes( (fieldtimes > start) & (fieldtimes < finish));
values = fieldValues( (fieldtimes > start) & (fieldtimes < finish));

plot( times - starttimes(trial_num), values );