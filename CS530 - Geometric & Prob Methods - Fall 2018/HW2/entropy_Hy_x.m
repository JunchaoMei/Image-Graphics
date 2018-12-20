function Hy_x = entropy_Hy_x(Pxy,Py_x)
dim = size(Pxy);
n = dim(1);
m = dim(2);
sum = 0;

for i=1:n
    for j=1:m
        if Py_x(j,i)~=0
            sum = sum + Pxy(i,j)*log2(Py_x(j,i));
        end
    end
end

Hy_x = -sum;
end