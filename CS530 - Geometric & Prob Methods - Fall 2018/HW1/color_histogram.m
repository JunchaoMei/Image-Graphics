function [hR,hG,hB]=color_histogram(imR,imG,imB)
% take R & G & B components of a color image and returns their histogram

rows=size(imR,1);
cols=size(imG,2);
area=rows*cols;

for i=0:255
    hR(i+1)=sum(imR(:) == i)/area;
    hG(i+1)=sum(imG(:) == i)/area;
    hB(i+1)=sum(imB(:) == i)/area;
end

figure
plot(0:255,hR,'r',0:255,hG,'g',0:255,hB,'b');
xlabel('pixel value'); ylabel('p.m.f.');
legend('Red','Green','Blue');

end