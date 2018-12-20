function [Px_y, Pxy] = image_conditional_joint(X,Y)
rows = size(X,1);
cols = size(X,2);
X_Y = zeros(256,256);
Px_y = zeros(256,256);
Pxy = zeros(256,256);

% conditional counts
for j=0:255
    for a=1:rows
        for b=1:cols
            if Y(a,b)==j
                X_Y(X(a,b)+1,j+1) = X_Y(X(a,b)+1,j+1) + 1;
            end
        end
    end
end

% conditional probabilities
Tx_y=sum(X_Y);
for i=1:256
	for j=1:256
        if Tx_y(j)==0
            Px_y(i,j)=0;
        else
            Px_y(i,j)=X_Y(i,j)/Tx_y(j);
        end
	end
end

% joint probabilities
Py = grey_histogram(Y);
for i=1:256
	for j=1:256
        Pxy(i,j)=Py(j)*Px_y(i,j);
	end
end

end