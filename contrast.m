close all
I=imread("peppers.png");

[h w d]=size(I);


a=1.5;
hold on

syms t
y=255/(1+exp(a*(-1*t+127)));
xx=0:255;
plot(xx,xx)
%{
yy=double(subs(y,t,xx));
plot(yy)
%}

syms t
y=a*(t-128)+128;

xx=0:255;
yy=double(subs(y,t,xx));
yy(yy<0)=0;
yy(yy>255)=255;

plot(yy)
fun = @(x) yy(x+1);
I1 = arrayfun(fun, I);


a=0.5;
syms t
y=a*(t-128)+128;

xx=0:255;
yy=double(subs(y,t,xx));
yy(yy<0)=0;
yy(yy>255)=255;

plot(yy)

xlim([0,255])
legend("y=x","y=a*(x-128)+128  a=1.5","y=a*(x-128)+128  a=0.5","Location","northwest")

fun = @(x) yy(x+1);
I2 = arrayfun(fun, I);

figure;
subplot(3,1,1);imshow(uint8(I1))
subplot(3,1,2);imshow(uint8(I))
subplot(3,1,3);imshow(uint8(I2))

