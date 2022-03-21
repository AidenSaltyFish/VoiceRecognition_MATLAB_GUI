function [isFound,speaker] = isSpeakerMatch(speaker_names,tester_name, n, codebook)

s = audioRecordSegmentSingle(audioread(strcat(tester_name,'_',num2str(n),'.wav')));
s = s / max(abs(s));
mfccCoe = mfccCoefExtract(s,48000); %得到测试人语音的Mel倒谱系数
thresholdDistance = 4; %阈值设置处

% assignin('base','mfccCoe',mfccCoe);

speakerIndex = 0;
isFound = false;
while(~isFound && speakerIndex < size(codebook,1))
    speakerIndex = speakerIndex+1;
    
    for templateIndex = 1:size(codebook,2)	% read test sound file of each speaker
        d = eucDistance(mfccCoe,codebook{speakerIndex,templateIndex}); %计算得到模板和要判断的声音之间的"距离"
        distance = sum(min(d,[],2))/size(d,1); %变换得到一个距离的量
        
        %测试阈值数量级
        fprintf('与模板语音信号的差值为:%10f\n',distance) ;
        
        if distance <= thresholdDistance %一个阈值,小于阈值就是这个人
            % match
            fprintf('与第%d位说话者的第%d个模板语音信号匹配,符合要求!\n',speakerIndex,templateIndex); %界面显示语句,可随意设定
            isFound = true; 
            break;
        else
            % dismatch
            fprintf('与第%d位说话者的第%d个模板语音信号不匹配,不符合要求!\n',speakerIndex,templateIndex); %界面显示语句,可随意设定
        end
    end
end

if isFound
    speaker = speaker_names{speakerIndex};
    fprintf('说话者是%s!是第%d个指令！\n',speaker,templateIndex-1);
else
    speaker = 'none';
    fprintf('无人匹配!\n');
end

end

