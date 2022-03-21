function codebook = vqCodebookGenerate(d, k)

e = 0.01; % 分裂参数,阈值
codebook = mean(d, 2);
D_prev = 10000;

for i = 1:log2(k)
    codebook = [codebook*(1+e) codebook*(1-e)]; % 形成2m个码字
    
    while (true)
        % dist = eucDistance(d, codebook);
        [idle,index] = min(eucDistance(d, codebook), [], 2);
        D_cur = 0;
        for j = 1:2^i
            codebook(:, j) = mean(d(:, find(index == j)), 2);
            tempDist = eucDistance(d(:, find(index == j)), codebook(:, j));
%             for k = 1:length(x)
%                 D_cur = D_cur + x(k);
%             end
            D_cur = D_cur + sum(tempDist);
        end
        
        if (D_prev - D_cur)/D_cur < e
            break;
        else
            D_prev = D_cur;
        end
    end
end

end
