close all
I=imread("peppers.png");
[h0 w0 ~]=size(I);

x1 = 100;x2 = 200;
y1 = 100;y2 = 400;

range = ones(size(I))*0.5;
range(y1:y2,x1:x2,:) = 1;

I2=double(I).*range;

subplot(1,2,1);imshow(I)
subplot(1,2,2);imshow(uint8(I2))