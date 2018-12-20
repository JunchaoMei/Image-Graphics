function Hx_y = entropy_Hx_y(Pxy,Px_y)
dim = size(Pxy);
n = dim(1);
m = dim(2);
sum = 0;

for j=1:m
    for i=1:n
        if Px_y(i,j)~=0
            sum = sum + Pxy(i,j)*log2(Px_y(i,j));
        end
    end
end

Hx_y = -sum;
end