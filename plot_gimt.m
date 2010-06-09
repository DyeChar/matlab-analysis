function plot_gimt( gimt, index )
% 
% num_r = size( gimt, 2 );
% 
% 
% for r = 1:num_r
%     subplot(num_r,1,r);
%     plot( gimt{ index, 1, 3 }, [ gimt{index,1,1}, gimt{index,1,2} ] )
% end    

besti = 1;
worsti = 1;
allerrors = zeros(size(gimt,1),1);
allerrors(1) = mean( ( gimt{1,1,2} - gimt{1,1,1} ) .^ 2 );
besterr = allerrors(1);
worsterr = allerrors(1);
for i = 2:size(gimt,1)
    error = mean( ( gimt{i,1,2} - gimt{i,1,1} ) .^ 2 );
    allerrors(i) = error;
    if error < besterr 
        besterr = error;
        besti = i;
    elseif error > worsterr
        worsterr = error;
        worsti = i;
    end
end

figure;
range = [besti worsti];
subplot( length(range)+1 , 1, 1);
plot([gimt{ :, 1, 4 }],allerrors);

for i = 1:length(range)
     subplot( length(range)+1 , 1, i+1);
     plot( gimt{ range(i), 1, 3 }, [ gimt{range(i),1,1}, gimt{range(i),1,2} ] );
     
    error = mean( ( gimt{range(i),1,2} - gimt{range(i),1,1} ) .^ 2 );
    title(['Param=' num2str(gimt{range(i),1,4}) ' Error=' num2str(error, 4)]);
end