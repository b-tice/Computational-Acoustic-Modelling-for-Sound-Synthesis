
% Brian Tice
% 1/15/2023
% Assignment A1 W23, Question 2

% Implement a parametric circular delay line in Matlab where the single 
% parameter M is the integer length of the effective sample delay.

% -implement the integer sample delay using a read and write pointer to a 
%  delay line having a maximum length M_max set according to the longest 
%  expected delay (or lowest frequency);

% -verify your implementation by looking at its impulse response, the 
%  output in response to an impulse as input;



function y = circular_delay(M,x)


    % the easy way, use built in circular delay function in MATLAB:
    % y = circshift(x,M);

    % the hard way, use input and output pointers:

    % cover the base case of a delay of length zero
    if(M == 0)
        y = x;
        return;
    end

    % initialize pointers in and out
    in = 1;
    out = length(x) - M + 1;

    y = zeros(length(x),1);
   
    buffer = zeros(length(x),1);

    for i=1:length(x)

        

        in = in + 1;
        out = out + 1;

        if(in > length(x))
            in = 1;
        end

        if(out >= length(x)+1)
            out = 1;
        end
        
        buffer(in) = x(i);
        y(i) = buffer(out);

        % debug = [buffer(out), buffer(in), x(i)];
        
        % disp(debug);
        
        % disp(y');
  
    end

    y = y';
    return;

end








