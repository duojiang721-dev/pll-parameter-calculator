clear;close all;
% 1. 定义我们已经算好的物理参数
Icp = 0.005;                % 电荷泵电流 5mA
Kv_Hz = 2;                  % 压控灵敏度 2 Hz/V
Kv_rad = Kv_Hz * 2 * pi;    % 转换为角频率
N = 8;                      % 分频比
Kd = Icp / (2*pi);          % 鉴相增益

% 2. 构建拉普拉斯传递函数
s = tf('s');
% 这正是我们算好的 56kΩ, 1.0μF, 82nF 阻容网络
Z = (0.056*s + 1) / (4.592e-9*s^2 + 1.082e-6*s); 

% 开环增益
G = Kd * Z * (Kv_rad / s);

% 3. 提取两大核心噪声传递函数
% 参考源噪声传递函数 (呈现低通特性)
H_ref = N * ( (G/N) / (1 + G/N) );

% VCO 固有噪声传递函数 (呈现高通特性)
H_vco = 1 / (1 + G/N);

% 4. 绘制相位噪声频谱整形曲线 (Bode 图)
figure;
opts = bodeoptions('cstprefs');
opts.FreqUnits = 'Hz';      % 将横坐标设置为 Hz 以便查看相噪
opts.PhaseVisible = 'off';  % 只看幅值（dB），不看相位
bode(H_ref, 'b', H_vco, 'r', opts);
grid on;
title('PLL 噪声传递特性');
legend('参考源噪声传递 (低通)', 'VCO 固有噪声传递 (高通)');

