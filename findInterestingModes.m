function [allmode,interestingmode] ...
            = findInterestingModes( field, startevent_ms, endevent_ms, Fs, backwindow, fwdwindow, Nstd, NE )
  
fieldfortrial = field(:,field(1,:)>(startevent_ms-backwindow));
fieldfortrial = fieldfortrial(:,fieldfortrial(1,:)< (endevent_ms+fwdwindow));

allmode = eemd(fieldfortrial(2,:), Nstd, NE);

%  ******   Find the intrinsic mode functions of interest   ******

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
% for i = 1:3
%     figure;
%     for j = 1:4
%         subplot(4,1,j);plot(allmode(:,4*(i-1)+j));
%     end        
% end
%     subplot(2,1,1);plot(allmode(:,1));
%     subplot(2,1,2);plot(allmode(:,interestingmode(end)));

