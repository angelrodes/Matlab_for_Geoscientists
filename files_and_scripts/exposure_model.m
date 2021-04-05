
function [ C ] = exposure_model(P,L,l,density,z,C0,erosion,t)
  C=C0+...
    P(1)./(l+erosion.*density./L(1)).*exp(-z.*density./L(1)).*...
    (1-exp(-(l+erosion.*density./L(1)).*t))+...
    P(2)./(l+erosion.*density./L(2)).*exp(-z.*density./L(2)).*...
    (1-exp(-(l+erosion.*density./L(2)).*t))+...
    P(3)./(l+erosion.*density./L(3)).*exp(-z.*density./L(3)).*...
    (1-exp(-(l+erosion.*density./L(3)).*t));
end


