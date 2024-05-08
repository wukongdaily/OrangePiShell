<img alt="GitHub License" src="https://img.shields.io/github/license/wukongdaily/diy-nas-onescript?labelColor=%23FF4500&color=black"> 

### 镜像仓库:https://cafe.cpolar.cn/wkdaily/zero3
### 通过ssh 连接到zero3,举例
`ssh orangepi@192.168.66.106`
- 默认用户名:`orangepi`
- 默认密码:`orangepi` <br>
#### 首次使用 如果时间不正确可以先更新软件 然后设置时区
```
sudo apt update
sudo orangepi-config
```


<img src="https://github.com/wukongdaily/OrangePiShell/assets/143675923/0d9e5421-53b4-4a63-b7a1-025ab977eed5" width="40%" />


### zero3 在Ubuntu系统下如何连接wifi? 如上图所示都有


### 一键命令如下(Ubuntu)
> 系统带sudo
```bash
wget -qO pi.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/pi.sh && chmod +x pi.sh
./pi.sh proxy

```
### Debian的准备
> debian系统最好先切到root身份再运行上述脚本


```bash
su -
```
```bash
wget -qO pi.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/pi.sh && chmod +x pi.sh
./pi.sh proxy

```



***

<img src="https://github.com/wukongdaily/OrangePiShell/assets/143675923/56898b74-ea47-44aa-8de3-e14e12873a25" width="40%" />


### 网盘
- docker 离线包：https://wwl.lanzouq.com/s/zero3  密码:3c60
- 免费内网穿透工具:https://i.cpolar.com/m/5Ij6
- docker全部离线包：https://drive.google.com/drive/folders/1lN14zlHeLu0zckHNftpW8kPlqGZHolL8?usp=sharing
- zero3开发版 Ubuntu Server(需要解压后再写入TF卡):https://pan.baidu.com/s/1EKlmccM6STFDb_01rv-qQQ?pwd=2gc7
- TF卡写盘工具：https://etcher.balena.io/
- 教学视频：https://www.bilibili.com/video/BV1ND421T7nB/
- 教学视频2:https://youtu.be/Ym4d7uCo9eg

# 兼容的系统
| 设备 \| 架构   | 是否支持 |
| :----- | :--: | 
| x86-64 \| amd64   |  ✅  |
| arm64 \| arm64v8 |  ✅  | 
| armhf \| armv7 |  ✅  | 

| 系统名称   | 是否支持 |
| :----- | :--: | 
| Ubuntu   |  ✅  |
| Debian |  ✅  | 
| Deepin |  ✅  |
# 常见问题汇总⬇️⬇️⬇️
[filebrowser 如何设置自定义端口](https://github.com/wukongdaily/OrangePiShell/wiki/filebrowser-%E5%A6%82%E4%BD%95%E8%AE%BE%E7%BD%AE%E8%87%AA%E5%AE%9A%E4%B9%89%E7%AB%AF%E5%8F%A3)

[常见问题总结（持续更新中](https://github.com/wukongdaily/OrangePiShell/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)

[常见问题总结（持续更新中）](https://cafe.cpolar.cn/wkdaily/zero3/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E6%B1%87%E6%80%BB)
# 如何定时重启小雅？
[使用1panel 添加定时任务即可](https://cafe.cpolar.cn/wkdaily/zero3/wiki/%E5%B8%B8%E8%A7%81%E9%9C%80%E6%B1%82%E5%9C%BA%E6%99%AF%E6%B1%87%E6%80%BB)

# 参考项目
https://github.com/DDS-Derek/xiaoya-alist
