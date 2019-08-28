function [ locationMapCompressed ] = rle( locationMap )
%RLE Summary of this function goes here
%   Detailed explanation goes here

% numCode = chainCode - '0'; % turn to numerical array
% relMat = [];
% numCode = [numCode nan]; % dummy ending

% N = 1;
% for i = 1:length(numCode)-1   
%     if numCode(i)==numCode(i+1)
%         N = N + 1;
%     else
%         valuecode = numCode(i);
%         lengthcode =  N;
%         relMat = [relMat; valuecode lengthcode];
%         N = 1;
%     end
% end

numCode = [];
N = 1;
relMat = [];
locationMapCompressed = [];
for i = 1:256;
    numCode = [numCode locationMap(i, :)];
end

for i = 1:length(numCode) -1
    if numCode(i) == numCode(i+1)
        N = N + 1;
    else
        valuecode = numCode(i);
        lengthcode = N;
        relMat = [relMat; valuecode lengthcode];
        N = 1;
    end
end

for i = 1:length(relMat)
    locationMapCompressed = [locationMapCompressed dec2bin(relMat(i, 1)) dec2bin(relMat(i, 2))];
end

end

