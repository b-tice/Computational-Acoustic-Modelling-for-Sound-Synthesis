fs = 44100;
dur = 1;
nsamp = fs*dur;

fmin = 20;                  % min frequency, Hz
Mmax = floor(fs/fmin);      % max delay, samples
dline = zeros(Mmax, 1);     % delay line buffer

f0 = 1000;                  % freq. of first notch, Hz 
M = floor(fs/f0/2);         % delay, samples
g = .9;                     % depth coefficient, 0-1

x = [1; zeros(nsamp-1, 1)]; % input vector
y = zeros(nsamp, 1);        % output vector
iptr = 1;                   % in/write pointer
optr = 1;                   % out/read pointer

for n=1:nsamp
  % set out ptr in relation to in ptr
  optr = iptr-M;
  if (optr < 1) optr = optr + Mmax; end;
  
  % write to delay line
  dline(iptr) = x(n);
  
  % read from delay line and multiply by depth coefficient
  y(n) = x(n) + g*dline(optr);
  
  % increment pointer
  iptr = iptr+1;
  if (iptr > Mmax) iptr = iptr - Mmax; end;
end

% compare to Matlab's filter
B = [1; zeros(M-1, 1); g];
A = 1;
y2 = filter(B, A, x);  

plot(abs(fft(y2)));
%plot(abs(fft(y)))