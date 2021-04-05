function [ myfit ] = leastsquares( x,y )
a=(length(x)*sum(x.*y)-sum(x)*sum(y))/(length(x)*sum(x.^2)-sum(x)^2);
b=(sum(x.^2)*sum(y)-sum(x)*sum(x.*y))/(length(x)*sum(x.^2)-sum(x)^2);
myfit = @(x) a*x+b;
end

