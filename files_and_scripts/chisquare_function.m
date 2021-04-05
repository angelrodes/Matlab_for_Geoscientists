function [ chisq ] = chisquare_function(P,L,l,density,z,C0,erosion,t,Be10,Be10error)
  chisq=0;
  for n=1:length(z)
    chisq=chisq+...
      ((exposure_model(P,L,l,density,z(n),C0,erosion,t)-Be10(n))./...
      Be10error(n)).^2;
  end
end
