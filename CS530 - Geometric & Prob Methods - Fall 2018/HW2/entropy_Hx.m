function Hx = entropy_Hx(Px)
sum = 0;
N = length(Px);

for i=1:N
    if Px(i)~=0
        sum = sum + Px(i)*log2(Px(i));
    end
end

Hx = -sum;
end