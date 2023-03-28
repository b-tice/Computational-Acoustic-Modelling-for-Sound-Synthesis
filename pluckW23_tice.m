% Brian Tice
% Digital Waveguide, Plucked String
% 3/8/23

% Pluck string implementation using circular delay lines

%string = [0 .5 1 .75 .5 .25 0];
string = [linspace(0,1,70), linspace(1,0,30)];


% Low Pass Filter Coefficients
B = 0.98*[.5 .5];
A = 1;
state = 0;

% N = 2L/X = fs/f1 samples

% change this
pu = 50;                                % pickup position, upper rail
%string = [0 1 .5 0];
%pu = 2;                                % pickup position, upper rail

M = length(string)-1;                   % delay line length


upper = fliplr(string(1:end-1)/2);      % upper delay line
lower = string(2:end)/2;                % lower delay line

pl = length(string)-pu+1;               % pickup position, lower rail

N = 44100;                              % sample count
y = zeros(N, 1);                        % output buffer

uptr = 0;                               % upper out pointer at pickup
lptr = 0;                               % lower out pointer at pickup
ptr = 1;                                % beg/end of delay line

for i = 1:N
%for i = 1:4

  % read from end of dlines
  uout = upper(ptr);
  lout = lower(ptr);

  [uout, state] = filter(B, A, uout, state);
  
  % get output from from pickup position
  uptr = ptr - pu;
  if (uptr < 1) uptr = uptr + M; end;
  lptr = ptr - pl;
  if (lptr < 1) lptr = lptr + M; end;

  % acutal physical displacement at pickup
  %upper(uptr)*2
  %lower(lptr)*2;
  y(i) = upper(uptr) + lower(lptr);
  %pause;
  
  % update dlines
  upper(ptr) = -lout;
  lower(ptr) = -uout;

  % add a lowpass filter to the upper output
  
 
  
  % update delay line pointer
  ptr = ptr + 1; 
  if (ptr > M) ptr = 1; end;

end


    
    