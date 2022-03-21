function codebook = audioTrainSequence(codebook,speakerIndex)

k = 16;

for

for recordIndex = 1:size(audioVoice,2)
    audioVoiceSeg = audioVoice{recordIndex} / max(abs(audioVoice{recordIndex}));
    mfccCoe = mfccCoefExtract(audioVoiceSeg,44100); %计算MFCC提取特征特征返回值是Mel倒谱系数,是一个log的DCT得到的
    codebook{speakerIndex,recordIndex} = vqCodebookGenerate(mfccCoe, k); %训练VQ码本,通过矢量量化,得到原说话人的VQ码本
end

end