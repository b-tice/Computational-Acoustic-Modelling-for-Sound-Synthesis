% a5.m MUS 267, in class, Feb 27, 2023
% Karplus strong algorithm incorporating tuning (allpass
% interpolation) and decay shortening

fs = 44100;     % sampling rate
dur = 10;       % duration (seconds)
Ns = dur*fs;    % number of samples

fmin = 20;      % lowest frequency (Hz)
Tmax = 1/fmin;  % max period of lowest freq (seconds)
Mmax = Tmax*fs;   % maximum delay = fs/f0;

% playing parameters
f0 = 200;
%f0 = 80; 
%M = round(fs/f0);

% set note duration
T60 = 1;        % duration, seconds (less than dur)
tau = -T60/log(0.001);
rho =  exp( -1/(f0*tau)/abs(cos(pi*f0/fs)) );

% set lowpass filter (Ha)
B = rho*[.5 .5];
A = 1;
state = 0;
Pa = 0.5;    % phase delay, samples
% pseudo code if Pa is function of frequency
% Ha = freqz(B, A, 'whole, length(faxis)); % frequency response
% Paf = angle(Ha)/wT;                      % phase response divided
                                           % by omegaT is phase delay
% Pa = Paf(fi)                             % index phase delay at f0                                                         

% set allpas filter (Hc)
P1 = fs/f0;               % period, samples
M = floor(P1 - Pa - eps); % delay line length
Pc = P1 - M - Pa;
C = (1 - Pc)/(1 + Pc);
Bc = [C 1];
Ac = [1 C];
stateC = 0;


dline = zeros(Mmax, 1);  % circular delay line buffer

% input signal
%x = [1; zeros(Ns-1, 1)]; 
x = [1 - 2*rand(M, 1); zeros(Ns-M, 1)];
y = zeros(Ns, 1);        % output signal

iptr = 1;                % input pointer
optr = 1;                % output pointer

for n = 1:Ns
    
    % set out pointer relative to in pointer
    optr = iptr - M;
    if (optr < 1) 
        optr = optr + Mmax; 
    end

    % read from delay line
    z = dline(optr); 
    [z, state] = filter(B, A, z, state);    % lowpass 
    [z, stateC] = filter(Bc, Ac, z, stateC); % allpass 

    y(n) = x(n) + z;
    
    % write to delay line
    dline(iptr) = y(n);
    
    
    % increment (in) pointer
    iptr = iptr + 1;
    if (iptr > Mmax) 
        iptr = iptr - Mmax; 
    end
end

Nfft = 2^nextpow2(length(y));
Y = fft(y, Nfft);
faxis = fs*[0:Nfft-1]'/Nfft;
plot(faxis, abs(Y)); set(gca, 'xlim', [0 5000]);