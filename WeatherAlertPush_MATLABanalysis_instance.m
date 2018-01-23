% WeatherAlertPush script for Thingspeak MATLAB Analysis
% https://github.com/chouj/WeatherAlertPush
% powered by Thingspeak/MATLAB/Pushbear/Telegram/IFTTT
%
%    于Thingspeak每10分钟运行一次MATLAB脚本，通过正则表达式抓取最新的城镇预警信息；
%    若存在目标城镇（代码中以襄阳为例），则将该信息通过Pushbear推送至微信公众号（或
%    通过IFTTT推送至Telegram），并将该信息的发布时间记录于Thingspeak Channel用以判
%    别是否已推送。


% Thingspeak channel
ReadAPIKey='{yours}';
WriteAPIKey='{yours}';
ID={yours};

% Pushbear sendkey
sendKey='{yours}';

% API调用方法设定为post
% Pushbear的
options = weboptions('RequestMethod','post','Timeout',60);
% webhooks of IFTTT的 （如欲推送至Telegram，请取消下一行的注释）
% optionsTG = weboptions('RequestMethod','post', 'MediaType','application/json');

% 国家突发事件预警信息发布网
yujing=urlread('http://www.12379.cn/data/alarm_list_all.html','TimeOut',60);

% 正则表达式抓取
description=regexp(yujing,'{"description":"(.*?)","headline"','tokens');
headline=regexp(yujing,'"headline":"(.*?)","identifier"','tokens');
sendtime=regexp(yujing,'"sendTime":"(.*?)"}','tokens');
% identifier=regexp(yujing,'","identifier":"(.*?)","sendTime','tokens');

% 将sendTime转化为待写入Thingspeak channel的datetime类型timestamp
for i=1:length(sendtime)
     tStamps(i) = datetime(cell2mat(sendtime{i}), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
end

% 从headline提取县市名
% 注意：temp(1:3)只适用于两个字的县市，如XX市、XX县、XX区！！
for i=1:length(headline)
    temp=headline{i};
    temp=temp{1};
    city{i}=temp(1:3);
end

% 目标县市识别与预警信息推送
clear n datav datat
n=find(strcmp('襄阳市',city)==1); %目标县市预警信息条目识别
if length(n)>0
        % 读取Thingspeak Channel field 1 三天内的记录，datav是field1的数值，datat是该数值的timestamp。
        try
            [datav,datat] = thingSpeakRead(ID,'Fields',1,'NumDays',3,'ReadKey',ReadAPIKey,'Timeout',60);
        catch
            pause(30);[datav,datat] = thingSpeakRead(ID,'Fields',1,'NumDays',3,'ReadKey',ReadAPIKey,'Timeout',60);
        end
        if isempty(datat)==1 % 如果未读取到任何数据，表示Channel新建、尚未有数据记录，将消息推送出去。
            try 
                % 借助Pushbear推送至微信公众号
                response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
                % 如果要借助IFTTT推送至Telegram，请将所有pushbear的API调用替换为取消注释的下一行，：
                % response = webwrite('https://maker.ifttt.com/trigger/{your_event_name}/with/key/{your_ifttt_webhooks_key}', 'value1',cell2mat(headline{n(i)}),'value2',cell2mat(description{n(i)}), optionsTG);
            catch
                pause(30);
                response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
            end
            try
                % 由于n可能大于1，这里n(1)是最新的预警信息。将该条信息的发布时间写入Thingspeak
                % channel，fields1的值赋为1。
                responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
            catch
                pause(30);
                responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
            end
        else % 如果datat有记录
            if eq(datat(max(find(datav==1))),tStamps(n(1)))==0 %最近一条Thingspeak Channel记录的timestamp若与最新一条识别预警信息的发布时间不同，则表明该最新预警信息未发布过。
                try 
                    response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
                catch
                    pause(30);
                    response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
                end
                try
                    % 推送后将该条信息的发布时间写入Thingspeak channel，fields1的值赋为1。
                    responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
                catch
                    pause(30);
                    responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
                end
            end
        end
end
