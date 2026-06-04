function vals = myCustomRequirement(data)
    % 1. 从 MATLAB 主工作区读取静态参数
    % 如果你的设计变量里没有勾选它们，优化器就会用这里的固定值
    C1 = evalin('base', 'C1');
    R2 = evalin('base', 'R2');
    C2 = evalin('base', 'C2');
    R3 = evalin('base', 'R3');
    C3 = evalin('base', 'C3');
    
    Icp   = evalin('base', 'Icp');
    Kvco  = evalin('base', 'Kvco');
    f_VCO = evalin('base', 'f_VCO');
    N     = evalin('base', 'N');

    % 2. 覆盖正在优化的设计变量
    % 如果你在 Simulink 优化器里勾选了 R2 和 C1 等作为优化变量，
    % 这里会用优化器当前试探的值去覆盖掉上面从工作区读取的值。
    vars = data.DesignVars;
    for i = 1:length(vars)
        switch vars(i).Name
            case 'R2'
                R2 = vars(i).Value;
            case 'C1'
                C1 = vars(i).Value;
            case 'C2'
                C2 = vars(i).Value;
            case 'R3'
                R3 = vars(i).Value;
            case 'C3'
                C3 = vars(i).Value;
        end
    end

    % 3. 处理 VCO 灵敏度单位 (极其关键)
    % 你定义的 Kvco = 2e-6/5 = 4e-7，这是归一化比例 (ppm/V)
    % 在传递函数中，我们需要的 Kvco_Hz 单位是 Hz/V，必须乘以载波频率
    if Kvco < 1 
        Kvco_Hz = Kvco * f_VCO; 
    else
        Kvco_Hz = Kvco;
    end

    % 4. 计算前向总增益系数 K 
    K = (Icp * Kvco_Hz) / N;

    % 5. 构建三阶环路滤波器的传递函数 Z(s)
    s = tf('s');
    
    % 分子：1 + s*R2*C2
    num_Z = 1 + s * R2 * C2;
    
    % 分母系数：A2*s^3 + A1*s^2 + A0*s
    A0 = C1 + C2 + C3;
    A1 = C2 * R2 * (C1 + C3) + C3 * R3 * (C1 + C2);
    A2 = C1 * C2 * C3 * R2 * R3;
    
    den_Z = A2 * s^3 + A1 * s^2 + A0 * s;
    
    Z = num_Z / den_Z;

    % 6. 开环传递函数 Hol(s) = K/s * Z(s)
    Hol = (K / s) * Z;

    % 7. 计算相位裕度
    [~, pm, ~, ~] = margin(Hol);
    
    % 防错处理：如果系统极度不稳定导致 margin 算不出数值，给一个极大的惩罚值
    if isempty(pm) || isnan(pm)
        pm = -100; % 设为负数，确保误差极大
    end

    % 8. 设定目标约束公式 (限定相位裕度 <= 55度)
    % 当 pm > 55 时，vals > 0，优化器判定违规，会自动调整参数
    vals = (pm - 70)*2; 
end