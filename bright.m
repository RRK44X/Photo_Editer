I=imread("peppers.png");

x=1.5;

I2=double(I)*x;

subplot(1,2,1);imshow(I)
subplot(1,2,2);imshow(uint8(I2))