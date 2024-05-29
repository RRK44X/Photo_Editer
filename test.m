t = 0.5;
I=imread("peppers.png");
xx = 0:255;
y = t*xx+128;
y(y<0) = 0;
y(y>255) = 255;

f = @(x) y(x+1);
I2 = arrayfun(f, I);
imshow(uint8(I2))