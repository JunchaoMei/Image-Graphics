function A=circulant(x)
N=length(x);

for n=0:N-1
    % 初始化S
    for i=1:N
        for j=1:N
            S(i,j)=delta_Kro(mod(i-j-n,N));
        end
    end
    % 计算A的第n+1列
    Sx=S*x;
    for i=1:N
        A(i,n+1)=Sx(i);
    end
end
end