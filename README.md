# 天气预警信息推送

###### powered by [Thingspeak](https://thingspeak.com)/[MATLAB](https://www.mathworks.com/products/matlab.html)/[Pushbear](https://pushbear.ftqq.com/admin/)/[Telegram](https://telegram.org)/[IFTTT](https://ifttt.com)



## 简介

- 于Thingspeak每10分钟运行一次MATLAB脚本，通过正则表达式抓取最新的城镇预警信息；
- 若存在目标城镇（代码中以襄阳为例），则将该信息通过Pushbear推送至微信公众号（或通过IFTTT推送至Telegram），并将该信息的发布时间记录于Thingspeak Channel用以判别是否已推送。



## 天气预警数据来源

[国家突发事件预警信息发布网](http://www.12379.cn/data/alarm_list_all.html)

格式：

```{"description":"天津市气象台于2018年01月21日22时28分发布天津地区道路结冰黄色预警信号：路表温度低于0 ℃，出现降水，12小时内可能出现对交通有影响的道路结冰，请有关单位和人员作好防范准备。","headline":"天津市气象局发布道路结冰黄色预警/III/较重","identifier":"12000041600000_20180121223442","sendTime":"2018-01-21 22:36:38"}```

description、headline和sendTime是需要抓取的内容。

## 设置方法及源码

#### Thingspeak Channel准备

新建Thingspeak Channel用于存储已推送信息的发布时间，1个城镇对应1个field。因1个Channel可以有8个field，故可利用一个Channel实现8个城镇的推送。以襄阳为例，field 1起名xiangyang。MATLAB脚本中要用到Channel的ID、read_API_key、write_API_key。

#### 推送准备

##### Pushbear准备

创建通道，MATLAB脚本中要用到通道的sendkey。

##### 或者Telegram/IFTTT准备

- 在IFTTT关联Telegram，即TG上有[@ifttt](https://t.me/ifttt)这个bot。
- 在IFTTT启用webhooks，[后面需调用的url可在这里看到](https://ifttt.com/services/maker_webhooks/settings)。
- 在IFTTT建立一个if Webhooks then Telegram的Applet，设定一个Event Name。

#### Thingspeak Apps - MATLAB Analysis

新建MATLAB Analysis的app，将脚本文件XXXX.m中的代码填入；根据注释将Channel ID、几个API key和目标城镇替换为你自己的；设定10分钟运行一次的Time Control。

## 后记

Inspired by [Telegram广州天气速报频道](https://t.me/cantonWeather)

