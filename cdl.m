fs = 44100;                 % sampling frequency
dur = 1;                    % length in seconds
nsamp = fs*dur;             % total number of samples

fmin = 20;                  % min frequency, Hz
Mmax = floor(fs/fmin);      % max delay, samples
dline = zeros(Mmax, 1);     % delay line buffer

x = [1; zeros(nsamp-1, 1)]; % input vector
y = zeros(nsamp, 1);        % output vector
M = 3;                      % delay, samples
iptr = 1;                   % in/write pointer
optr = 1;                   % out/read pointer

for n=1:nsamp

  % set out ptr in relation to in ptr
  optr = iptr-M;
  if (optr < 1) optr = optr + Mmax; end;
  
  % write to delay line
  dline(iptr) = x(n);
  
  % read from delay line
  y(n) = dline(optr);
  
  % increment pointer
  iptr = iptr+1;
  if (iptr > Mmax) iptr = iptr - Mmax; end;
  
end

  
  
