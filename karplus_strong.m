% Brian Tice
% Final Project Music 267

% Extended Karplus-Strong with Pick Position 
% https://ccrma.stanford.edu/~jos/pasp/Extended_Karplus_Strong_Algorithm.html

% a5.m MUS 267, in class, Feb 27, 2023
% Karplus strong algorithm incorporating tuning (allpass
% interpolation) and decay shortening

% Extend the algorithm to include pick position.
% One way to simulate this is to filter the noise burst input
% with a comb filter..

fs = 44100;                 % sampling rate
dur = 10;                   % duration (seconds)
Ns = dur*fs;                % number of samples

fmin = 20;                  % lowest frequency (Hz)
Tmax = 1/fmin;              % max period of lowest freq (seconds)
Mmax = Tmax*fs;             % maximum delay = fs/f0;

% playing parameters

%f0 = 82.41;                % open low e string on guitar
%f0 = 146.83;               % a on guitar
f0 = 329.63;                % high e string on guitar

%f0 = 80; 
%M = round(fs/f0);

% set note duration
T60 = 1;                    % duration, seconds (less than dur)
tau = -T60/log(0.001);
rho =  exp( -1/(f0*tau)/abs(cos(pi*f0/fs)) );

% set lowpass filter (Ha)
B = rho*[.5 .5];
A = 1;
state = 0;
Pa = 0.5;                   % phase delay, samples

% pseudo code if Pa is function of frequency
% Ha = freqz(B, A, 'whole, length(faxis)); % frequency response
% Paf = angle(Ha)/wT;                      % phase response divided
                                           % by omegaT is phase delay
% Pa = Paf(fi)                             % index phase delay at f0                                                         

% set allpas filter (Hc)
P1 = fs/f0;                 % period, samples
M = floor(P1 - Pa - eps);   % delay line length
Pc = P1 - M - Pa;
C = (1 - Pc)/(1 + Pc);
Bc = [C 1];
Ac = [1 C];
stateC = 0;


dline = zeros(Mmax, 1);  % circular delay line buffer

% input signal
%x = [1; zeros(Ns-1, 1)]; 
x_start = [1 - 2*rand(M, 1); zeros(Ns-M, 1)];


% ***
% here we need to filter the noise burst with a comb filter
% compare to Matlab's filter

beta = 0.9;

%B_pluck = [1; zeros((M-1), 1); -0.9];
B_pluck = [1; zeros(floor((M*beta+0.5)),1); -1];
A_pluck = 1;
x = filter(B_pluck, A_pluck, x_start);  
audiowrite('noise_burst.wav',x_start,fs);

%plot(abs(fft(x)));

% ***

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