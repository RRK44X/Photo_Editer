I=imread("peppers.png");
[h0 w0 ~]=size(I);


t=-pi/4;

A=[cos(t) sin(t) 0; -sin(t) cos(t) 0; 0 0 1];
Af=affine2d(A');
I2=imwarp(I,Af);
I2=I;
[h w ~]=size(I2);
I2=I2(floor(h/2)+1-floor(h0/2):floor(h/2)+floor(h0/2),floor(w/2)+1-floor(w0/2):floor(w/2)+floor(w0/2),:);

subplot(1,2,1);imshow(I)
subplot(1,2,2);imshow(uint8(I2))