function result = f(t)
    syms a b
    if abs(a*t-b)<=0.5
        result = 1;
    else
        result = 0;
    end
end