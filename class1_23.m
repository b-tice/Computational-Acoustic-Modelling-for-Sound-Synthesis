% comb filter

x = [1; zeros(1023,1)];

M = 6;
g = 0.8;
y = filter([1 zeros(1,M-1) g],1,x)

plot(abs(fft(y)))


% phase
%plot(angle(fft(y)))

% use freqz, just requires the coefficients
% returns magnitude and phase

p = freqz([1 zeros(1,M-1) 1],1,x)

plot(abs(p))

