
% Brian Tice
% Flanger 
% 1/29/2023

fs = 44100;     % sampling rate
dur = 1;        % duration (seconds)
Ns = dur*fs;    % number of samples

fmin = 20;      % lowest frequency (Hz)
Tmax = 1/fmin;  % max period of lowest freq (seconds)
Mmax = Tmax*fs;   % maximum delay = fs/f0;
                  
%Mmax = 10;
M = 3;          % actual delay
M = 100;
M = 100*ones(Ns, 1);

% Time-Varying Delay can be constructed using an LFO
nT = 0:1/fs:dur-1/fs;

nT = nT';

M = 3 + sin(2*pi*nT);

%M = M';

%M = A0 + A*sin(...)
g = .8

dline = zeros(Mmax, 1);
x = [1; zeros(Ns-1, 1)]; % input signal
y = zeros(Ns, 1);        % output signal
iptr = 1;                % input pointer
optr = 1;                % output pointer

for n = 1:Ns
    
    % set out pointer relative to in pointer
    optr = iptr - M(n);
    if (optr == 1) 
        %optr = optr + Mmax; 
        optr = (1 - delta)*dline(optr) + delta*dline(Mmax);
    else
        optr = (1 - delta)*dline(optr) + delta*dline(optr - 1);
    end
    
    % write to delay line
    dline(iptr) = x(n);
    
    % read from delay line
    y(n) = x(n) + g*round(dline(optr)); % x(n) + x(n-M)
    
    % increment (in) pointer
    iptr = iptr + 1;
    if (iptr > Mmax) 
        iptr = iptr - Mmax; 
    end
end

% Matlab implementation 
% (not time varying, at least like this...)
B = [1 zeros(1, M(1)-1) g]; 
A = 1;
y2 = filter(B, A, x);

plot(abs(fft(y)))