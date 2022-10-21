function xi = learnxf(y,A,Q,H,R,d,mu,pi,chains,x_init,Z,activefactordims);

% epsilon = learnxf(eps_init,y,A,Q,H,R,x_init,P_init,Z);
%
% Single EM update for X-factor parameter xi.

[S,x,P_out] = skf_adf(y,A,H,Q,R,x_init,Z,d,mu,[],{},chains,{},1);

xi = 0;
xfactorindex = 2; % 1 is always normal, if X-factor is included it must be 2 (any known factor overwrites the X-factor, and the X-factor overwrites normality)
d_state = size(A{1},1);
nstates = length(A);
normaliser = 0;

for t=2:size(y,1)
  for s = 1:nstates
    newx = S(t,:)*reshape(x(t,:,:),nstates,d_state);   %reshape2vector(x(t,s,:));
    oldx = S(t-1,:)*reshape(x(t-1,:,:),nstates,d_state);  %reshape2vector(x(t-1,s,:)); % might want to change to expectation over all states
    xdiff = (newx'-A{s}*oldx');
    for dim=1:d_state
      if activefactordims(s,dim)==xfactorindex
        if Q{nstates}(dim,dim)>0  % avoid effects of dealing with lagged versions of variables
          xi_local = xdiff(dim)^2 / Q{nstates}(dim,dim); % expected xi for this instant
          %if xi_local>1 % don't want to settle on a local optima which has smaller variance than normality 
            xi = xi + xi_local*S(t,s);
            normaliser = normaliser + S(t,s);
          %end
        end
      end
    end
  end
end

xi = xi/normaliser;


if 0
epsilon = 0;
for t=2:size(y,1)
xdiff = (x(:,t)-A{1}*x(:,t-1));
Qinv_prime = inv(Q{1});
Qinv = zeros(size(Qinv_prime));
Qinv(1,1) =  + Qinv_prime(1,1);
epsilon = epsilon + ( xdiff'*Qinv*xdiff ) *S(t,2);
end
n = sum(S(:,2));
epsilon = epsilon/n;
end




