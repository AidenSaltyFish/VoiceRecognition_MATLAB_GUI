clear,clc,close all;
speaker_names = {'ZhanmingXiao','HaotianLi'};
% speaker_name = {'ZhanmingXiao'};
% speaker_names_chinese ={};
codebook = audioTrain(speaker_names,10);
% [codebook, speaker_names] = audioTrainSingle(speaker_name{1}, speaker_names, 9, codebook);
% disp(speaker_names);
% audio = audioread('150250230.wav');
isSpeakerMatch(speaker_names,'HaotianLi',1,codebook);
% audioRecordSegment(audioread('ZhanmingXiao_total.wav'));
% audio = audioread('150250230.wav');
% fil = fir1(128,0.1417);
% audio_filtered = filter(fil,1,audio);

% AP = audioplayer(audio_filtered,48000);
% play(AP);

% codebook = audioRecordTrain(audio_filtered,codebook,2);
% voice2str = audioRecognize(audio_filtered,codebook);

% plot(fftshift(abs(fft(audioread('ZhanmingXiao_total.wav')))));
% figure
% plot(fftshift(abs(fft(audioread('150250230.wav')))));
% plot(fftshift(abs(fft(audio_filtered))));
% plot(fftshift(abs(fft(audioread('KeweiDu_total.wav')))));