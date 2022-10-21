function [A,H,Q,R,d,x_0,P_0] = ar2statespace(alpha,e);

% AR2STATESPACE  Convert AR coefficients into state space
%                transition and emission matrices.
%
%   [A,H,Q,R,d,x_0,P_0] = ar2statespace(alpha,e)

p = length(alpha);
if size(alpha,1)>size(alpha,2)
  alpha = alpha';
end

A = [alpha; [eye(p-1) zeros(p-1,1)]];

H = [1 zeros(1,p-1)];

Q = diag([e zeros(1,p-1)]);

d = zeros(p,1);
x_0 = d;
P_0 = eye(p);
R = 1;

