% Problem 1.5 %

function result = f(t)
    syms s0
    result = exp(-pi*(t^2))*sin(2*pi*s0*t);
end

% Fourier.m
clear
syms t
F = fourier(f(t));
disp('F = ')
pretty(F)

>> Fourier
F = 
     /                2 \         /                2 \
     |   (w - 2 pi s0)  |         |   (w + 2 pi s0)  |
  exp| - -------------- | 1i   exp| - -------------- | 1i
     \        4 pi      /         \        4 pi      /
- -------------------------- + --------------------------
               2                            2