function y = loggauss(mu, sigma, x)

% LOGGAUSS  Log Gaussian density.
%    Y = LOGGAUSS(mu, sigma, x)

[n, d] = size(x);
mu = reshape(mu, 1, d);    
x = x - ones(n, 1)*mu;
fact = sum(((x*inv(sigma)).*x), 2);
y = -0.5*fact - 0.5 * log((2*pi)^d) - 0.5 * log(det(sigma));
