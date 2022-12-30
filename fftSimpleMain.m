clc
clear
close all

path_1 = 'D:\data2\电梯振动数据\4.1\' ;   % 文件所在的文件夹 
% C:\Users\Administrator\Desktop\2   D:\data2\电梯振动数据\4.1\
filesTemp1=dir([path_1,'*.wav']);%指定读取wav文件
filesTemp2=dir([path_1,'*.txt']);%指定读取txt文件
if isempty(filesTemp1)
    files = filesTemp2;
else
    files = filesTemp1;
end

fileLen = length(files);
fileName = cell(fileLen,1);

minEnvelope = 1000; % 包络的低频列表.[200,1000,2000]
maxEnvelope = 3000;

if fileLen == 0
    disp("路径错误或文件夹为空。")
    return
end

for file_i = 1:fileLen
    path_2 = files(file_i).name;
    if isempty(filesTemp1)
        % 读取txt用
        y_ = load([path_1,path_2]);
        fs = 12800;
    else
        % 读取wav用
        [audio,fs] = audioread([path_1,path_2]);
        y_ = audio(:,1);
    end

    fprintf('数据总长：%.2f 秒\n',(length(y_)/fs))

    yy = y_;
    yy=detrend(yy);

    NN = length(yy);
    N = length(yy);
    En_sig = figure();
    set(En_sig, 'position', get(0,'ScreenSize'));
    
    subplot(3,1,1)
    t = (1:length(yy))*(1/fs);
    plot(t,yy)
    title(sprintf("时域波形图： %s",path_2),'Interpreter','none')
    xlabel('时间(s)')
    ylabel('幅值')
    axis tight
    grid on 

    subplot(3,1,2)
    hold on
    
    [f,fa]=fftSimplePack.singleSideFft(yy,fs); 
    faLessThanTwo=floor(2/(fs/2)*length(fa));
    fa(1:faLessThanTwo) = 0; % 将小于2Hz的幅值置零
    plot(f,fa)
    xlim([2 6400])
    title("频谱图",'FontSize',13)
    grid on

    ylabel("幅值",'FontSize',13)
    xlabel("频率(Hz)",'FontSize',13)

%     justFftPack.myFindPeak(fa,f,20)
    justFftPack.myFindPeak(fa,f,20);
    hold off
    

    [ff2,hfa,~] = justFftPack.myHilbertFunction(yy,minEnvelope,maxEnvelope,fs);
    hfa(1:faLessThanTwo)=0; % 将小于2Hz的幅值置零
    subplot(3,1,3)
    hold on
    plot(ff2,hfa)
    xlim([2 2000])
    %     title('原始包络解调谱')
    title({sprintf('包络解调谱， 包络频率范围：%d -- %d Hz',...
        minEnvelope,maxEnvelope)},'FontSize',13)
    grid on
    justFftPack.myFindPeak(hfa,ff2,10);
    ylabel("幅值",'FontSize',13)
    xlabel("频率(Hz)",'FontSize',13)

    hold off

    keyboard
    %     pause(0.1)
    %     close(En_sig)
    close all


end








