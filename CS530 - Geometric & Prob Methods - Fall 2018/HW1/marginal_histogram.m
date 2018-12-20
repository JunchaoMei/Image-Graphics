function [xh,yh]=marginal_histogram(joint)
% take a 2D joint histogram and returns the marginal histogram on both
% dimensions

yh=sum(joint);
xh=sum(joint');

figure
plot(0:255,xh,0:255,yh);
xlabel('pixel value'); ylabel('p.m.f.');
legend('marginal X','marginal Y');

end