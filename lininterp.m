function y = lininterp(w, x);
% LININTERP Linear interpolation.
% Y = LININTERP(W, X) where Y is the output,
% X is the input indeces, not necessarily
% integers, and W is the transfer function
% indexed by X.
n = floor(x);
eta = x-n;
w = [w 0];
y = (1-eta).*w(n) + eta.*w(n+1);
y = y(1:length(x));