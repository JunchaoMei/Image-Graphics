function fN=truncate_Fourier(N)
j=sqrt(-1);
t=-4*pi:0.01:4*pi;
I=length(t);

for i=1:I
    sum=0;
    for omega=-N:N
        if omega~=0
            sum = sum + (j/omega)*exp(j*omega*t(i));
        end
    end
    fN(i) = sum + pi;
end

figure
[AX,H1,H2] =plotyy(t,real(fN),t,imag(fN),@plot);% »ñÈ¡×ø±êÖá¡¢Í¼Ïñ¾ä±ú
title(['Truncated Fourier Series with N=',num2str(N)]);
xlabel('t');
set(get(AX(1),'ylabel'),'string','real part');
set(get(AX(2),'ylabel'),'string', 'imaginary part');
set(H1,'Linestyle','-');
set(H2,'Linestyle',':');
legend('real part','imaginary part');

end