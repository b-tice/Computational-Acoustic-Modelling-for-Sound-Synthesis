fs = 44100;         % sampling rate
dur = 5;            % duration (seconds)
Ns = dur*fs;        % number of samples

%fmin = 20;          % lowest frequency (Hz)
%Tmax = 1/fmin;      % max period of lowest freq (seconds)
%Mmax = Tmax*fs;     % maximum delay = fs/f0;



nT = [0:Ns-1]/fs;       % continuous sampled time t = nT

M0 = 0.005 * fs;        % average delay (1 to 10 ms) in units of samples

A = 0.9;                  % max swing value, between 0 and 1;

fRATE = 5;              % frequency of flange ( want it to be LOW)

g = 1;                  % depth of our flange

Mv = floor(M0*(1 + A*sin(2*pi*fRATE*nT))); 

Mmax = ceil(max(Mv));

dline = zeros(Mmax, 1);
%x = [1; zeros(Ns-1, 1)];           % input signal
x = 1 - 2*rand(Ns,1);               % make some white noise
y = zeros(Ns, 1);                   % output signal
iptr = 1;                           % input pointer
optr = 1;                           % output pointer

for n = 1:Ns
    
    % set out pointer relative to in pointer

    M = floor(Mv(n));   % integer part
    delta = Mv(n) - M;    % fractional  

    optr = iptr - Mv(n);
    if (optr < 1) 
        optr = optr + Mmax; 
    end
    
    if(optr > Mmax)
        optr = optr - Mmax;
    end

    % write to delay line
    dline(iptr) = x(n);
    
    % read from (fractional) delay line (linear interpolation)
    if(optr == 1)
        z = (1 - delta)*dline(optr) + delta*dline(Mmax);
    else
        z = (1 - delta)*dline(optr) + delta*dline(optr - 1);
    end

    % form the flange output
    y(n) = x(n) + g*z; % x(n) + x(n-M)
    
    % increment (in) pointer
    iptr = iptr + 1;
    if (iptr > Mmax) 
        iptr = iptr - Mmax; 
    end
end

% Matlab implementation 
% (not time varying, at least like this...)
% B = [1 zeros(1, M(1)-1) g]; 
% A = 1;
% y2 = filter(B, A, x);

% plot(abs(fft(y)))
 plot(x);