function Hxy = entropy_Hxy(Pxy)
dim = size(Pxy);
n = dim(1);
m = dim(2);
sum = 0;

for i=1:n
    for j=1:m
        if Pxy(i,j)~=0
            sum = sum + Pxy(i,j)*log2(Pxy(i,j));
        end
    end
end

Hxy = -sum;
end