fs = 44100;     % sampling rate
dur = 5;        % duration (seconds)
Ns = dur*fs;    % number of samples

%fmin = 20;      % lowest frequency (Hz)
%Tmax = 1/fmin;  % max period of lowest freq (seconds)
%Mmax = Tmax*fs;   % maximum delay = fs/f0;

% chorus parameters

% brute force, make 4 and sum them together...

nT = [0:Ns-1]/fs; % sampled continuous time t = nT 
M0 = 0.001*fs;    % avg delay, samples (approx. 1 to 10 ms)
A = .9;            % max swing value; between 0 and 1
fRATE = 0.5;        % frequency of flange (LOW)
g = 1;            % depth of flange

Mv = M0*(1 + A*sin(2*pi*fRATE*nT)); 
Mmax = ceil(max(Mv)) + 2;
dline = zeros(Mmax, 1);  % create delay line

%x = [1; zeros(Ns-1, 1)]; % input signal
x = 1 - 2*rand(Ns, 1);
%x = randn(5.0*fs,1); x = x/max(abs(x));
y = zeros(Ns, 1);        % output signal

iptr = 1;                % input pointer
optr = 1;                % output pointer

for n = 1:Ns
    
    % set out pointer relative to in pointer
    M = floor(Mv(n));  % integer part;
    delta = Mv(n) - M; % fractional part;
    
    optr = iptr - M;
    if (optr < 1) 
        optr = optr + Mmax; 
    end
        
    % write to delay line
    dline(iptr) = x(n);
    
    % read from (fractional) delay line (linear interpolation)
    if (optr == 1)
        z = (1 - delta)*dline(optr) + delta*dline(Mmax);
    else
        z = (1 - delta)*dline(optr) + delta*dline(optr - 1);
    end
    
    % form flange output
    y(n) = x(n) + g*z; % x(n) + g*xhat(n - (M + delta))
    
    % increment (in) pointer
    iptr = iptr + 1;
    if (iptr > Mmax) 
        iptr = iptr - Mmax; 
    end
end

% Matlab implementation 
% (not time varying, at least like this...)
%B = [1 zeros(1, M(1)-1) g]; 
%A = 1;
%y2 = filter(B, A, x);