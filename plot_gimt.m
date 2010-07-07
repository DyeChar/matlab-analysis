function [ allerrors pvals ] = plot_gimt( gimt )
% gimt is the parameter returned by findBestParameterValue.  It is defined
% as:
%   gimt{ p, r, d }, where p is the index of the parameter value (for
%       example .1 from 0:.1:1 would have p=2), r is the index of the run
%       (each parameter might be ran multiple times), and d is a number
%       that selects what data.  Look in the findBestParameterValue loop to
%       be sure, but the following numbers selects the corresponding data:
%    1 = groundtruthw (windowed ground truth)
%    2 = interestingmode
%    3 = fieldtimesw (windowed field times)
%    4 = pvals(p) (the pvalue of this data)
%    5 = err (the error)
%    6 = fieldtimes (entire range of the field times)
%    7 = fieldValues

allerrors = zeros(size(gimt,1),size(gimt,2));
pvals = zeros(size(gimt,1),size(gimt,2),1);

for i = 1:size(gimt,1)
    for r = 1:size(gimt,2)
        error = mean( ( gimt{i,r,2} - gimt{i,r,1} ) .^ 2 );
        allerrors(i,r) = error;
        pvals(i,r) = gimt{i,r,4};
    end
end

figure;
boxplot(allerrors(:),pvals(:),'whisker',3);
title('Errors');

worst_run_err_of_paramv = zeros(size(gimt,1),1);
worst_run_of_paramv = zeros(size(gimt,1),1);
for i = 1:size(gimt,1)
    worst_run_err_of_paramv(i) = max(allerrors(i,:));
	worst_run_of_paramv(i) = find( allerrors(i,:) == max(allerrors(i,:)) );
end

sorted = sort(worst_run_err_of_paramv);
% retrieve the jth-best parameters
jmax = 5;
plotncols = 2;
plotnrows = ceil((jmax+1)/plotncols);

figure;
subplot( plotnrows, plotncols, 1);
plot(gimt{1, 1, 6}, gimt{1, 1, 7});
title('Example Input Signal');

for j = 1:jmax
    if j == 1
        prefix = 'Best ';
    else
        prefix = [iptnum2ordinal(j) ' best '];
        prefix = [upper(prefix(1)) prefix(2:end)];
    end
    i = find( worst_run_err_of_paramv == sorted(j) );
    r = worst_run_of_paramv(i);
    subplot( plotnrows, plotncols, j+1);
    plot( gimt{ i, r, 3 }, [ gimt{i,r,1}, gimt{i,r,2} ] );
    title([prefix 'Param=' num2str(gimt{i,r,4}) ' Error=' num2str(worst_run_err_of_paramv(i))]);
end