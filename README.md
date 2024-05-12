<img alt="GitHub License" src="https://img.shields.io/github/license/wukongdaily/diy-nas-onescript?labelColor=%23FF4500&color=black"> 

### 镜像仓库:https://cafe.cpolar.cn/wkdaily/zero3
### 通过ssh 连接到zero3,举例
`ssh orangepi@192.168.66.106`
- 默认用户名:`orangepi`
- 默认密码:`orangepi` <br>
#### 准备：首次使用 如果时间不正确可以先更新软件 然后设置时区
```
# 举例 可以先手动设置好 当前时间 比如 
sudo date -s "2024-05-11 07:45:00"
# 更新apt
sudo apt update
# 设置时区Asia/Shanghai
sudo orangepi-config
```


<img src="https://github.com/wukongdaily/OrangePiShell/assets/143675923/0d9e5421-53b4-4a63-b7a1-025ab977eed5" width="40%" />

> 调用命令之前最好先切后到root模式 ubuntu/synology 使用 `sudo -i`<br>
> debian 使用 `su -` 

### Ubuntu/Debian/Synology等基于Debian的Linux

```bash
wget -qO pi.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/pi.sh && chmod +x pi.sh && ./pi.sh

```

### OpenWrt/iStoreOS 软路由系统
```bash
wget -qO op.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/op.sh && chmod +x op.sh && ./op.sh

```


<img src="https://cafe.cpolar.cn/wkdaily/zero3/releases/download/v1/pre.jpg" width="40%" />


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

| 系统 | 或 |机型  |
|-----|-----|-----|
| Ubuntu ✅ | Debian ✅ | Deepin ✅ |
| OpenWrt ✅ | iStoreOS ✅ | MT-3000 ✅ |
| NanoPi-R2S ✅ | NanoPi-R4S ✅ | NanoPi-Neo3 ✅ |
| Synology ✅ |  |   |

# 常见问题汇总⬇️⬇️⬇️
[filebrowser 如何设置自定义端口](https://github.com/wukongdaily/OrangePiShell/wiki/filebrowser-%E5%A6%82%E4%BD%95%E8%AE%BE%E7%BD%AE%E8%87%AA%E5%AE%9A%E4%B9%89%E7%AB%AF%E5%8F%A3)

[常见问题总结（持续更新中](https://github.com/wukongdaily/OrangePiShell/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)

[常见问题总结（持续更新中）](https://cafe.cpolar.cn/wkdaily/zero3/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E6%B1%87%E6%80%BB)
# 如何定时重启小雅？
[使用1panel 添加定时任务即可](https://cafe.cpolar.cn/wkdaily/zero3/wiki/%E5%A6%82%E4%BD%95%E5%AE%9A%E6%97%B6%E9%87%8D%E5%90%AF%E5%B0%8F%E9%9B%85)

# 参考项目
https://github.com/DDS-Derek/xiaoya-alist
