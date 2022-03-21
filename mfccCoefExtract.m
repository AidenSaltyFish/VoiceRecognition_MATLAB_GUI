function mfccCoe = mfccCoefExtract(s, fs)

numFilters = 100;
n = 256;
l = length(s);
numFrame = floor((l - n) / numFilters) + 1;   %沿-∞方向取整
numMfccCoe = 25; % MFCC系数个数通常选取20-30,这里是25

% 分帧
for i = 1:n
    for j = 1:numFrame
        frames(i, j) = s(((j - 1) * numFilters) + i);  %对矩阵M赋值
    end
end

% h = hamming(n);    %加hamming窗,以增加音框左端和右端的连续性
framesWindowed = diag(hamming(n)) * frames; %加hamming窗,以增加音框左端和右端的连续性

for i = 1:numFrame
    framesFFT(:,i) = fft(framesWindowed(:, i));  %对信号进行快速傅里叶变换FFT
end

% t = n / 2;
% tmax = l / fs;
% m = melFilter(20, n, fs); %将上述线性频谱通过Mel频率滤波器组得到Mel频谱,下面在将其转化成对数频谱

f0 = 700 / fs;
fn2 = floor(n/2);
lr = log(1 + 0.5/f0) / (numMfccCoe + 1);
% convert to fft bin numbers with 0 for DC term
bl = n * (f0 * (exp([0 1 numMfccCoe numMfccCoe+1] * lr) - 1));
% 直接转换为FFT的数字模型
bl1 = floor(bl(1)) + 1;
bl2 = ceil(bl(2));
bl3 = floor(bl(3));
bl4 = min(fn2, ceil(bl(4))) - 1;
pf = log(1 + (bl1:bl4)/n/f0) / lr;
fp = floor(pf);
pm = pf - fp;

r = [fp(bl2:bl4) 1+fp(1:bl3)];
c = [bl2:bl4 1:bl3] + 1;
v = 2 * [1-pm(bl2:bl4) pm(1:bl3)];
numFilters = sparse(r, c, v, numMfccCoe, 1+fn2);

energyFiltered = numFilters * (abs(framesFFT(1:(1+floor(n / 2)), :)).^2); % 能量谱通过mel尺度滤波器
mfccCoe = dct(log(energyFiltered));  %将上述对数频谱,经过离散余弦变换(DCT)变换到倒谱域,即可得到Mel倒谱系数(MFCC参数)

% x = bl1:bl4;
% assignin('base','x',x);

end