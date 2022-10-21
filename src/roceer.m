function eer=roceer(FP,TP)

returnzero = 0;
f1=FP(1:length(FP)-1);
f2=FP(2:length(FP));
t1=TP(1:length(FP)-1);
t2=TP(2:length(FP));
a = f1-f2-t2+t1;
b = t1+f1-1;
%bet = a(1:(end-1))./b(1:(end-1));
warning off
b=(t1+f1-1)./(f1-f2-t2+t1);
warning on


soli=find(b>=0&b<1);
if isempty(soli)
     warning('no solution for EER');
     returnzero = 1;
end
if length(soli)>1
     %warning('multiple solutions for EER');
     returnzeros = 1;
end

if returnzero
  eer = 0;
else
  f1=f1(soli);
  f2=f2(soli);
  t1=t1(soli);
  t2=t2(soli);  
  eer=-(-f1+f2-t1.*f2+f1.*t2)./(f1-f2-t2+t1);
end
