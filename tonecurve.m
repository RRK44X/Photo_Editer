close all
I=imread("peppers.png");

p0=[0 0;255 255];

hold on
n=3;

%{
p=set_global(p0);
[p bezierCurve]=plotline(p);
f0=fplot(bezierCurve(1), bezierCurve(2), [0, 1]);


[p bezierCurve]=plotline([100 10;180 300]);
f=fplot(bezierCurve(1), bezierCurve(2), [0, 1]);


yyaxis right
h1=histogram(I,"FaceColor","k","FaceAlpha",0.2,"EdgeColor","none","BinWidth",3);


syms t
yy=bezierCurve(2);
xx=0:1/255:1;
yy=double(subs(yy,t,xx));
%}

p=[p0; 40,100;100 10;200 300;220 100];
%[s,indx]=sort(p,1);
%p=p(indx(:,1),:);
plot(0:255,0:255)
[h w d]=size(I);



t=polyfit(p(:,1),p(:,2),size(p,1)-1);
xx=0:255;
yy=polyval(t,xx);
plot(yy,"-r")
f = @(x) yy(x+1);
I1 = arrayfun(f, I);

sp=spline(p(:,1),[0 p(:,2)' 0]);
xx=0:255;
yy=ppval(sp,xx);
plot(xx,yy,"-g")
f = @(x) yy(x+1);
I2 = arrayfun(f, I);

sp=interp1(p(:,1),p(:,2),xx,"makima");
plot(sp,"-y")
f = @(x) sp(x+1);
I3 = arrayfun(f, I);


s=scatter(p(:,1),p(:,2));
legend("y = x","Polyfit","Spline","Makima","Points","Location","northwest")
xlim([0,255])
clear
figure;
xx=0:255;
yy=0.5.*xx;
plot(yy)
xlim([0 255])
f = @(x) yy(x+1);
I=imread("peppers.png");
I1 = arrayfun(f, I);

yyaxis right
h1=histogram(I,"FaceColor","k","FaceAlpha",0.2,"EdgeColor","none","BinWidth",3);
h2=histogram(I2,"FaceColor","b","FaceAlpha",0.3,"EdgeColor","none","BinWidth",3);


figure;
subplot(1,2,1);imshow(I)
subplot(1,2,2);imshow(uint8(I1))
