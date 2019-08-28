% clc
% clear all
% close all
% testImage = imread('test1.jpg');
% temp = 0;

% for i = 1 : 256
%     for j = 1 : 256
%         temp = dec2bin(testImage(i, j));
%         %testImage(i, j) = temp;
%     end
% end

function  r = expandable (h, l)
    r = abs(2*h + 1) <= min(2*(255 - l), 2*l + 1) && abs(2*h) <= min(2*(255-l), 2*l + 1);
end