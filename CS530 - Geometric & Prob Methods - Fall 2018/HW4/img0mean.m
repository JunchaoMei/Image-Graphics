function [newR,newG,newB] = img0mean(imR, imG, imB)
rows=size(imR,1);
cols=size(imG,2);

sumVec = [0; 0; 0];
for i=1:rows
	for j=1:cols
		xij = [imR(i,j); imG(i,j); imB(i,j)];
		sumVec = sumVec + xij;
	end
end

meanVec = sumVec / (rows*cols);
newR = imR - meanVec(1);
newG = imG - meanVec(2);
newB = imB - meanVec(3);
end
