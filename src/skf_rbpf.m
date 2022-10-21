function S = skf_rbpf(y,A,H,Q,R,x_0,Z,d,mu,N,priors,labels,chains,plotinfo,constraintransitions)

% SKF_RBPF  Switching Kalman filter with approximate inference
%           using Rao-Blackwellised particle filtering.
%
%   S = skf_rbpf(y,A,H,Q,R,x_0,Z,d,mu,N,priors)
%
%   S(t,i)      output, P(S_t=i|y)
%   y(t,:)      observation at time t, zero mean
%   A(:,:,j)    transition matrix for discrete state i
%   H(:,:,j)    emission matrix for discrete state i
%   Q(:,:,j)    discrete state j transition noise
%   R(:,j)      discrete state j measurement noise
%   x_0(:,i)    initial estimate for continuous state for particle i
%   P_0(:,:,i)  initial estimate for state covariance for particle i
%   Z(i,j)      transition probability of discrete 
%                state i -> j
%   d(:,i)      constant drift of hidden cont state, in discrete state i
%   mu(:,i)     mean of observations in state i
%   priors(1,i)     prior probability of state i
%   N           number of particles
%
%   Approximate inference using Rao-Blackwellised particle
%   filtering (de Freitas)


[T d_obs] = size(y);
d_state = size(x_0,1); 
M = size(Z,1);
warning off;
showprogress = 1;
auto_handle_dropouts = 1;
showfactorisedplot = 1;
if ~exist('labels'); labels={}; end;
if ~exist('plotinfo'); plotinfo={}; end;
if isfield(plotinfo,'showinference'); showprogress = plotinfo.showinference; end;
if ~exist('constraintransitions'); constraintransitions=0; end;

if ~exist('priors') || isempty(priors') 
  priors = ones(M,1)/M; 
end


if showprogress
  if showfactorisedplot
    handles = animplot_init(y,length(chains),labels,plotinfo); 
  else
    handles = animplot_init(y,size(Z,1));
  end;
end

P_0 = eye(d_state);

x = zeros(d_state,N,T);
z = zeros(N,T);
w = ones(N,1);
z_hat = zeros(N,1);
x_hat = zeros(d_state,N);
P = zeros(d_state,d_state,N);

S = zeros(T,M);
x_out = zeros(T,1);
P_out = zeros(T,1);
K_out = zeros(T,1);
S_factorised = zeros(T+1,length(chains));

% which states is it possible to transition into from other states
trans = cell(M,1);
if constraintransitions
  for i_state=1:M
    trans{i_state} = i_state;
    currchain = stateindex2chain(i_state,chains+1);
    for i_chain=1:length(chains)
      for chain_setting = [1:currchain(i_chain)-1 currchain(i_chain)+1:chains(i_chain)+1]
        posschain = currchain;
        posschain(i_chain) = chain_setting;
        possstate = chainindex2state(posschain,chains+1);
        trans{i_state} = [trans{i_state} possstate]; 
      end
    end
  end
else
  for i_state=1:M
    trans{i_state} = [1:M];
  end
end


for i=1:N
  x(:,i,1) = x_0; 
  P(:,:,i) = P_0; 
  z(i,1) = length(find(cumsum(priors)<rand))+1; 
end

% smoothing of Z to encourage particles to switch
Z = Z+.1;
Z = Z./repmat(sum(Z,2),1,M);


for t=2:T

  if showprogress
    if showfactorisedplot
      S_factorised(t-1,:) = factoriseposteriors(S(t-1,:),chains+1);
      animplot_update(handles,S_factorised,t); 
    else
      animplot_update(handles,S,t);
    end;
  end
  
  % sampling
  for i=1:N

    % sample from transition prior
    if constraintransitions
      Z_constr = zeros(size(Z,1),1);
      Z_constr(trans{z(i,t-1)}) = Z(z(i,t-1),trans{z(i,t-1)});
      Z_constr = Z_constr/sum(Z_constr);
      z_hat(i) = length(find(cumsum(Z_constr)<rand))+1;
    else
      z_hat(i) = length(find(cumsum(Z(z(i,t-1),:)')<rand))+1;
    end 

    A_i = A{z_hat(i)}; 
    H_i = H{z_hat(i)};
    Q_i = Q{z_hat(i)}; 
    R_i = R{z_hat(i)};
    d_i = d{z_hat(i)};
    mu_i = mu{z_hat(i)};

    % evaluate importance weights
    x_hat(:,i) = (A_i*(x(:,i,t-1)-mu_i) + d_i) + mu_i;
    P_hat(:,:,i) = A_i*P(:,:,i)*A_i' + Q_i;
    w(i) = gauss(y(t,:),H_i*P_hat(:,:,i)*H_i' + R_i,(H_i*x_hat(:,i))');
  end

  % particle selection
  w = w/sum(w);
  selected = deterministicR(1:N,w(:));
  x_hat = x_hat(:,selected);
  P_hat = P_hat(:,:,selected);
  w = w(selected);
  z(:,t) = z_hat(selected);

  % updating
  for i=1:N
    A_i = A{z(i,t)}; 
    H_i = H{z(i,t)};
    Q_i = Q{z(i,t)};
    R_i = R{z(i,t)};
    mu_i = mu{z(i,t)};

    K = (P_hat(:,:,i) * H_i') * (H_i*P_hat(:,:,i)*H_i' + R_i)^-1;
    P(:,:,i) = (eye(d_state) - K*H_i)*P_hat(:,:,i);
    x(:,i,t) = x_hat(:,i) + K*(y(t,:)' - H_i*x_hat(:,i));
    K_out(t) = K_out(t) + K(1)*w(i);
  end

  % summary statistics
  w = w/sum(w);
  for i=1:N
    S(t,z(i,t)) = S(t,z(i,t)) + w(i);
    x_out(t) = (x_out(t) + x(1,i,t)*w(i));
    P_out(t) = P_out(t) + P(1,1,i)*w(i);
  end
  x_out(t) = x_out(t);
  S(t,:) = S(t,:)/sum(S(t,:));

end

