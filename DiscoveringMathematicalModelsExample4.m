%% Research code by Agus Hasan

clear;
clc;

%% time horizon
tf  = 1;
dt  = 0.0001;
t   = dt:dt:tf;

%% number of variables and coefficients
n = 3;
r = 5;

%% system description
A = eye(n);
C = eye(n);

%% noise
RF = 1;

%% state initialization
x        = [5;1;1];
xbar     = zeros(n,1);
y        = zeros(n,1);
thetabar = zeros(r,1);
 
%% true parameters
g = 9.8;
c = 1.5;
m = 0.1;
R = 6;
L = 3;

%% initial control inputs
u     = 2;

%% for plotting
uArray          = [];
xArray          = [];
xbarArray       = [];
yArray          = [];
thetabarArray   = [];

%% Initialization for estimator

lambdav = 0.995;
lambdat = 0.999;
Rx      = 1*eye(n);
Rt      = 1*eye(n);
Px      = 10000*eye(n);
Pt      = 10000*eye(r);
Gamma   = 1*zeros(n,r);

%% simulation
for i=1:(tf/dt)
    
    u = 10*sin(i*dt*40);

    uArray         = [uArray u];
    xArray         = [xArray x];
    xbarArray      = [xbarArray xbar];
    yArray         = [yArray y];
    thetabarArray  = [thetabarArray thetabar]; 
    
    x = A*x+dt*[x(2);g-(c/m)*(x(3)/x(1))^2;-(R/L)*x(3)]+dt*[0 0 1/L]'*u;    
    y = C*x+dt*RF^2*randn(n,1);

    Phi = [y(2) 0 0 0 0;
           0 1 (y(3)/y(1))^2 0 0;
           0 0 0 y(3) u];
    
    % Estimation using adaptive observer
    Kx = Px*C'*inv(C*Px*C'+Rx);
    Kt = Pt*Gamma'*C'*inv(C*Gamma*Pt*Gamma'*C'+Rt);
    Gamma = (eye(n)-Kx*C)*Gamma;

    xbar = xbar+(Kx+Gamma*Kt)*(y-C*xbar);
    thetabar = thetabar-Kt*(y-C*xbar);

    xbar = A*xbar+Phi*thetabar;

    thetabar = thetabar;
    Px = (1/lambdav)*eye(n)*(eye(n)-Kx*C)*Px*eye(n);
    Pt = (1/lambdat)*(eye(r)-Kt*C*Gamma)*Pt;
    Gamma = eye(n)*Gamma-Phi;

end

figure(1)
subplot(3,1,1)
plot(t,yArray(1,:),'-b','LineWidth',10);
hold on;
plot(t,xbarArray(1,:),':r','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
legend('measured','estimated')
grid on;
grid minor;
ylabel('x [m]')
subplot(3,1,2)
plot(t,yArray(2,:),'-b','LineWidth',10);
hold on;
plot(t,xbarArray(2,:),':r','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
grid on;
grid minor;
ylabel('v [m/s]')
subplot(3,1,3)
plot(t,yArray(2,:),'-b','LineWidth',10);
hold on;
plot(t,xbarArray(2,:),':r','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
grid on;
grid minor;
ylabel('i [Amp]')
xlabel('t (s)')

figure(2)
subplot(3,2,1)
plot(t,L*ones(1,length(t)),'-k','LineWidth',10);
hold on;
plot(t,dt./thetabarArray(5,:),':g','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
legend('true','estimated')
xlim([0 tf])
ylim([L-1 L+1])
grid on;
grid minor;
ylabel('L [H]')
subplot(3,2,2)
plot(t,L*ones(1,length(t))-(dt./thetabarArray(5,:)),':r','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
xlim([0 tf])
ylim([-1 1])
grid on;
grid minor;
ylabel('error L')
subplot(3,2,3)
plot(t,R*ones(1,length(t)),'-k','LineWidth',10);
hold on;
plot(t,-L*thetabarArray(4,:)/dt,':g','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
xlim([0 tf])
ylim([R-1 R+1])
grid on;
grid minor;
ylabel('R [Ohm]')
subplot(3,2,4)
plot(t,R*ones(1,length(t))+L*thetabarArray(4,:)/dt,':r','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
xlim([0 tf])
ylim([-1 1])
grid on;
grid minor;
ylabel('error R')
subplot(3,2,5)
plot(t,c*ones(1,length(t)),'-k','LineWidth',10);
hold on;
plot(t,-m*thetabarArray(3,:)/dt,':g','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
xlim([0 tf])
ylim([c-1 c+1])
grid on;
grid minor;
ylabel('C [F]')
xlabel('t (s)')
subplot(3,2,6)
plot(t,c*ones(1,length(t))+m*thetabarArray(3,:)/dt,':r','LineWidth',10);
set(gca,'color','white','LineWidth',3,'FontSize',36)
xlim([0 tf])
ylim([-1 1])
grid on;
grid minor;
ylabel('error C')
xlabel('t (s)')

Coeff = (1/dt)*thetabar(1:r,end)
Lbar = dt/thetabar(5,:)
Rbar = -Lbar*thetabar(4,:)/dt
Cbar = -m*thetabar(3,:)/dt