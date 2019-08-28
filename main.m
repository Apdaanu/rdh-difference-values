%Read the grayscale image

grayImage = imread('test1.jpg');


%Convert the grayImage matrix into double to obtain correct values of 'h'

grayImage = double(grayImage);


%Create the list of difference values and partition in four sets

M1 = zeros(256, 128);
EZ = uint8.empty;
EN = uint8.empty;
CN = uint8.empty;
NC = uint8.empty;

    %This loop partitions in four sets.

for i = 1:256
    for j = 1:128
        h = grayImage(i, 2*j-1) - grayImage(i, 2*j);
        l = floor((grayImage(i, 2*j-1) + grayImage(i, 2*j))/2);
        isExp = expandable(h, l);
        isChg = changeable(h, l);
        
        M1(i, j) = abs(h);

        if isExp && (h == 0 || h==1)
            EZ = [EZ ; i j];

        elseif isExp && (h ~= 0 && h ~= 1)
            EN = [EN ; i j];

        elseif ~isExp && isChg
            CN = [CN ; i j];

        else
            NC = [NC ; i j];
        end
    end
end

%3. create a location bitmap
locationMap = zeros(256, 128);
EN1 = uint8.empty;
EN2 = uint8.empty;
    
    %divide into EN1 and EN2
for i = 1:numel(EN)/2
    h = M1(EN(i, 1), EN(i, 2));
        %Take the threshold value, T =3
    if h >= 3;
        EN1 = [EN1 ; EN(i, 1) EN(i, 2)];
    else 
        EN2 = [EN2 ; EN(i, 1) EN(i, 2)];
    end
end

    %form location map
for i = 1: numel(EZ)/2
    locationMap(EZ(i, 1), EZ(i, 2)) = 1;
end

for i = 1: numel(EN1)/2
    locationMap(EN1(i, 1), EN1(i, 2)) = 1;
end

for i = 1: numel(EN2)/2
    locationMap(EN2(i, 1), EN2(i, 2)) = 0;
end

for i = 1: numel(CN)/2
    locationMap(CN(i, 1), CN(i, 2)) = 0;
end

for i = 1: numel(NC)/2
    locationMap(NC(i, 1), NC(i, 2)) = 0;
end

    %compress the locationMap

locationMapCompressed = rle(locationMap);


%4. collect original LSB's EN2 U CN
lsbBitstream = uint8.empty;
for i = 1: numel(EN2)/2
    test = dec2bin(M1(EN2(i, 1), EN2(i, 2)));
    lsbBitstream = [lsbBitstream test(numel(test))];
end

for i = 1: numel(CN)/2
    test = dec2bin(M1(CN(i, 1), CN(i, 2)));
    lsbBitstream = [lsbBitstream test(numel(test))];
end


%5. Embed the bitstream

    %Forming random payloads.
payload(:, :, 1) = (randi([0 1],10000,1))';
payload(:, :, 2) = (randi([0 1],10000,1))';
payload(:, :, 3) = (randi([0 1],10000,1))';
payload(:, :, 4) = (randi([0 1],10000,1))';
payload(:, :, 5) = (randi([0 1],10000,1))';

    %Array to store transformed images into.
transformedImageArray = uint8.empty;

for payloadCount = 1:5
        %Forminf the final bitstream to be embedded
    finalBitStream = [locationMapCompressed lsbBitstream payload(:, :, payloadCount)];

    m = 1;
    row = 1;
    column = 1;
        %Loop to embedd the final bitstream bitwise.
    while m <= numel(finalBitStream)
        temp = M1(row, column);
        [tf1, index1] = ismember([row column], EZ, 'rows');
        [tf2, index2] = ismember([row column], EN1, 'rows');
        if tf1 || tf2
            M1(row, column) = 2*temp + finalBitStream(m);
            if row <256
                row = row + 1;
            else 
                column = column + 1;
                row = 1;
                if column > 128
                    disp('limit exceeded');
                end
            end
        else
            [tf1, index1] = ismember([row column], EN2, 'rows');
            [tf2, index2] = ismember([row column], CN, 'rows');
            if tf1 || tf2
                M1(row, column) = 2*floor(temp/2) + finalBitStream(m);
                if row <256
                    row = row + 1;
                else 
                    column = column + 1;
                    row = 1;
                    if column > 128
                        disp('limit exceeded');
                    end
                end 
            end
        end 
        m = m+1;
    end 


        %6. Reverse Integer transform the image.
    transformedImage = zeros(256, 256);
    for i = 1:256
        for j = 1:128
            l = floor((grayImage(i, 2*j-1) + grayImage(i, 2*j))/2);
            tempx = l + floor((M1(i, j) + 1)/2);
            tempy = l - floor(M1(i, j)/2);
            transformedImage(i, 2*j-1) = tempy;
            transformedImage(i, 2*j) = tempx;        
        end
    end
    transformedImage = uint8(transformedImage);

        %Store the result into transformedImageArray
    transformedImageArray(:, :, payloadCount) = transformedImage;
end

    %Converting the original image array back to uint8 for display of image.
grayImage = uint8(grayImage);

    %calculating psnr values
psnrArray = double.empty;
for i = 1:5
    psnrArray = [psnrArray psnr(transformedImageArray(:, :, i), grayImage)];
end

    %show the results.

subplot(2,3,1);
imshow(grayImage); title('original image');
subplot(2,3,2);
imshow(transformedImageArray(:, :, 1)); title(['bpp: 0.15 psnr: ' psnrArray(1)]);
subplot(2,3,3);
imshow(transformedImageArray(:, :, 2)); title(['bpp: 0.305 psnr: ' psnrArray(2)]);
subplot(2,3,4);
imshow(transformedImageArray(:, :, 3)); title(['bpp: 0.457 psnr: ' psnrArray(3)]);
subplot(2,3,5);
imshow(transformedImageArray(:, :, 4)); title(['bpp: 0.91 psnr: ' psnrArray(3)]);
subplot(2,3,6);
imshow(transformedImageArray(:, :, 5)); title(['bpp: 1.83 psnr: ' psnrArray(3)]);
