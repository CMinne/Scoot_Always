%% Identification de a et b

%%
% Ce code provient de l'�tude m�canique d'une trotinnette � moteur BLDC,
% il permet de d�terminer le coefficient dynamique de frottement ainsi que 
% le coefficient de train�e de l'air. Il permet �galement d'afficher
% certaines caract�ristiques de la trottinette � l'aide de graphique. 
% Ce code sera sujet � des modifications si il est utilis� pour un autre
% projet.

%% Donn�es initiales
clear all 
Mtot=110;                               % (kg)
g=9.81;                                 % (m/s�)
pente=0;                                % (degr�)
rho=1.204;                              % (kg/m�)
hauteur=0.65;                           % (m)
poids=75;                               % (kg)
%% Calcul de l'acc�l�ration (dv)
[num, txt, tab] = xlsread('test25.xlsx')
Te=num(2,2)- num(1,2)
x = 0:0.25:27;
v1=0.0007*x.^3 - 0.0328*x.^2 + 0.1344*x + 6.9002;
v1=v1'/3.6;
v2=num(:,6)/3.6;
figure(1)
plot(num(:,2),v2,x,v1)
%%
dv1 = diff(v1,1)/Te % on fait la d�rive de la vitesse pour avoir l'acceleration
dv2 = diff(v2,1)/Te % on fait la d�rive de la vitesse pour avoir l'acceleration
% la p�riode est prise 
Fr_exp1 = -Mtot*dv1; % formule du livre w
Fr_exp2 = -Mtot*dv2; % formule du livre w
y = linspace(0,27,135);
figure(2)
plot(y,Fr_exp1);
%%
figure(3)
v = v1;
plot(v(1:135),Fr_exp1)
%% Calcul de la moyenne pour trouver a et b
% La premiere etape se base sur la d�termination des valeurs de a et b. 
% Cela permettra de valider le modele et donc la m�thode d'identification 
% des elements.

% En se basant sur le graphique repr�sentant la force r�sistante a
% l'avancement (Fr) sur la vitesse (V) en m/s.

% Le a vaut = 0,16 et b= 0,4

% Les premiers couples de points : (Fr,V) == (22.5,0) et (25,2.5) -->a= 0,21 b=0,4 
% Le second couples de points : (Fr,V) ==(25,2.5) et (30,4.3) -->a=0.2098  b=0.4085
% Le troisieme couples de points : (Fr,V) ==(37.5,6) et (32.5,5) -->a=0.1975  b=0.45


clear all
close all
clc

syms a b
[Sa,Sb] = solve(a*107 + (b*((5)^2)) == 32.5, a*107 + (b*(6^2)) == 37.5)

A = [0.21; 0.2098 ; 0.1975];
mean(A) % calcul la moyenne
%%

%Identification de a et b

clear all
close all
clc
% masse est de 110
% formule de reference: Fr= a*M + b*V^2;

%(Fr,V) == (9.8,4.5) et (19,6) -->a=-71/3850  b= 184/315
%(Fr,V) == (23,7) et (30,9) -->a= 393/3520  b= 7/32
%(Fr,V) == (33,10) et (40,12.5) -->a=37/198  b= 28/225
%(Fr,V) == (44,15) et (48,17) -->a=479/1760  b= 1/16
%(Fr,V) == (26,8) et (36,11) -->a=421/3135  b= 10/57

Mtot=110;                               % (kg)
g=9.81;                                 % (m/s�)
pente=0;                                % (degr�)
rho=1.204;                              % (kg/m�)
hauteur=0.65;                            % (m)
poids=75;                               % (kg)

syms a b
[Sa,Sb] = solve(a*110 + (b*((8)^2)) == 26, a*110 + (b*(11^2)) == 36)

A = [-71/3850; 393/3520 ; 37/198; 479/1760; 421/3135];
B= [184/315; 7/32; 28/225; 1/16; 10/57]
a =mean(A) % calcul la moyenne
b= mean(B)
%% Mod�le Fr et Pr
V=linspace(0,20);                       % (m/s)
Fr=a*Mtot+b*V.^2;                       % (N)
Pr=a*Mtot*V+b*V.^3;                     % (W)
figure(1)
plot(V,Fr)                              % Affichage
legend('Fr')
title('Force de r�sistance en fonction de la vitesse')
xlabel('Vitesse (m/s)');ylabel('Fr (N)');
figure(2)
plot(V,Pr)                              % Affichage
legend('Pr')
title('Puissance r�sistance en fonction de la vitesse')
xlabel('Vitesse (m/s)');ylabel('Pr (W)');
%% Calcul de uc et Cx
%S=sqrt((hauteur *poids)/36);              % (m�) , formule de la surface de la voiture 
%uc=(a-g*sind(pente))/(g*cosd(pente))  % (/)
%Cx=b/(0.5*rho*S)                       % (/)
%% calcul de Cr et Cx
%a=Mtot*g*Cr;
syms Cr
eqn =Mtot*g*Cr == a;
slox = solve(eqn,Cr)