fs = 44100;     % sampling rate
dur = 1;        % duration (seconds)
Ns = dur*fs;    % number of samples

fmin = 20;      % lowest frequency (Hz)
Tmax = 1/fmin;  % max period of lowest freq (seconds)
Mmax = Tmax*fs;   % maximum delay = fs/f0;
                  
%Mmax = 10;

f0 = 220;
M = round(fs/f0);
%M = A0 + A*sin(...)
g = .8;


B = [.5 .5];
A = 1;

state = 0;

dline = zeros(Mmax, 1);
x = [1; zeros(Ns-1, 1)]; % input signal
y = zeros(Ns, 1);        % output signal
iptr = 1;                % input pointer
optr = 1;                % output pointer

for n = 1:Ns
    
    % set out pointer relative to in pointer
    optr = iptr - M;
    if (optr < 1) 
        optr = optr + Mmax; 
    end
    
    % write to delay line
    dline(iptr) = y(n);
    
    z = dline(optr);
    [z, state] = filter(B,A,z,state);

    y(n) = x(n) + g*z;

    % read from delay line
    %y(n) = x(n) + g*dline(optr); % x(n) + x(n-M)
    
    % increment (in) pointer
    iptr = iptr + 1;
    if (iptr > Mmax) 
        iptr = iptr - Mmax; 
    end
end

% Matlab implementation 
% (not time varying, at least like this...)
B = 1; 
A = [1 zeros(1,M-1) -g];
y2 = filter(B, A, x);

% plot(abs(fft(y2)))
stem(y);
%freqz(B,A);     % plot the magnitude in dB
                % also the phase response