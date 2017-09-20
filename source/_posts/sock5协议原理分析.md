---
title: sock5协议原理分析
date: 2017-09-15 22:47:03
tags:
---

# shadowsocks翻墙原理
早点两年前就开始使用shadowsocks了,那时候买了搬瓦工一年19$的vps,由于搬瓦工数据中心比较少,且大部分位于美国,经过测试选了个在凤凰城的机房,但是网速一直不稳定时不时的断线,前阵子买了vultr位于东京数据中心的vps,网络稳定,看youtube 1080p 毫无压力.虽然用了很久的shandowsock5,但是一直对sock5协知之甚少,决定解下这个牛逼的翻墙协议,简单的说就是在墙外搭一个sock5服务器,墙内的客户端把tcp数据加密后发往墙外的服务器,server按照sock5协议解密后再发往目标机器


<div style="align: center">
<img src="https://yuerblog.cc/wp-content/uploads/2016/11/WechatIMG938.jpeg" width="100%" height="100%">
</div>

1. PC客户端（即你的电脑）发出请求基于Socks5协议跟SS-Local端进行通讯，由于这个SS-Local一般是本机或路由器等局域网的其他机器，不经过GFW，所以解决GFW通过特征分析进行干扰的问题
2. SS-Local和SS-Server两端通过多种可选的加密方法("aes-256-cfb"等)进行通讯，经过GFW的时候因为是常规的TCP包，没有明显特征码GFW也无法对通讯数据进行解密
3. SS-Server将收到的加密数据进行解密，还原初始请求，再发送到用户需要访问的服务网站，获取响应原路再返回SS-04，返回途中依然使用了加密，使得流量是普通TCP包，并成功穿过GFW防火墙



# sock5协议简介
>wiki:SOCKS是一种网络传输协议，主要用于客户端与外网服务器之间通讯的中间传递,根据OSI模型，SOCKS是会话层的协议，位于表示层与传输层之间

根据[rfc1928](https://www.ietf.org/rfc/rfc1928.txt "rfc1928")文档的说明,sock5协议设计之初就是为了解决翻墙问题,该协议工作在应用层和传输层,不提供例如转发ICMP消息的网关服务,sock5在sock4协议基础上增加了对udp和ipv6的支持,rfc文档中制定了报文格式:
1. sock5客户端先给服务端发版本协商报文

| VER   |  NMETHODS  | METHODS  |
| ---   | --------   | ------   |
|   1   |    1       |  1-255   | 
- VER字段为0x05
- NMETHODSB表示加密算法的格式
- METHODS表示具体的加密算法


2. 服务端版本协商响应报文

| VER   |  METHOD  | 
| :---: | :--------: | 
| 1     |    1       |

METHOD字段表示含义
- X'00' NO AUTHENTICATION REQUIRED
- X'01' GSSAPI
- X'02' USERNAME/PASSWORD
- X'03' to X'7F' IANA ASSIGNED
- X'80' to X'FE' RESERVED FOR PRIVATE METHODS
- X'FF' NO ACCEPTABLE METHODS

3. 协商完毕后client的正常请求

| VER | CMD | RSV | ATYP | DST ADDR | DST PORT |
| --- |  ---| --- | ---  |  ------- |  ------- |
|  1  |  1  | 00  |   1  | Variable |    2     |

- VER   protocol version: X'05'
- CMD 
    - CONNECT X'01'
    - BIND X'02'
    - UDP ASSOCIATE X'03'
- RSV    RESERVED
- ATYP   address type of following address
    - IP V4 address: X'01'
    - DOMAINNAME: X'03'
    - P V6 address: X'04'
- DST.ADDR       desired destination address
- DST.PORT desired destination port in network octet order

当客户端和服务端建立连接后,client会给server发送这样上面格式的请求

4. server的响应

| VER | REP | RSV | ATPY | BND ADDR | BND PORT |
|  -- | --- | --- | ---  | ----     |  ----    |
|  1  |  1  | 00  |  1   | Variable |    2     |

- VER    protocol version: X'05'
- REP    Reply field:
  - X'00' succeeded
  - X'01' general SOCKS server failure
  - X'02' connection not allowed by ruleset
  - X'03' Network unreachable
  - X'04' Host unreachable
  - X'05' Connection refused
  - X'06' TTL expired
  - X'07' Command not supported
  - X'08' Address type not supported
  - X'09' to X'FF' unassigned
- RSV    RESERVED
- ATYP   address type of following address

具体的协议抓包可以参考这篇博客[sock5抓包分析](https://www.skyreal.me/tong-guo-wireshark-zhua-bao-xue-xi-socks5-xie-yi/ "sock5抓包分析")
