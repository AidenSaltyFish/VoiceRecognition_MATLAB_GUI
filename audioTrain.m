function codebook = audioTrain(speaker_names, maxAudioIndex)

k = 16;

for i = 1:length(speaker_names)
    for	j = 1:maxAudioIndex %对数据库中代码形成码本
        filename = strcat(speaker_names{i},'_',num2str(j-1),'.wav');
        disp(filename);
        [audio,	fs]	= audioread(filename);
        audioVoice = audioRecordSegmentSingle(audio);
        audioVoice = audioVoice / max(abs(audioVoice));
        mfccCoe = mfccCoefExtract(audioVoice,fs); %计算MFCC提取特征特征返回值是Mel倒谱系数,是一个log的DCT得到的
        codebook{i,j} = vqCodebookGenerate(mfccCoe, k); %训练VQ码本,通过矢量量化,得到原说话人的VQ码本
    end
end

end