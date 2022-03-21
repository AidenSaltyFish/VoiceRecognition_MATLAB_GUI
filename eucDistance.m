function distance = eucDistance(a,b)

[M1, N1] = size(a);  %音频x赋值给[M1，N]
[M2, N2] = size(b); %音频y赋值给[M2，P]

if (M1 ~= M2)
    error('音频时间不等!') %两个音频时间长度不相等
end
d = zeros(N1, N2);

if (N1 < N2) %在两个音频时间长度相等的前提下
    temp_copies = zeros(1,N2);
    for n = 1:N1
        d(n,:) = sum((a(:, n+temp_copies) - b) .^2, 1);
    end
else
    temp_copies = zeros(1,N1);
    for p = 1:N2
        d(:,p) = sum((a - b(:, p+temp_copies)) .^2, 1)';
    end %成对欧氏距离的两个矩阵的列之间的距离
end

distance = sqrt(d);

end
