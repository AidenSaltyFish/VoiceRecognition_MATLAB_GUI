fs = 44100;
nbits = 8;
audioRecord = audiorecorder(fs,nbits,2);
%创建一个保存音频信息的对象，它包含采样率，时间和录制的音频信息等等
%44100表示采样为44100Hz（可改为8000, 11025, 22050等，此数值越大，录入的声音质量越好，相应需要的存储空间越大）
%16为用16bits存储，2为两通道即立体声（也可以改为1即单声道）
record(audioRecord);
%开始录制，此时对着麦克风说话即可
pause(audioRecord);
%暂停录制
resume(audioRecord);
%继续录制
stop(audioRecord);
%停止录制
play(audioRecord);
%播放录制的声音
myspeech = getaudiodata(audioRecord);
%得到以n*2列数字矩阵存储的刚录制的音频信号