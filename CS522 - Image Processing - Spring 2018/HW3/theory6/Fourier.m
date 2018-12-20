clear
syms t
F = fourier(f(t));
disp('F = ')
pretty(F)