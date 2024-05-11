#!/bin/sh
# OpenWrt/iStoreOS
# 定义颜色输出函数
red() { echo -e "\033[31m\033[01m[WARNING] $1\033[0m"; }
green() { echo -e "\033[32m\033[01m[INFO] $1\033[0m"; }
greenline() { echo -e "\033[32m\033[01m $1\033[0m"; }
yellow() { echo -e "\033[33m\033[01m[NOTICE] $1\033[0m"; }
blue() { echo -e "\033[34m\033[01m[MESSAGE] $1\033[0m"; }
light_magenta() { echo -e "\033[95m\033[01m[NOTICE] $1\033[0m"; }
highlight() { echo -e "\033[32m\033[01m$1\033[0m"; }
cyan() { echo -e "\033[38;2;0;255;255m$1\033[0m"; }

get_hostname() {
    hostname=$(uci get system.@system[0].hostname)
    echo "${hostname}.lan"
}

host_ip=$(get_hostname)

#安装alist
install_alist() {
    green "正在安装alist 请稍后"
    docker run -d --restart=unless-stopped -v /etc/alist:/opt/alist/data -p 5244:5244 -e PUID=0 -e PGID=0 -e UMASK=022 --name="alist" xhofe/alist:latest
    sleep 3
    docker exec -it alist ./alist admin set admin
    echo '
    AList已安装,已帮你设置好用户名和密码,若修改请在web面板修改即可。
    用户: admin 
    密码: admin
    '
    green 浏览器访问:http://${host_ip}:5244
}

# 安装盒子助手docker版
install_wukongdaily_box() {
    mkdir -p /mnt/tvhelper_data
    chmod 777 /mnt/tvhelper_data
    docker run -d \
        --restart unless-stopped \
        --name tvhelper \
        -p 2299:22 \
        -p 2288:80 \
        -v "/mnt/tvhelper_data:/tvhelper/shells/data" \
        -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/android-sdk/platform-tools \
        wukongdaily/box:latest
    if ! docker ps | grep -q "wukongdaily/box"; then
        echo "Error: 盒子助手docker版 未运行成功"
    else
        green "盒子助手docker版已启动，可以通过 http://${host_ip}:2288 验证是否安装成功"
        green "还可以通过 ssh root@${host_ip} -p 2299 连接到容器内 执行 ./tv.sh 使用该工具"
        green "文档和教学视频：https://www.youtube.com/watch?v=xAk-3TxeXxQ \n  https://www.bilibili.com/video/BV1Rm411o78P"
    fi
}

# 更新自己
update_scripts() {
    wget -O op.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/op.sh && chmod +x op.sh
    ./op.sh
    exit 0
}

# 安装小雅xiaoya-tvbox
# 参考 https://har01d.cn/notes/alist-tvbox.html
install_xiaoya_tvbox() {
    wget -qO xt.sh https://d.har01d.cn/update_xiaoya.sh
    chmod +x xt.sh
    ./xt.sh -d /etc/xiaoya
    green "tvbox 使用的json地址是 http://${host_ip}:4567/sub/0"
    green "更多文档请查看:https://har01d.cn/notes/alist-tvbox.html"
    green "上述这些网址,建议等足5分钟后再查看!\n若没有配置过token信息,可以在此处添加账号 http://${host_ip}:4567/#/accounts"
    echo '
    小雅tvbox
    webdav 信息如下
    端口:5344
    用户: guest 
    密码: guest_Api789
    '
}

# 安装1panel面板
install_1panel_on_openwrt() {
    docker run -d \
        --name 1panel \
        --restart always \
        --network host \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /www/data/1panel-data:/opt/1panel_data \
        -e TZ=Asia/Shanghai \
        moelin/1panel:latest

    echo '
    默认端口：10086
    默认账户：1panel
    默认密码：1panel_password
    默认入口：entrance'
    green http://${host_ip}:10086/entrance
    green 或者访问 http://路由器ip:10086/entrance

}

# *************************************************************
while true; do
    #*************************************
    clear
    greenline "————————————————————————————————————————————————————"
    echo '
    ***********  DIY docker轻服务器  ***************
    环境:OpenWrt/iStoreOS
    脚本作用:快速部署一个省电无感的小透明轻服务器
            --- Made by wukong with YOU ---'
    echo -e "    https://github.com/wukongdaily/OrangePiShell"
    greenline "————————————————————————————————————————————————————"
    echo
    cyan " 1. 安装小雅tvbox"
    echo " 2. 安装盒子助手docker版"
    echo " 3. 安装AList docker版"
    echo " 4. 安装1panel面板docker版"
    echo " 5. 更新脚本"
    echo
    echo " Q. 退出本程序"
    echo
    read -p "请选择一个选项: " choice

    case $choice in

    1)
        install_xiaoya_tvbox
        ;;
    2)
        install_wukongdaily_box
        ;;
    3)
        install_alist
        ;;
    4)
        install_1panel_on_openwrt
        ;;
    5)
        update_scripts
        ;;
    q | Q)
        echo "退出"
        exit 0
        ;;
    *)
        echo "无效选项，请重新选择。"
        ;;
    esac

    read -p "按 Enter 键继续..."
done
