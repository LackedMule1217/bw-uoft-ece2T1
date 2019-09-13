function [x y] = EMsolverS(e,f,g,h,j,k,T,N)
A = [e f; g h];
dt = T/N;
t = 0:dt:T;
SOL = NaN(2,length(t));
SOL(1,1) = j;
SOL(2,1) = k;
for(k = 2:length(t))
    SOL(:,k) = SOL(:,k-1) + dt*A*SOL(:,k-1);
end
x = SOL(1,:)
y = SOL(2,:)
end