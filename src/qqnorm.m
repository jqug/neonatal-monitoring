function qqnorm(x,sigma,mu)


% plot x against inverse norm cdf
yy = sort(x);
b = ([1:length(x)]-.5) / length(x);
xx = inversenormal(b,sigma,mu);
mx = max(abs(xx));
mx = [-mx mx];
sx = [-sigma sigma];
plot(xx,yy,'k',mx,mx,'k:',sx,sx,'k--');
set(gca,'xlim',mx,'ylim',mx,'xtick',[],'ytick',[]);
xlabel('Normal quantiles');
ylabel('Empirical quantiles');

function n = inversenormal(p,sigma,mu)

x0 = -sqrt(2).*erfcinv(2*p);
n = sigma.*x0 + mu;

