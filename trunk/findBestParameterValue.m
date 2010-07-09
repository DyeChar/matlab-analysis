function [all_errors gimt Nstds] = findBestParameterValue( Nstds, NEs, trial_durations )

all_errors = zeros( size(Nstds) );
num_r = 10;% number of iterations
gimt = cell( length(Nstds), num_r, 7); % groundtruth, interesting mode, field times, parameter value, error,fieldtimes, fieldValues

%NE = 50;

iter = 1;
for Nstd = Nstds
    for NE = NEs
        for trial_duration = trial_durations
            mean_error = 0;
            fprintf('processing Nstd = %g \n',Nstd);
            for r = 1:num_r
                [ sqd_errors groundtruthw interestingmode fieldtimesw ...
                    fieldtimes fieldValues groupName] = calcError( rand()*2*pi, Nstd, NE, trial_duration );
                err = mean( sqd_errors );
                gimt{ iter, r, 1 } = groundtruthw;
                gimt{ iter, r, 2 } = interestingmode;
                gimt{ iter, r, 3 } = fieldtimesw;
                gimt{ iter, r, 4 } = Nstd;
                gimt{ iter, r, 5 } = err;
                gimt{ iter, r, 6 } = fieldtimes;
                gimt{ iter, r, 7 } = fieldValues;
                gimt{ iter, r, 8 } = groupName;

                mean_error = (mean_error * (r-1) + err)/r ;
            end
            all_errors( iter ) = mean_error;
            iter=iter+1;
        end
    end
    
%     save('temp1');
end

% save('temp');