function c = PLL_OpenLoop_Constraint(G_open)
% PLL_OpenLoop_Constraint: 同时限制相位裕度和穿越频率(fc)
%
% 输入: G_open - 系统的开环传递函数
% 输出: c - 不等式约束数组 (优化器要求所有 c <= 0)

    % 1. 计算裕度参数
    % Pm: 相位裕度 (度)
    % Wcp: 增益穿越频率 (单位是 rad/s，即角频率)
    [Gm, Pm, Wcg, Wcp] = margin(G_open);
    
    % 异常处理（防止初期参数离谱导致报错）
    if isempty(Pm) || isnan(Pm) || isinf(Pm) || isempty(Wcp)
        c = [1000; 1000; 1000]; % 返回极大惩罚值
        return;
    end
    
    % 2. 将角频率 Wcp 转换为实际频率 fc (Hz)
    fc = Wcp / (2 * pi);
    
    % ================= 设置你的目标参数 =================
    max_PM = 75;         % 最大允许相位裕度 (度)
    
    min_fc = 1000;       % 最小穿越频率 (Hz) -> 比如 1 kHz
    max_fc = 5000;       % 最大穿越频率 (Hz) -> 比如 5 kHz
    % ====================================================
    
    % 3. 构建约束条件 (形式必须为: 实际值 - 目标上限 <= 0)
    
    % 约束 A: Pm <= 75  =>  Pm - 75 <= 0
    c1 = Pm - max_PM;
    
    % 约束 B: fc <= 5000  =>  fc - 5000 <= 0
    c2 = fc - max_fc;
    
    % 约束 C: fc >= 1000  =>  1000 - fc <= 0
    c3 = min_fc - fc;
    
    % 4. 输出约束数组
    c = [c1; c2; c3]; 
end