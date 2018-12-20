function joint=joint_histogram(x,y)
% take a pair of images of equal size and returns the 2D joint histogram
% assume those two images are statistically independent

xh=grey_histogram(x);
yh=grey_histogram(y);
joint=zeros(256,256);

for i=0:255
  for j=0:255
    joint(i+1,j+1)=xh(i+1)*yh(j+1);
  end
end

gdisplay(joint)

end