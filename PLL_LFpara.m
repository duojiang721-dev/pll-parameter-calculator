clear;close all;clc;
%环路滤波器参数定义
% C1 = 100e-9;
% C2 = 1e-6;
% C3 = 0;
% R2 = 51e3;
% R3 = 0;

C1 = 47e-9;
C2 = 4.7e-6;
C3 = 10e-9;
R2 = 18e3;
R3 = 2.2e3;

% C1 = 680e-9;
% R2 = 1.8e3;
% C2 = 22e-6;
% R3 = 2.2e3;
% C3 = 47e-9;
% % R4 = 1.5e3;
% % C4 = 1.5e-9;
% % R5 = 10e3;
% % C5 = 100e-9;

% C1 = 1e-9;
% R2 = 240e3;
% C2 = 6.8e-9;

% C2_change = 1;
% C2 = C2*C2_change;

f_ref = 10e6;
f_VCO = 100e6;
Kvco = 0.4e-6;

Icp_max = 6.4e-3;
Icp_div = 1;
Icp = Icp_max/Icp_div;

R = 8;
f_Realref = f_ref/R;
N = f_VCO/f_Realref;
if mod(N, 1) ~= 0
    error('错误：N必须是整数！程序已停止。');
end








