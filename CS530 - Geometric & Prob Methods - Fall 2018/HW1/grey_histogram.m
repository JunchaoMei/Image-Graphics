function h=grey_histogram(im)
% take a grey level image and returns its histogram

rows=size(im,1);
cols=size(im,2);
area=rows*cols;

for i=0:255
    h(i+1)=sum(im(:) == i)/area;
end

figure
plot(0:255,h);
xlabel('pixel value'); ylabel('p.m.f.');

end