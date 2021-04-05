function [ ] = drawboxplot( ages,x,width )
%DRAWBOXPLOT Summary of this function goes here
%   Detailed explanation goes here
%% calculate the cuartiles
Q1=quantile(ages,0.25);
Q2=median(ages);
Q3=quantile(ages,0.75);
maxbar=Q3+1.5*(Q3-Q1);
minbar=Q1-1.5*(Q3-Q1);
outliers=ages(ages<minbar | ages>maxbar);
%% plot box at position x=2
plot([x-width,x+width],[Q1,Q1],'-k')
plot([x-width,x+width],[Q2,Q2],'-k')
plot([x-width,x+width],[Q3,Q3],'-k')
plot([x-width,x-width],[Q1,Q3],'-k')
plot([x+width,x+width],[Q1,Q3],'-k')
plot([x,x],[Q3,maxbar],'-k')
plot([x,x],[Q1,minbar],'-k')
plot([x-width/2,x+width/2],[minbar,minbar],'-k')
plot([x-width/2,x+width/2],[maxbar,maxbar],'-k')

plot(ones(size(outliers))*2,outliers,'.k')


end

