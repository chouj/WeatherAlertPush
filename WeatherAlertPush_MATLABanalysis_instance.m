% WeatherAlertPush script for Thingspeak MATLAB Analysis
% https://github.com/chouj/WeatherAlertPush
% powered by Thingspeak/MATLAB/Pushbear/Telegram/IFTTT
%
%    ��Thingspeakÿ10��������һ��MATLAB�ű���ͨ��������ʽץȡ���µĳ���Ԥ����Ϣ��
%    ������Ŀ����򣨴�����������Ϊ�������򽫸���Ϣͨ��Pushbear������΢�Ź��ںţ���
%    ͨ��IFTTT������Telegram������������Ϣ�ķ���ʱ���¼��Thingspeak Channel������
%    ���Ƿ������͡�


% Thingspeak channel
ReadAPIKey='yours';
WriteAPIKey='yours';
ID=yours;

% Pushbear sendkey
sendKey='yours';

% API���÷����趨Ϊpost
% Pushbear��
options = weboptions('RequestMethod','post','Timeout',60);
% webhooks of IFTTT�� ����������ֻTelegram����ȡ����һ�е�ע�ͣ�
% optionsTG = weboptions('RequestMethod','post', 'MediaType','application/json');

% ����ͻ���¼�Ԥ����Ϣ������
yujing=urlread('http://www.12379.cn/data/alarm_list_all.html','TimeOut',60);

% ������ʽץȡ
description=regexp(yujing,'{"description":"(.*?)","headline"','tokens');
headline=regexp(yujing,'"headline":"(.*?)","identifier"','tokens');
sendtime=regexp(yujing,'"sendTime":"(.*?)"}','tokens');
% identifier=regexp(yujing,'","identifier":"(.*?)","sendTime','tokens');

% ��sendTimeת��Ϊ��д��Thingspeak channel��datetime����timestamp
for i=1:length(sendtime)
     tStamps(i) = datetime(cell2mat(sendtime{i}), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
end

% ��headline��ȡ������
% ע�⣺temp(1:3)ֻ�����������ֵ����У���XX�С�XX�ء�XX����
for i=1:length(headline)
    temp=headline{i};
    temp=temp{1};
    city{i}=temp(1:3);
end

% Ŀ�����ʶ����Ԥ����Ϣ����
clear n datav datat
n=find(strcmp('������',city)==1); %Ŀ�����Ԥ����Ϣ��Ŀʶ��
if length(n)>0
        % ��ȡThingspeak Channel field 1 �����ڵļ�¼��datav��field
        % 1����ֵ��datat�Ǹ���ֵ��timestamp��
        try
            [datav,datat] = thingSpeakRead(ID,'Fields',1,'NumDays',3,'ReadKey',ReadAPIKey,'Timeout',60);
        catch
            pause(30);[datav,datat] = thingSpeakRead(ID,'Fields',1,'NumDays',3,'ReadKey',ReadAPIKey,'Timeout',60);
        end
        if isempty(datat)==1 % ���δ��ȡ���κ����ݣ���ʾChannel�½�����δ�����ݼ�¼������Ϣ���ͳ�ȥ��
            try 
                % ����Pushbear������΢�Ź��ں�
                response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
                % ���Ҫ����IFTTT������Telegram���뽫����pushbear��API�����滻Ϊȡ��ע�͵���һ�У���
                % response = webwrite('https://maker.ifttt.com/trigger/{your_event_name}/with/key/{your_ifttt_webhooks_key}', 'value1',cell2mat(headline{n(i)}),'value2',cell2mat(description{n(i)}), optionsTG);
            catch
                pause(30);
                response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
            end
            try
                % ����n���ܴ���1������n(1)�����µ�Ԥ����Ϣ����������Ϣ�ķ���ʱ��д��Thingspeak
                % channel��fields1��ֵ��Ϊ1��
                responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
            catch
                pause(30);
                responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
            end
        else % ���datat�м�¼
            if eq(datat(max(find(datav==1))),tStamps(n(1)))==0 %���һ��Thingspeak Channel��¼��timestamp��������һ��ʶ��Ԥ����Ϣ�ķ���ʱ�䲻ͬ�������������Ԥ����Ϣδ��������
                try 
                    response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
                catch
                    pause(30);
                    response = webwrite('https://pushbear.ftqq.com/sub', 'sendkey',sendKey,'text',cell2mat(headline{n(1)}), 'desp',cell2mat(description{n(1)}),options);
                end
                try
                    % ���ͺ󽫸�����Ϣ�ķ���ʱ��д��Thingspeak channel��fields1��ֵ��Ϊ1��
                    responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
                catch
                    pause(30);
                    responsew=thingSpeakWrite(ID,1, 'Fields', 1,'TimeStamp',tStamps(n(1)),'WriteKey', WriteAPIKey,'Timeout',60);
                end
            end
        end
end