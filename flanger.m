% Flanger, by Tamara Smyth
%
% Notes: uses 1) a circular delay line, 
%             2) a sinusoid to control the delay line length
%             3) linear interpolation when reading from the delay
%                line.

clear all;
                                                                               
%input signals
if 0
        fs = 44100;
        x = randn(5.0*fs,1);
        x = x/max(abs(x));
else
        [signal, fs] = audioread('c_and_d.wav');
        x = min(max(signal/max(abs(signal)), -0.2), 0.2);
end;

nsamp = length(x);
                                                                               
%flanger controls
M0 = 0.001*fs;      % average delay 1-10 ms, samples
A = .9;             % excursion or sweep (maximum delay swing)
DEPTH = 1;          % DEPTH of flange (g coefficient in comb filter)
RATE = 1;           % rate of flanger in cycles per second (control param)

%delay trajectory
Mvect = M0 + M0*A*sin(2*pi*RATE*[0:nsamp-1]/fs);

%system constants
Mmax = ceil(max(Mvect));  % maximum delay
dline = zeros(1, Mmax);   % delay line
                                                                               
%initialize loop
y = zeros(size(x)); % buffer for flanger output
inPtr = 1;          % write pointer
outPtr = 1;         % read pointer

for n = 1:nsamp
                                                                               
        %modulate delay
        M = floor(Mvect(n));  % integer part
        delta = Mvect(n) - M; % fractional part
                                                                               
        %write to and read from delay line
        dline(inPtr) = x(n);
                                                                               
        % outPtr chases inPtr
        outPtr = inPtr - M;  
        % wrap outPtr (circular delay line)
	if (outPtr < 1) outPtr = outPtr + Mmax; end;
        
        % read delayed signal using linear interpolation
        if (outPtr==Mmax)
          z = (1-delta)*dline(outPtr) + delta*dline(1);
        else
          z = (1-delta)*dline(outPtr) + delta*dline(outPtr+1);
        end
        
        %form flanged output
        y(n) = x(n) + DEPTH*z;
                                                                               
        % increment inPtr pointer
        inPtr = inPtr + 1;
        % wrap inPtr (circular delay line)
	if (inPtr > Mmax) inPtr = 1; end; 
                                                                               
end;

audiowrite('flanged.wav',y,fs);