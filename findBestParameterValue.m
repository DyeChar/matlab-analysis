function [all_errors gimt pvals] = findBestParameterValue( pvals )

all_errors = zeros( size(pvals) );
num_r = 3;% number of iterations
gimt = cell( length(pvals), num_r, 7); % groundtruth, interesting mode, field times, parameter value, error,fieldtimes, fieldValues

NE = 50;

for p = 1:length( pvals )
    mean_error = 0;
    fprintf('processing pval = %g \n',pvals(p));
    for r = 1:num_r
        [ sqd_errors groundtruthw interestingmode fieldtimesw fieldtimes fieldValues] = calcError( rand()*2*pi, pvals(p), NE );
        err = mean( sqd_errors );
        gimt{ p, r, 1 } = groundtruthw;
        gimt{ p, r, 2 } = interestingmode;
        gimt{ p, r, 3 } = fieldtimesw;
        gimt{ p, r, 4 } = pvals(p);
        gimt{ p, r, 5 } = err;
        gimt{ p, r, 6 } = fieldtimes;
        gimt{ p, r, 7 } = fieldValues;
        
        mean_error = (mean_error * (r-1) + err)/r ;
    end
    all_errors(p) = mean_error;
    
%     save('temp1');
end

% save('temp');