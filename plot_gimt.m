function plot_gimt( gimt )
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
%    4 = pvals(p) (the pvalue of this data
%    5 = err (the error)
%    6 = fieldtimes (entire range of the field times)
%    7 = fieldValues

besti = 1;
worsti = 1;
bestr = 1;
worstr = 1;
allerrors = zeros(size(gimt,1)*size(gimt,2),1);
pvals = zeros(size(gimt,1)*size(gimt,2),1);

besterr = 1;
worsterr = 0;
for i = 1:size(gimt,1)
    for r = 1:size(gimt,2)
        error = mean( ( gimt{i,r,2} - gimt{i,r,1} ) .^ 2 );
        allerrors((i-1)*size(gimt,2)+r) = error;
        pvals((i-1)*size(gimt,2)+r) = gimt{i,r,4};
        if error < besterr
            besterr = error;
            besti = i;
            bestr = r;
        elseif error > worsterr
            worsterr = error;
            worsti = i;
            worstr = r;
        end
    end
end

figure;
range_i = [besti worsti];
range_r = [bestr worstr];
subplot( length(range)+2, 1, 1);
plot(gimt{range(1), 1, 6}, gimt{range(1), 1, 7});
title('Input Signal');

subplot( length(range)+2 , 1, 2);
%plot([gimt{ :, runnum, 4 }],allerrors);
boxplot(allerrors,pvals);
title('Errors');

for i = 1:length(range)
     subplot( length(range_i)+2 , 1, i+2);
     plot( gimt{ range_i(i), range_r(i), 3 }, [ gimt{range_i(i),range_r(i),1}, gimt{range_i(i),range_r(i),2} ] );
     
    error = mean( ( gimt{range_i(i),range_r(i),2} - gimt{range_i(i),range_r(i),1} ) .^ 2 );
    title(['Param=' num2str(gimt{range_i(i),range_r(i),4}) ' Error=' num2str(error, 4)]);
end