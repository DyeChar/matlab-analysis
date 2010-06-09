function [f,powerY] = fouriercorrected(x,Fs,windowname)
% Function written by Vijay
%
% Input : x -> Signal to be Fourier transformed. Has to be a row vector
%         Fs -> Sampling rate
%         windowname -> name the window to be applied to the signal
% Output : f -> frequency vector
%          powerY -> power at the corresponding frequency
% 
% The signal is first corrected for baseline drift and then a window is applied to correct for a finite length of signal.


if x(end) ~= x(1)
    baselinedrift = x(1):((x(end)-x(1))/(length(x)-1)):x(end);
elseif x(end) == x(1)
    baselinedrift = zeros(1,length(x));
end
baselinecorrectedsignal = x - baselinedrift;
if windowname == 'hamming'
    window = hamming(length(x));
end
windowedbaselinecorrectedsignal = window'.*baselinecorrectedsignal;
NFFT = 2^nextpow2( length(x) );
Y = fft(windowedbaselinecorrectedsignal,NFFT)/length(x);
f = Fs/2*linspace(0,1,NFFT/2);
powerY = 2*abs(Y(1:NFFT/2));

