function [f,powerY,Y] = fouriercorrected(x,Fs,windowname)
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
    baselinedrift = linspace(x(1),x(end),length(x));
elseif x(end) == x(1)
    baselinedrift = x(1)*ones(size(x));
end
baselinecorrectedsignal = x - baselinedrift;
if windowname == 'hamming'
    window = hamming(length(x),'periodic');
end
windowedbaselinecorrectedsignal = window'.*baselinecorrectedsignal;
Y = fft(windowedbaselinecorrectedsignal);
f = Fs/2*linspace(0,1,floor(length(x)/2));
powerY = abs(Y(1:1:floor(length(x)/2))).^2;
