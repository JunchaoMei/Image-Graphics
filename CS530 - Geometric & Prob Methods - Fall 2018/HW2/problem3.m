function H = problem3()
sum = 0;

for n=1:12367
    pn = 0.1/n;
    sum = sum + pn*log2(pn);
end

H = -sum;
end