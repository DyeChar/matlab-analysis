function Y = sin_Hz(X_ms, Hz, phaseoffset_rad)
% X_ms is the time points in milliseconds
% Hz is the frequency in seconds ^ -1
% phaseoffset_rad is the phase offset in radians

if nargin < 3
    phaseoffset_rad = 0;
end
Y = sin( X_ms*(2*pi)*Hz/1000 + phaseoffset_rad);