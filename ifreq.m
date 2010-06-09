function [d, th] = ifreq(imf,Ts,mode,freqflag,angleflag)
% Function written by Vijay
% 
% This calculates the instantaneous frequency of an IMF 
% Input : imf -> Matrix of IMFs with each IMF being a single column
%         Ts -> Sampling time
%         mode -> the mode for which you need the instantaneous frequency. Use 0 for getting all modes
%         freqflag -> If flag = 1, the function plots the time-frequency
%           response of the IMFs
%         angleflag -> If flag = 1, the function plots the time-angle
%         (phase) response of the IMFs
%         
% Output : th -> theta of the IMF, current angle
%          d -> instantaneous frequency of the IMF
%          
%    

N = size(imf,1);
c = linspace(0,(N-2)*Ts,N-1);

if mode == 0
    th = zeros(size(imf,1),size(imf,2));
    d = zeros(size(imf,1)-1,size(imf,2));
    for k = 1:size(imf,2)
       th(:,k) = angle(hilbert(imf(:,k)));
       d(:,k) = diff(th(:,k))/Ts/(2*pi);
       if freqflag == 1
           figure, plot(c,d(:,k),'k.','MarkerSize',3);
           set(gca,'FontSize',8,'XLim',[0 c(end)],'YLim',[0 1/2/Ts]); xlabel('Time'), ylabel('Frequency');
       end
       if angleflag == 1
           figure, plot(c,th(1:end-1,k)*360/(2*pi),'-ok');
           set(gca,'FontSize',8,'XLim',[0 c(end)],'YLim',[-180 180]); xlabel('Time'), ylabel('Phase in degrees');
       end
    end
elseif mode > 0
    th = angle(hilbert(imf(:,mode)));
    d = diff(th)/(2*pi*Ts);
    if freqflag == 1
        figure, plot(c,d,'k.','MarkerSize',3);
        set(gca,'FontSize',8,'XLim',[0 c(end)],'YLim',[0 1/2/Ts]); xlabel('Time'), ylabel('Frequency');
    end
    if angleflag == 1
        figure, plot(c,th(1:end-1)*360/(2*pi),'-ok');
        set(gca,'FontSize',8,'XLim',[0 c(end)],'YLim',[-180 180]); xlabel('Time'), ylabel('Phase in degrees');
    end
end

end