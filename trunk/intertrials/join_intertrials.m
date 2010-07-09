function joined = join_intertrials( intertrials )
% intertrial should be a cell array (N,>=2), where (i,1) would be the times
%   and (i,2) would be the values.

joined_times = intertrials{1,1}(1);
joined_vals = intertrials{1,2}(1);

for i = 1:size(intertrials,1)
    time_diff = joined_times(end)-intertrials{i,1}(1);
    val_diff = 0; %joined_vals(end)-intertrials{i,2}(1);
    
    if any( abs(intertrials{i,2}) >= .5 )
        continue
    end
    assert( all( abs(intertrials{i,2}) <= .5 ) );
    
    joined_times =[ joined_times,intertrials{i,1}(2:end)+time_diff ];
    joined_vals = [ joined_vals, intertrials{i,2}(2:end)+val_diff ];
end

joined = [joined_times; joined_vals];