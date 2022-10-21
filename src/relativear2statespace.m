function [A,Q,H] = relativear2statespace(a1,a2,e1,e2)

% [A,Q,H] = relativear2statespace(a1,a2,e1,e2)

p1 = length(a1);
p2 = length(a2);
a1 = reshape(a1,p1,1);
a2 = reshape(a2,p2,1);


if p2<p1
  a2 = [a2; zeros(p1-p2,1)];
  p2 = length(a2);
end


A = zeros(p1+p2);
Q = zeros(p1+p2);
H = zeros(1,p1+p2);

[A1,H1,Q1,R1,d,x_0,P_0] = ar2statespace(a1,e1);
A(1:p1,1:p1) = A1;
[A2,H2,Q2,R2,d,x_0,P_0] = ar2statespace(a2,e2);
A(p1+1:p1+p2,p1+1:p1+p2) = A2;
A(1,p1+1) = 1;
A(1,p1+1:p1+p1) = A(1,p1+1:p1+p1) - a1';

Q(1,1) = e1 + e2;
Q(p1+1,p1+1) = e2;

H = [1 zeros(1,p1+p2-1)];

