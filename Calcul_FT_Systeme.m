%% Initial calculations
close all; clc; clear all;
[num, txt, tab] = xlsread('Test_Speed.csv');
TeF=num(6,2)-num(5,2);  % Sampling period of data in essai.xlsx
y=num(:,1);
t=num(:,2);
d1y = diff(y,1)/TeF;  % Approximate first derivative by difference [y(2)-y(1)]
d2y = diff(y,2)/TeF;  % Approximate second derivative by difference [y(2)-y(1)]
%% Global variables
p=tf([1,0],[1]);  % p = P in Laplace, use for futur transfer function
KF=20/5;
%% Data display
close all;
figure(1)
plot(t,y);  % Display of the test
legend('Trottinette Test')
title('System transfer function')
xlabel('Time (seconds)');ylabel('Amplitude (km/h)');
%% calculation of the inflection point
t_infl = fzero(@(T) interp1(t(2:end-1),d2y,T,'linear',100),0);  % Find sign change of second derivative
y_infl = interp1(t,y,t_infl,'linear','extrap');  % Find the associated y of t_infl
figure(2)
title('System transfer function with inflection point');
xlabel('Time (seconds)');ylabel('Amplitude (km/h)');
plot(t_infl,y_infl,'ro',t,y)
legend('Inflection point','Trottinette Test')
%% Calculation of the tangent at the inflection point  
slope  = interp1(t(1:end-1), d1y, t_infl);  % Calculation the slope of tangent
intcpt = y_infl - slope*t_infl;  % Calculation the point at the origin of tangent
tngt = slope*t + intcpt;  % Function of tangent at the inflection point
figure(3)
plot(t_infl,y_infl,'ro',t,y)
legend('Inflection point','Trottinette Test')
hold on
plot(t, tngt,'-r', 'LineWidth',1)  % Tangent display 
title('System transfer function with inflection point and tangent')
xlabel('Time (seconds)');ylabel('Amplitude (km/h)');
axis([xlim,0,25])
%% Calculation transfer function by Strejc
Tstrejc=0.32;   % Calculate with the graph for Strejc
TFs=(KF)/(Tstrejc*p+1)^6;  % TF by Strejc
[yfts,tfts]=step(TFs);
figure(4)
plot(t,y,tfts,5*yfts)
legend('Trottinette Test','By Strejc')
title('Tranfer function by Strejc')
xlabel('Time (seconds)');ylabel('Amplitude');
%% Bode test
bode(TFs);
%% "Methode Frequentielle"
Phase = 80; % We don't want overtaking
PhaseProcess= -180 +Phase -50;
w=1.46; % We find this value for the target pusaltion
A=6.77; % And this value for the amplitude to rectify
[TFs_Freq_I,TFs_Freq_D,K_FS,Ti_FS,Td_FS]=MethFreq(w,A); % Function for "Methode Frequentielle"
ReguS=K_FS*((Ti_FS*p+1)/(Ti_FS*p))*(Td_FS*p+1); % FT for serie PID
K_FS_Para=K_FS*(Ti_FS+Td_FS)/Ti_FS;
Ti_FS_Para=Ti_FS+Td_FS;
Td_FS_Para=(Ti_FS*Td_FS)/(Ti_FS+Td_FS);
%% FT "Methode Frequentielle"
ReguP=K_FS_Para*(1 + 1/(Ti_FS_Para*p)+ Td_FS_Para*p);
TF_OL= series(TFs, ReguP);
bode(TF_OL);
%% Step "Methode Frequentielle"
TF_Strejc=feedback(TF_OL,1);
step(TF_Strejc) % Response for "Methode Frequentielle" FT
%% Test "Methode ZNBO"
Tu=0.916;   % Found with the inflection point
Ta=1.754;   % Found with the inflection point
K_ZNBO=0.2*1.27*(Ta/(Tu*KF));
Ti_ZNBO=0.624*2*Tu;
Td_ZNBO=0*0.5*Tu;
%% FT "Methode ZNBO"
TF_OL= series(TFs, K_ZNBO*(1 + 1/(Ti_ZNBO*p)+ Td_ZNBO*p));
bode(TF_OL);
%% Step "Methode ZNBO"
TF=feedback(TF_OL,1);
step(TF)
%% Test "Methode de Base"
bode(TFs)
w=4;    % We find this value for the target pusaltion
Ti=11.43/w;
Ti=Ti*0.4;    % Better result with 0.4*Ti
Td=1/(w*sqrt(0.1));
Td=Td*0;    % Better result without Td
bode(((Ti*p+1)/(Ti*p))*(Td*p+1)*TFs);
A=18;   % Value for the amplitude to rectify
K=10^(-A/20);
K=K*0.97;   % Better result with 0.95*K
%% FT et step "Methode de Base"
FT_Process=K*((Ti*p+1)/(Ti*p))*(Td*p+1);
bode(K*((Ti*p+1)/(Ti*p))*(Td*p+1)*TFs);
TF=feedback(K*(1 + 1/(Ti*p)+ Td*p)*TFs,1);
step(TF)
%% Sampling period
Te1=0.35*(1/w);
Te2=0.7*(1/w);
Te=(Te1+Te2)/2; % Calcul échantillonnage
Te=0.25;
%% Numérisation du process
G_Z=c2d(TFs,Te,'zoh');
C_Z=c2d(K*(1+1/(Ti*p) + Td*p),Te,'tustin');
FTBO_Z=G_Z*C_Z;
FTBF_Z=feedback(FTBO_Z,1);
step(FTBF_Z)
%% Comparison
step(TFs)
%% For Simulink
[N_TFs,D_TFs]=tfdata(TFs,'v');
N=10;
Te=0.25;