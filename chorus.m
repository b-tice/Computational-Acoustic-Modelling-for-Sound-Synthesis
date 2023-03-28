% Chorus, by Brian Tice, adapted from Flanger by Tamara Smyth

clear all;
                                                                               
%input signals
if 0                % ignore this for now to test on wave file
        fs = 44100;
        x = randn(5.0*fs,1);
        x = x/max(abs(x));
else
   
        % read in wavefile at 44100
        [signal, fs] = audioread('c_and_d.wav');    % live drum .wav

        % normalize (?)
        x = min(max(signal/max(abs(signal)), -0.2), 0.2);
end;

nsamp = length(x);
                                                                               
%chorus controls:

% LFO 0
M0 = 0.001*fs;      % average delay 10-50 ms, samples
A = .9;             % excursion or sweep (maximum delay swing)
DEPTH = 1;          % DEPTH of flange (g coefficient in comb filter)
RATE = 1;           % rate of flanger in cycles per second (control param)

% LFO1
M1 = 0.020*fs;
A1 = 0.8;
DEPTH1 = .9;
RATE1 = 2;

% Random 1
DEPTH2 = .4;

% Random 2
DEPTH3 = .5;

% delay trajectory 0
Mvect = M0 + M0*A*sin(2*pi*RATE*[0:nsamp-1]/fs);

% delay trajectory 1
Mvect2 = M1 + M1*A1*sin(2*pi*RATE1*[0:nsamp-1]/fs);

% Random1
Mvect3 = 2*M0*rand*[0:nsamp-1]/fs;

% Random2
Mvect4 = 2*M1*rand*[0:nsamp-1]/fs;

%system constants
Mmax =  ceil(max(Mvect));  % maximum delay
Mmax2 = 100*ceil(max(Mvect2));  % make it big enough
Mmax3 = ceil(max(Mvect3));
Mmax4 = ceil(max(Mvect4));

dline = zeros(1, Mmax2);   % delay line
                                                                               
%initialize loop
y = zeros(size(x)); % buffer for flanger output
inPtr = 1;          % write pointer
outPtr = 1;         % read pointer
outPtr2 = 1;
outPtr3 = 1;
outPtr4 = 1;

for n = 1:nsamp
                                                                               
        %modulate delay
        M = floor(Mvect(n));  % integer part
        delta = Mvect(n) - M; % fractional part

        M2 = abs(floor(Mvect2(n)));      % integer part
        delta1 = Mvect2(n) - M2;         % fractional part

        %modulate random vectors
        M3 = floor(Mvect3(n));
        delta2 = Mvect3(n) - M3;

        M4 = floor(Mvect4(n));
        delta3 = Mvect4(n) - M4;


                                                                               
        %write to and read from delay line
        dline(inPtr) = x(n);
                                                                               
        % outPtr chases inPtr
        outPtr = inPtr - M;  
        outPtr2 = abs(inPtr - M2);
        outPtr3 = abs(inPtr - M3);
        outPtr4 = abs(inPtr - M4);


        % wrap outPtr (circular delay line)
	    if (outPtr < 1) outPtr = outPtr + Mmax; end;

        % wrap outPtr2 (circular delay line)
	    if (outPtr2 < 1) outPtr2 = outPtr2 + Mmax; end;

        % wrap outPtr3 (circular delay line)
	    if (outPtr3 < 1) outPtr3 = outPtr3 + Mmax; end;

        % wrap outPtr4 (circular delay line)
	    if (outPtr4 < 1) outPtr4 = outPtr4 + Mmax; end;
        
        % read delayed signal using linear interpolation
        if (outPtr==Mmax)
          z = (1-delta)*dline(outPtr) + delta*dline(1);
        else
          z = (1-delta)*dline(outPtr) + delta*dline(outPtr+1);
        end

        % read delayed signal using linear interpolation
        if (outPtr2==Mmax2)
          z1 = (1-delta1)*dline(outPtr2) + delta1*dline(1);
        else
          z1 = (1-delta1)*dline(outPtr2) + delta1*dline(outPtr2+1);
        end

        % read delayed signal using linear interpolation
        if (outPtr3==Mmax3)
          z2 = (1-delta2)*dline(outPtr3) + delta2*dline(1);
        else
          z2 = (1-delta2)*dline(outPtr3) + delta2*dline(outPtr3+1);
        end

        % read delayed signal using linear interpolation
        if (outPtr4==Mmax4)
          z3 = (1-delta3)*dline(outPtr4) + delta3*dline(1);
        else
          z3 = (1-delta3)*dline(outPtr4) + delta3*dline(outPtr4+1);
        end
        
        %form flanged output
        y(n) = x(n) + DEPTH*z + DEPTH1*z1 + DEPTH2*z2 + DEPTH3*z3;
                                                                               
        % increment inPtr pointer
        inPtr = inPtr + 1;
        % wrap inPtr (circular delay line)
	if (inPtr > Mmax) inPtr = 1; end; 
                                                                               
end;

audiowrite('chorus_effect.wav',y,fs);