function [value, index]=magnRank(Lam,rank)
[sorted,I]=sort(diag(abs(Lam)));
index=I(rank);
value=Lam(index,index);
end