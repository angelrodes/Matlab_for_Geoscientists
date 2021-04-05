function [P]=normalprobs(x,mu,sigma) 
  % Calculates the probability of x based on a gaussian mu +/- sigma
  P=1/(2*pi*sigma^2)^0.5*exp(-(x-mu).^2./(2*sigma^2));
end

