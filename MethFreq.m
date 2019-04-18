function [TF_I,TF_D,K,Ti,Td] = MethFreq(w,A)
p=tf([1,0],[1]);
alpha=0.1;
Ti=11.43/w;
Td=(1/((sqrt(alpha))*w));
K=(10^(-A/20))/(Td*w);
TF_I=(Ti*p+1)/(Ti*p);
TF_D=(Td*p+1)/(Td*alpha*p+1);
end