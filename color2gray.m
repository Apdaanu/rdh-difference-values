clc
clear all
close all
myimage = imread('test.jpg');
mycolorimage = imresize(myimage, [256, 256], 'nearest');
mygrayimage = rgb2gray(mycolorimage);
mybinimage = im2bw(mycolorimage);
subplot(2, 2, 1);
imshow(mycolorimage); title('Original Color Image');
subplot(2, 2, 2);
imshow(mygrayimage); title('Original gray image');
%{
subplot(2, 2, 3);
imshow(mybinimage); title('Binary Image');%}
