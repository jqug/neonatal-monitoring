function [S,x_out,P_out] = skf_adf(y,A,H,Q,R,x_0,Z,d,mu,prior,labels,chains,plotinfo,constraintransitions)

% SKF_FILTER  Switching Kalman filter
%
%   S = skf_adf(y,A,H,Q,R,x_0,P_0,Z,d,mu,prior,labels,chains,plotinfo)
%
%   S(t,i)      output, P(S_t=i|y)
%   y(t,:)      observation at time t, zero mean
%   A{j}        transition matrix for continuous state i
%   H{j}        emission matrix for state i
%   Q{j}        state j transition noise
%   R{j}        state j measurement noise
%   x_0(:)      initial estimate for continuous state
%   P_0(:,:)    initial estimate for state covariance
%   Z(i,j)      transition probability of discrete 
%                state i -> j
%   prior(1,i)  prior probability of state i
%   if plotinfo==-1 then no inferences are displayed.
%
%   Approximate inference using ADF algorithm.


% Murphy (1998), Switching Kalman Filters, section 2.3 
% Welch and Bishop (2004), An Introduction to the Kalman Filter

showprogress=1;
givewarnings=1;

%% If the following is set to one, return x_minus (predicted state, useful for diagnosing performance)
%% If set to zero, return x (corrected state, actual posterior estimate). 
returnpredictions=0;

auto_handle_dropouts = 1;
showfactorisedplot = 1;
if ~exist('labels'); labels={}; end;
if ~exist('plotinfo'); plotinfo={}; end;
if isfield(plotinfo,'showinference'); showprogress = plotinfo.showinference; end;
if ~exist('constraintransitions'); constraintransitions=0; end;
if showprogress
  if showfactorisedplot
    handles = animplot_init(y,length(chains),labels,plotinfo); 
  else
    handles = animplot_init(y,size(Z,1));
  end;
end

[T d_obs] = size(y);
d_state = size(A{1},1); 
M = size(Z,1);
P_0 = eye(d_state);
x = zeros(d_state,M,T+1);
x_ij = zeros(d_state,M,M);
P_ij = zeros(d_state,d_state,M,M);
S = zeros(T+1,M);
S_factorised = zeros(T+1,length(chains));
S_ij = zeros(M,1);
x_out = zeros(T,1);
P_out = zeros(T,1);
lik = zeros(T,M);
I = eye(d_state);
x(:,:,1) = repmat(x_0,1,M); % posterior estimates of state
xpred(:,:,1) = repmat(x_0,1,M); % predicted estimates for output to user

% Prepare a list of covariance entries which are allowed to be non-zero.
% This assumes that observation elements are diagonal.
% Raising the transition matrix to the power n shows all connections
% between elements of up to n transitions.
covmap ={};
for i=1:M
  covmap{i} = zeros(size(A{i}));
  Aconnected = A{1}^4;
  covmap{i}(find(Aconnected)) = 1;
  covmap{i}(find(Aconnected')) = 1;
end

if ~exist('prior') || isempty(prior)
    prior = ones(1,M-1)/(10*(M-1));
    prior = [prior .9]; 
end
for i=1:M
  P(:,:,i) = P_0;
end
S(1,:) = prior;
y = [zeros(1,d_obs);y];

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

for t=2:T+1
  if showprogress
    if showfactorisedplot
      S_factorised(t-1,:) = factoriseposteriors(S(t-1,:),chains+1);
      animplot_update(handles,S_factorised,t); 
    else
      animplot_update(handles,S,t);
    end;
  end
  S_norm = 0;
  S_marginal = zeros(M,M);
  for j=1:M % Work out probabilities of having moved to state j
    A_j = A{j};
    H_j = H{j};
    Q_j = Q{j};
    R_j = R{j};
    % Test for zeroes, and set empty observation matrix entries where appropriate
    if auto_handle_dropouts
      empty_indices = find(y(t,:)==0);
      H_j(empty_indices,:) = H_j(empty_indices,:)*0;
    end
    if ~mod(t,1)==0
      tmptrans = j;
    else
      tmptrans = trans{j}; % Get the limited set of states at time t-1 which could have led to state j
    end
    for i=tmptrans
      % Kalman update for each state
      x_minus = A_j * (x(:,i,t-1)-mu{j}) + mu{j} + d{j};
      P_minus = A_j * P(:,:,i) * A_j' + Q_j;

      % Ignore spurious covariances between observation channels. Assuming that observations are
      % diagonal.
      P_minus = P_minus.*covmap{j};
      
      K = (P_minus * H_j') * inv(H_j*P_minus*H_j' + R_j);
      
      %%% Can do some time-consuming checks here to see if the filtering is going OK.
      %if ~isempty(find(K>2))
      %  warning('Elements of Kalman gain are >> 1 - filter has become unstable.');
      %end
      %if ~isempty(find(eig(P_minus)<0))
      %  warning('Estimate covariance negative definite - filter has become unstable.');
      %end
      
      %%% Evaluating covariance of estimate: can use expression 1 which is the standard version,
      %%% but can be numerically unstable, or expression 2 which is a sum of psd matrices.
      %%% See e.g. Max Welling, 'The Kalman Filter'
      % P_ij(:,:,i,j) = (I - K*H_j)*P_minus; % expression 1
      P_ij(:,:,i,j) = (I - K*H_j)*P_minus*(I - K*H_j)' + K*R_j*K'; % expression 2
      
      x_ij(:,i,j) = x_minus + K*(y(t,:)' - H_j*x_minus);
      % Find the likelihood of data given S_t=j,S_t-1=i
      residualCovar = H_j*P_minus*H_j' + R_j;
      residualMean = (H_j*x_minus)';
      L = gauss(y(t,:),residualCovar,residualMean);
      if isnan(L) || (L<1e-8);
        L = 1e-8;
       end;
      S_marginal(i,j) = L * Z(i,j) * S(t-1,i);
      S_norm = S_norm + S_marginal(i,j);  
      %if (t==480)&&((i==2)&&(j==2))
        %keyboard
       % P_ij(:,:,1,1)
      %  P_ij(:,:,2,2)
      %  S_marginal
      %end
      if returnpredictions && i==j
        xpred(:,i,t) = x_minus;
      end
    end
  end
  % posterior for state j at time t
  S_marginal = S_marginal/S_norm;
  for j=1:M
    S(t,j) = sum(S_marginal(:,j));
  end
  % weights of state components
  for j=1:M
    for i=1:M
      W(i,j) = S_marginal(i,j)/S(t,j);
    end
  end
  % approximate new continuous state
  for j=1:M
    x(:,j,t) = x_ij(:,:,j) * W(:,j);
    P(:,:,j) = zeros(d_state);
    for i=trans{j}
      m = x_ij(:,i,j) - x(:,j,t);
      P(:,:,j) = P(:,:,j) + W(i,j)*(P_ij(:,:,i,j) + m*m');
    end
  end
  
  P_out(t-1) = S(t,:) * reshape(P(1,1,:),size(P,3),1);
  x_out(t-1) = x(1,:,t) * S(t,:)';
end


if ~returnpredictions
  x_out = x(:,:,1:end-1); % make it the same length as the input vector
else 
  x_out = xpred(:,:,1:end-1); % make it the same length as the input vector
end
%%% comment out permutation to save memory on a big experiment
%x_out = permute(x_out,[3 2 1]); % make it easy to plot, x(time,switch setting,dimension)
S = S(2:T+1,:);
