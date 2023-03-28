% Brian Tice
% MUSIC 267, Assignment 3
% 2/23/23

% extended Karplus-Strong with tuning (allpass fractional delay) and note 
% duration (decay rate shortening and stretching).

fs = 44100;     % sampling rate
dur = 4.0;        % duration (seconds)
Ns = dur*fs;    % number of samples

fmin = 20;      % lowest frequency (Hz)
Tmax = 1/fmin;  % max period of lowest freq (seconds)
Mmax = Tmax*fs;   % maximum delay = fs/f0;
                  
f0 = 440;
%f0 = 80;
M = round(fs/f0);

% set note duration
T60 = 4; % duration, seconds (make sure greater than dur)

SCALARLOSS = 0;

if SCALARLOSS
    g = 0.001^(M/(fs*T60));
else
    B = [.5 .5];
    A = 1;
    state = 0;
end

dline = zeros(Mmax, 1);

%x = [1; zeros(Ns-1, 1)]; % input signal

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
    if SCALARLOSS
        z = g*dline(optr); % z = gy(n-M) 
    else
        z = dline(optr); 
        [z, state] = filter(B, A, z, state);
    end

    y(n) = x(n) + z;
    
    % write to delay line
    dline(iptr) = y(n);
    
    
    % increment (in) pointer
    iptr = iptr + 1;
    if (iptr > Mmax) 
        iptr = iptr - Mmax; 
    end
end

% Matlab implementation 
% (not time varying, at least like this...)
B = 1;
A = [1 zeros(1, M-1) -g];
y2 = filter(B, A, x);