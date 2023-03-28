% Brian Tice
% MUSIC 267, Assignment 3
% 2/23/23

% Implement the following:
% extended Karplus-Strong with tuning (allpass fractional delay) and note 
% duration (decay rate shortening and stretching).

% Part 1: All-Pass filter for fractional delay

% Motivation: use fractional delay because an integer delayline length
% limits the resolution of possible sounding frequencies. Especially at
% higher frequencies.

% Calculations:

% fundamental frequency f1 has corresponding period: P1 = fs/f1;
% Delay line length N becomes: N = Floor(P1 - Pa(f1) - epsilon)
%           epsilon is much smaller than 1, used to shift Pc(f1) 
% The fractional phase delay, in samples, for the allpass interpolator
% becomes: Pc(f1) = P1 - N - Pa(f1)

% H(z) = (C + z^-1) / (1 + C*z^-1)
%
% Where C ~ (1 - ep) / (1 + ep)

% try C = 0.65, 0.25

% Part 2: Note Duration, Decay rate Shortening and stretching

% tau ~ T60/6.91
% abs(rho) = e^(-1/(f1*tau)) / (abs(cos(pi*f1*T)
%
% Then multiply rho in the feedback loop: y(n) = x(n)+rho*[y terms].
%
% for T60 of 4.0 @ 220 Hz: 
% tau = 4.0/6.91 = 0.5789
%
% rho = e^(-1/(220*0.5789)) / abs(cos(pi*f1*T)
%     = 0.992 / abs(0.999999962)
%     = 0.992




fs = 44100;         % sampling rate
dur = 4.0;          % duration (seconds)
Ns = dur*fs;        % number of samples

fmin = 20;          % lowest frequency (Hz)
Tmax = 1/fmin;      % max period of lowest freq (seconds)
Mmax = Tmax*fs;     % maximum delay = fs/f0;
                  
f0 = 110;
M = round(fs/f0);

% set note duration
T60 = 4.0; % duration, seconds (make sure greater than dur)

% set rho for decay rate shortening:

tau = T60/6.91;
rho = exp((-1/(f0*tau)) / (abs(cos(pi*f0*(1/fs)))));

SCALARLOSS = 0;

if SCALARLOSS
    g = 0.001^(M/(fs*T60));
else

    % low pass
    B = [.5 .5];    % feedforward coefficients
    A = 1;          % feedback coefficients
    state = 0;

    % all pass
    B_allpass = [0.25, 1.0];
    A_allpass = [1.0, 0.25];
    state_allpass = 0;

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
        
        % low pass
        [z, state] = filter(B, A, z, state);

        % all pass
        [z, state_allpass] = filter(B_allpass, A_allpass, z, state_allpass);
    end

    y(n) = x(n) + rho*z;
    %y(n) = x(n) + z;   % without decay rate shortening
    
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