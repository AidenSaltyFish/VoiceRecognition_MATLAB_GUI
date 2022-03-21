clear,clc;

[audio,fs]=audioread('KeweiDu_total.wav');
audioOrigin = audio;
fil = fir1(128,0.1417);
audio = filter(fil,1,audio);

%参数设置
frameLen = 256;     %帧长
frameInc = 90;           %未重叠部分，这里涉及到信号分帧的问题
shortTermEnergyThreshold1 = 10;          %短时能量阈值
shortTermEnergyThreshold2 = 2;           %即设定能量的两个阈值。
zeroCrossRateThreshold1 = 10;          %过零率阈值
zeroCrossRateThreshold2 = 5;           %过零率的两个阈值，感觉第一个没有用到

minSilenceLen = 30;   %用无声的长度来判断语音是否结束,n*(1/44100)ms
minVoiceLen  = 60;    %判断是语音的最小长度,15*10ms = 150ms

audioSeg = {};
prefixLen = 0;

for voiceIndex=1:10
    audio = audio / max(abs(audio)); %幅度归一化到[-1,1]
    audioStatus  = 0;      %记录语音段的状态
    voiceLen   = 0;     %语音序列的长度
    silenceLen = 0;      %无声的长度
    %计算过零率
    tmp1  = enframe(audio(1:end-1),frameLen,frameInc);
    tmp2  = enframe(audio(2:end)  ,frameLen,frameInc);
    signs = (tmp1 .* tmp2) < 0;
    diffs = (tmp1 - tmp2) > 0.02;
    zeroCrossRate   = sum(signs .* diffs,2); %虽然没搞懂上边的原理，但是可以推测存的是各帧的过零率。上边计算过零率的放到后边分析，这里只要了解通过这几句得到了信号各帧的过零率值，放到zcr矩阵中。
    
    %计算短时能量
    % shortTermEnergy = sum((abs(enframe(filter([1 -0.9375], 1, audio), frameLen, frameInc))).^2, 2);%不知道这里的filter是干啥的？但的出来的是各贞的能量了。
    shortTermEnergy = sum((abs(enframe(audio,frameLen,frameInc))).^2, 2);%通过把filter给去掉，发现结果差不多，所以个人感觉没必要加一个滤波器，上边出现的enframe函数放到后边分析。这里知道是求出x各帧的能量值就行。
    
    %调整能量门限
    shortTermEnergyThreshold1 = min(shortTermEnergyThreshold1, max(shortTermEnergy)/4);
    shortTermEnergyThreshold2 = min(shortTermEnergyThreshold2, max(shortTermEnergy)/8); % min函数是求最小值的，没必要说了
    
    %开始端点检测
    for n = 1:length(zeroCrossRate) % 从这里开始才是整个程序的思路,Length（zeroCorssRate）得到的是整个信号的帧数
        % goto = 0;
        switch audioStatus
            case {0,1}                   % 0 = 静音,1 = 可能开始
                if shortTermEnergy(n) > shortTermEnergyThreshold1          % 确信进入语音段
                    voiceStart = max(n - voiceLen - 1,1); % 记录语音段的起始点
                    audioStatus  = 2;
                    silenceLen = 0;
                    voiceLen   = voiceLen + 1;
                elseif shortTermEnergy(n) > shortTermEnergyThreshold2 || zeroCrossRate(n) > zeroCrossRateThreshold2 % 可能处于语音段
                    audioStatus = 1;
                    voiceLen  = voiceLen + 1;
                else                       % 静音状态
                    audioStatus  = 0;
                    voiceLen   = 0;
                end
                
            case 2                       % 2 = 语音段
                if shortTermEnergy(n) > shortTermEnergyThreshold2 || zeroCrossRate(n) > zeroCrossRateThreshold2     % 保持在语音段
                    voiceLen = voiceLen + 1;
                else                       % 语音将结束
                    silenceLen = silenceLen + 1;
                    if silenceLen < minSilenceLen % 静音还不够长，尚未结束
                        voiceLen  = voiceLen + 1;
                    elseif voiceLen < minVoiceLen   % 语音长度太短，认为是噪声
                        audioStatus  = 0;
                        silenceLen = 0;
                        voiceLen   = 0;
                    else                    % 语音结束
                        audioStatus  = 3;
                    end
                end
                
            case 3
                break;
        end
    end
    
    voiceLen = voiceLen - silenceLen/2;
    voiceEnd = voiceStart + voiceLen - 1;              %记录语音段结束点
    
    % assignin('base','x1',x1);
    % assignin('base','x2',x2);
    
    figure
    %后边的程序是找出语音端，然后用红线给标出来，没多少技术含量，就不多说了
    subplot(3,1,1)
    plot(audio)
    axis([1 length(audio) -1 1]) %限制x轴与y轴的范围。
    ylabel('Speech');
    line([voiceStart*frameInc voiceStart*frameInc], [-1 1], 'Color', 'red');
    line([voiceEnd*frameInc voiceEnd*frameInc], [-1 1], 'Color', 'red'); %注意下line函数的用法:基于两点连成一条直线
    
    subplot(3,1,2)
    plot(shortTermEnergy);
    axis([1 length(shortTermEnergy) 0 max(shortTermEnergy)])
    ylabel('Energy');
    line([voiceStart voiceStart], [min(shortTermEnergy),max(shortTermEnergy)], 'Color', 'red');
    line([voiceEnd voiceEnd], [min(shortTermEnergy),max(shortTermEnergy)], 'Color', 'red');
    
    subplot(3,1,3)
    plot(zeroCrossRate);
    axis([1 length(zeroCrossRate) 0 max(zeroCrossRate)])
    ylabel('Zero Crossing Rate');
    line([voiceStart voiceStart], [min(zeroCrossRate),max(zeroCrossRate)], 'Color', 'red');
    line([voiceEnd voiceEnd], [min(zeroCrossRate),max(zeroCrossRate)], 'Color', 'red');
    
    audio = audio * max(abs(audio));
    audioSeg = [audioSeg audioOrigin(prefixLen + voiceStart*frameInc : prefixLen + voiceEnd*frameInc , :)];
    
    prefixLen = prefixLen + length(1:voiceEnd*frameInc);
    audio = audio(voiceEnd*frameInc:end,:);
end