function [A,H,Q,R,Z,d,mu,pi,chains,activefactordims] = factors2statespace(factors)

% STATESPACEFROMFACTORS  Combine individual dynamics factor definitions 
%                        into a joint state-space.
%
% [A,H,Q,R,Z,d,mu,pi,chains,activefactordims] = factors2statespace(factors)
% returns a full dynamical model, where the 'factors' parameter is structured
% as follows:
%
% factors{1} - normal A, H, Q, R, mu
% factors{2+}:
%   factor{1} - A{i}(:,:) - state transition
%   factor{2} - H{i}(:,:) - emission
%   factor{3} - Q{i}(:,:) - transition noise
%   factor{4} - R{i}(:,:) - measurement noise
%   factor{5} - state channels affected
%   factor{6} - observation channels affected
%   factor{7} - Z - transition probabilities
%   factor{8} - d{i}(:) - drift
%   factor{9} - mu{i}(:) - hidden state mean
%
% Returns matrix activefactordims containing information as to which state
% dimensions are affected by which factors for each switch setting.
%
% activefactordims(switchsetting,statedimension) contains the index of the
% factor which overwrites dimension 'statedimension' in switch setting
% 'switchsetting', where factor 1 always corresponds to normality (no factors
% active).


normalstate = factors{1};
A_normal = normalstate{1};
H_normal = normalstate{2};
Q_normal = normalstate{3};
R_normal = normalstate{4};
mu_normal = normalstate{5};

if iscell(A_normal); A_normal = A_normal{1}; end;
if iscell(H_normal); H_normal = H_normal{1}; end;
if iscell(Q_normal); Q_normal = Q_normal{1}; end;
if iscell(R_normal); R_normal = R_normal{1}; end;
if iscell(mu_normal); mu_normal = mu_normal{1}; end;

chains = [];
for i=2:length(factors)
  chains = [chains size(factors{i}{7},1)];    
end

nstates = prod(chains);
d_state = size(A_normal,1);
d_obs = size(H_normal,1);
activefactordims = zeros(nstates,d_state);

chainindices = zeros(nstates,length(chains));

for i=1:nstates
  chainindices(i,:) = stateindex2chain(i,chains);
end

A = zeros(d_state,d_state,nstates);
H = zeros(d_obs,d_state,nstates);
Q = zeros(d_state,d_state,nstates);
R = zeros(d_obs,d_obs,nstates);

d = zeros(d_state,nstates);
mu = zeros(d_state,nstates);
pi = zeros(nstates,1);
 
for i=1:nstates
  chainindex = chainindices(i,:); 

  A(:,:,i) = A_normal;
  Q(:,:,i) = Q_normal;
  H(:,:,i) = H_normal;
  R(:,:,i) = R_normal;
  mu(:,i) = mu_normal;

  for j=1:length(chains)
    if chainindex(j) < chains(j) % if the factor is in an active (non-normal) setting 
      % dynamics
      dyn_channelsaffected = factors{j+1}{5};
      if ~isempty(dyn_channelsaffected) % if at least one state dimension is being affected by this factor in this switch setting
        A_factor = factors{j+1}{1};
        Q_factor = factors{j+1}{3};
        d_factor = factors{j+1}{8};
        mu_factor = factors{j+1}{9};
        activefactordims(i,dyn_channelsaffected) = j; % assign the active factor 
        A(dyn_channelsaffected,:,i) = A_factor{chainindex(j)}(dyn_channelsaffected,:);
        Q(dyn_channelsaffected,:,i) = Q_factor{chainindex(j)}(dyn_channelsaffected,:);
        d(dyn_channelsaffected,i) = d_factor{chainindex(j)}(dyn_channelsaffected);
        mu(dyn_channelsaffected,i) = mu_factor{chainindex(j)}(dyn_channelsaffected);
      end
  
      % observations
      obs_channelsaffected = factors{j+1}{6};
      if ~isempty(obs_channelsaffected)
        H_factor = factors{j+1}{2};
        R_factor = factors{j+1}{4};
        H(obs_channelsaffected,:,i) = H_factor{chainindex(j)}(obs_channelsaffected,:);
        R(obs_channelsaffected,:,i) = R_factor{chainindex(j)}(obs_channelsaffected,:);
      end
    end;
  end;

end;

Z = ones(nstates,nstates);

for i=1:nstates
  chain_i = chainindices(i,:);

  for j=1:nstates
    chain_j = chainindices(j,:);

    trans = zeros(length(chains),1);
    for k=1:length(chains)
      trans(k) = factors{k+1}{7}(chain_i(k),chain_j(k));
    end
    Z(i,j) = prod(trans);  
    
  end
end

chains = chains - 1;

activefactordims = activefactordims+1; % should be 1-indexed, so that normality = switch setting 1

% default prior is for all switch settings to be equally likely
pi = diag(Z);
pi = pi/sum(pi);
pi = pi';


% convert parameters to cell arrays
for i=1:nstates
A_out{i} = A(:,:,i);
H_out{i} = H(:,:,i);
Q_out{i} = Q(:,:,i);
R_out{i} = R(:,:,i);
d_out{i} = d(:,i);
mu_out{i} = mu(:,i);
end

A = A_out;
H = H_out;
Q = Q_out;
R = R_out;
d = d_out;
mu = mu_out;
