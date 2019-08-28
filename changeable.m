function r = changeable( h, l )
    %checks the changeabiblity of a pair
    temp = 2*floor(h/2);
    r = abs(temp + 1) <= min(2*(255 -l), 2*l + 1) && abs(temp + 0) <= min(2*(255 -l), 2*l + 1);
end

