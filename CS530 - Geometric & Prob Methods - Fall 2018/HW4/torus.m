function result = torus(t_end)
% parameters
dx=1; dy=1; dt=0.005;
x=0:dx:64;
y=0:dy:64;
t=0:dt:2;
c=100; sigma=3;

N=length(x);
M=length(y);
G=floor((t_end/dt))+1;

% initial condition
for i=1:N
    for j=1:M
        P(i,j,1) = exp(-0.5*((x(i)-32)^2+(y(j)-32)^2)/sigma)/(2*pi*sigma);
        P(i,j,2) = P(i,j,1);
    end
end

% iteration
for k=3:G
    for i=1:N
        for j=1:M
            if i==1 && j==1
                P(1,1,k) = 2*P(1,1,k-1)-P(1,1,k-2);
            elseif i==1 && j==2
                P(1,2,k) = (2*P(1,2,k-1)-P(1,2,k-2)-(c^2)*P(1,1,k))/(1-c^2);
            elseif i==1 && j>=3
                P(1,j,k) = (2*P(1,j,k-1)-P(1,j,k-2)-2*(c^2)*P(1,j-1,k)+(c^2)*P(1,j-2,k))/(1-c^2);
            elseif i==2 && j==1
                P(2,1,k) = (2*P(2,1,k-1)-P(2,1,k-2)-(c^2)*P(1,1,k))/(1-c^2);
            elseif i==2 && j==2
                P(2,2,k) = (2*P(2,2,k-1)-P(2,2,k-2)-(c^2)*P(1,2,k)-(c^2)*P(2,1,k))/(1-2*c^2);
            elseif i==2 && j>=3
                P(2,j,k) = (2*P(2,j,k-1)-P(2,j,k-2)-(c^2)*P(1,j,k)-2*(c^2)*P(2,j-1,k)+(c^2)*P(2,j-2,k))/(1-2*c^2);
            elseif i>=3 && j==1
                P(i,1,k) = (2*P(i,1,k-1)-P(i,1,k-2)-2*(c^2)*P(i-1,1,k)+(c^2)*P(i-2,1,k))/(1-c^2);
            elseif i>=3 && j==2
                P(i,2,k) = (2*P(i,2,k-1)-P(i,2,k-2)-2*(c^2)*P(i-1,2,k)+(c^2)*P(i-2,2,k)-(c^2)*P(i,1,k))/(1-2*c^2);
            else
                P(i,j,k) = (2*P(i,j,k-1)-P(i,j,k-2)-(2*c^2)*P(i-1,j,k)+(c^2)*P(i-2,j,k)-(2*c^2)*P(i,j-1,k)+(c^2)*P(i,j-2,k))/(1-2*c^2);
            end
        end
    end
end

result = P(:,:,G);
end