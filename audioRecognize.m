function voice2str = audioRecognize(audioRecordData,codebook)

audioVoice = audioRecordSegment(audioRecordData,9);
thresholdDistance = 6; %阈值设置处

speakerIndex = 0;
voice2str = '';

audioSeg = audioVoice{1,1} / max(abs(audioVoice{1,1}));
mfccCoe = mfccCoefExtract(audioSeg,48000); %得到测试人语音的Mel倒谱系数
isSpeakerFound = false;
while(~isSpeakerFound && speakerIndex < size(codebook,1))
    speakerIndex = speakerIndex + 1;
    for templateIndex = 1:size(codebook,2)	% read test sound file of each speaker
        d = eucDistance(mfccCoe,codebook{speakerIndex,templateIndex}); %计算得到模板和要判断的声音之间的"距离"
        distance = sum(min(d,[],2))/size(d,1); %变换得到一个距离的量
        
        %测试阈值数量级
        fprintf('与模板语音信号的差值为:%f\n',distance) ;
        
        if distance <= thresholdDistance %一个阈值,小于阈值就是这个人
            % match
            voice2str = strcat(voice2str,num2str(templateIndex-1));
            isSpeakerFound = true;
            break;
        end
    end
end

if isSpeakerFound == false % dismatch
    fprintf('无此人哦!\n');
end

if (size(audioVoice,2) > 1 && isSpeakerFound == true)
    for recordIndex = 2:size(audioVoice,2)
        audioSeg = audioVoice{1,recordIndex} / max(abs(audioVoice{1,recordIndex}));
        mfccCoe = mfccCoefExtract(audioSeg,44100); %得到测试人语音的Mel倒谱系数
        for templateIndex = 1:size(codebook,2)	% read test sound file of each speaker
            d = eucDistance(mfccCoe,codebook{speakerIndex,templateIndex}); %计算得到模板和要判断的声音之间的"距离"
            distance = sum(min(d,[],2))/size(d,1); %变换得到一个距离的量
            
            %测试阈值数量级
            fprintf('与模板语音信号的差值为:%10f\n',distance) ;
            
            if distance <= thresholdDistance %一个阈值,小于阈值就是这个人
                % match
                voice2str = strcat(voice2str,num2str(templateIndex-1));
                break;
            end
        end
    end
end

end