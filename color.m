I=imread("peppers.png");
[h0 w0 ~]=size(I);

t=0.5;

I2=I;
Imax = I*(1+t);
Imin = I*(1-t);

[~, imax]=max(I,[],3);
[~, imin]=min(I,[],3);


for d=1:3
    i=find(imax==d);
    I2(h0*w0*(d-1)+i)=Imax(h0*w0*(d-1)+i);
    i=find(imin==d);
    I2(h0*w0*(d-1)+i)=Imin(h0*w0*(d-1)+i);
end


subplot(1,2,1);imshow(I)
subplot(1,2,2);imshow(uint8(I2))