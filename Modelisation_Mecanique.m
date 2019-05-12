%% Identification de a et b

%%
% Ce code provient de l'étude mécanique d'une trotinnette à moteur BLDC,
% il permet de déterminer le coefficient dynamique de frottement ainsi que 
% le coefficient de trainée de l'air. Il permet également d'afficher
% certaines caractéristiques de la trottinette à l'aide de graphique. 
% Ce code sera sujet à des modifications si il est utilisé pour un autre
% projet.

%% Données initiales
clear all 
Mtot=67.5;                              % (kg)
g=9.81;                                 % (m/s²)
pente=0;                                % (degré)
rho=1.204;                              % (kg/m³)
hauteur=1.85;                           % (m)
poids=60;                               % (kg)
S=sqrt((hauteur*poids)/36);             % (m²)
%% Affichage de la vitesse en fonction du temps
[num, txt, tab] = xlsread('Test_Meca.xlsx') % Import des valeurs mesurées
Te=num(2,2)- num(1,2)                       % Calcul de la période d'échantillonnage 
t=(0:Te:12.75)';
v=num(:,1)/3.6;
figure(1)
plot(t,v)
title('Speed as a function of time');
xlabel('Time (seconds)');ylabel('Speed (m/s)');
%% Calcul de l'accélération et de la force résistante
dv = diff(v,1)/Te;  % On fait la dérivé de la vitesse pour avoir l'accélération
figure(2)
plot(t(1:51),dv);
title('Acceleration as a function of time');
xlabel('Time (seconds)');ylabel('a (m/s²)');
Fr = -Mtot*dv;      % Calcul de la force résistante 
csvwrite('A_B.txt',Fr);
figure(3)
plot(t(1:51),Fr);
title('Force as a function of time');
xlabel('Time (seconds)');ylabel('Force (N)');
%% Affichage de la force résistante en fonction de la vitesse
figure(4)
plot(v(1:51),Fr)
title('Force as a function of speed');
xlabel('Speed (m/s)');ylabel('Force (N)');
%% Calcul de la moyenne pour trouver a et b
% La premiere etape se base sur la détermination des valeurs de a et b. 
% Cela permettra de valider le modele et donc la méthode d'identification 
% des elements.

% En se basant sur le graphique représentant la force résistante a
% l'avancement (Fr) sur la vitesse (V) en m/s.

% Formule de reference: Fr= a*M + b*V^2;

% Les premiers couples de points : (Fr,V) == (24.07,0) et (26.41,2.5) -->a= 0,357 b=0,37 
% Le second couples de points : (Fr,V) ==(29.16,5) et (32.31,7.5) -->a=0.395  b=0.11
% Le troisieme couples de points : (Fr,V) ==(26.41,2.5) et (29.16,5) -->a=0.377  b=0.15


A = [0.357; 0.395 ; 0.377];
B = [0.37,0.11,0.15];
a=mean(A);  % calcul la moyenne
b=mean(B);
%% Modèle Fr et Pr
V=linspace(0,8);                        % (m/s)
Fr=a*Mtot+b*V.^2;                       % (N)
Pr=a*Mtot*V+b*V.^3;                     % (W)
figure(5)
plot(V,Fr)                              % Affichage
legend('Fr')
title('Force de résistance en fonction de la vitesse')
xlabel('Vitesse (m/s)');ylabel('Fr (N)');
figure(6)
plot(V,Pr)                              % Affichage
legend('Pr')
title('Puissance résistance en fonction de la vitesse')
xlabel('Vitesse (m/s)');ylabel('Pr (W)');
%% Calcul de Cr et Cx
uc=(a-g*sind(pente))/(g*cosd(pente));   % (/)
Cx=b/(0.5*rho*S/2);                     % (/)
%% Calcul de la puissance et couple
[num1, txt, tab] = xlsread('Test_Meca.xlsx') % Import des valeurs mesurées
Te1=num1(5,14)- num1(4,14)                       % Calcul de la période d'échantillonnage 
t1=(0:Te:31.5)';
v1=num1(:,13)/3.6;
figure(7)
plot(t1,v1)
title('Speed as a function of time');
xlabel('Time (seconds)');ylabel('Speed (m/s)');
dv1 = diff(v1,1)/Te1;  % On fait la dérivé de la vitesse pour avoir l'accélération
figure(8)
plot(t1(1:126),dv1);
title('Acceleration as a function of time');
xlabel('Time (seconds)');ylabel('a (m/s²)');
Pr1 = Mtot*dv1.*v1(1:126);
figure(9)
plot(t1(1:126),Pr1);
title('Power as a function of time');
xlabel('Time (seconds)');ylabel('Power (W)');
Cr1=Pr1./(v1(1:126)./3.6)*0.07;
figure(10)
plot(t1(1:126),Cr1);
title('Torque as a function of time');
xlabel('Time (seconds)');ylabel('Torque (N/m)');
