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

is_x86_64_router() {
    DISTRIB_ARCH=$(cat /etc/openwrt_release | grep "DISTRIB_ARCH" | cut -d "'" -f 2)
    if [ "$DISTRIB_ARCH" = "x86_64" ]; then
        return 0
    else
        return 1
    fi
}

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
    mkdir -p /opt/tvhelper_data
    chmod 777 /opt/tvhelper_data
    green 若使用自定义安装apk功能,可将apk放到/opt/tvhelper_data目录,用完记得及时清理
    docker run -d \
        --restart unless-stopped \
        --name tvhelper \
        -p 2299:22 \
        -p 2288:80 \
        -v "/opt/tvhelper_data:/tvhelper/shells/data" \
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
    curl -fsSL https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/xiaoya/xiaoya_tvbox.sh -o xt.sh
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
        -v /:/ahost \
        -e TZ=Asia/Shanghai \
        moelin/1panel:latest

    echo '
    默认端口：10086
    默认账户：1panel
    默认密码：1panel_password
    默认入口：entrance'
    green http://${host_ip}:10086/entrance
    green "或者访问 http://路由器ip:10086/entrance"

}

# 安装istoreOS版本1panel
install_istorepanel() {
    green "请务必确保您使用的是iStoreOS系统 回车或输入y来确定"
    yellow "并且移除了之前安装过的通用版1panel容器(y|n)"
    read -r answer
    if [ "$answer" = "y" ] || [ -z "$answer" ]; then
        green "先确保安装了iStore增强"
        is-opkg install app-meta-istoreenhance
        green "正在安装1panel的iStoreOS版本..."
        rm -rf /etc/config/istorepanel
        is-opkg remove app-meta-istorepanel
        is-opkg install app-meta-istorepanel
        green "正在安装istore版1panel..."
        # 执行 quickstart showLanIP 命令并提取结果
        output=$(quickstart showLanIP)
        lan_ip=$(echo $output | awk -F 'lanIp= ' '{print $2}')
        # 获取 Docker 根目录路径
        docker_root_dir=$(docker info 2>/dev/null | grep 'Docker Root Dir' | awk -F ': ' '{print $2}')
        # 检查是否成功获取到路径
        if [ -z "$docker_root_dir" ]; then
            echo "Failed to get Docker root directory."
            exit 1
        fi
        if ! is_available_space_greater_than_2GB "$docker_root_dir"; then
            red "检测到docker空间不足2GB 请在iStoreOS首页迁移docker到更大的分区"
            exit 1
        fi
        # 去除末尾的 '/docker' 部分
        config_root_dir=$(dirname "$docker_root_dir")
        config_path="${config_root_dir}/Configs/1Panel"
        green "是否将配置文件存放在下面的目录"
        yellow "$config_path"
        cyan "请回车继续或者输入n退出"
        read -r isConfig
        if [ "$isConfig" = "y" ] || [ -z "$isConfig" ]; then
            uci set istorepanel.@main[0].config_path=$config_path
            uci commit istorepanel
            wget -qO /tmp/istorepanel.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/istorepanel.sh
            chmod +x /tmp/istorepanel.sh
            "/tmp/istorepanel.sh" install 
            greenline "———————————————安装完成————————————————————————"
            countdown
            echo
            cyan "http://$lan_ip/cgi-bin/luci/admin/services/istorepanel"
            green "跳转到上述页面, 打开1panel或修改参数"
            cyan "http://$lan_ip:10086/entrance"
            green "或者跳转到上述页面, 直接打开1panel面板"
        else
            greenline "————————————————————————————————————————————————————"
            green "http://$lan_ip/cgi-bin/luci/admin/services/istorepanel"
            green "跳转到上述页面,手动点击 【安装】按钮 来启用1panel"
        fi
    else
        yellow "您选择了不安装"
    fi
}

is_available_space_greater_than_2GB() {
    local dir_path=$1
    local available_space_kb=$(df -k "$dir_path" | awk 'NR==2 {print $4}')
    local available_space_gb=$((available_space_kb / 1024 / 1024))
    if [ "$available_space_gb" -gt 2 ]; then
        return 0 
    else
        return 1 
    fi
}

# 倒计时15秒
countdown() {
    local seconds=15

    while [ $seconds -gt 0 ]; do
        printf "\r请耐心等待: %2d 秒后再访问" $seconds
        sleep 1
        seconds=$((seconds - 1))
    done
}

#根据release地址和命名前缀获取apk地址
get_docker_compose_url() {
    if [ $# -eq 0 ]; then
        echo "需要提供GitHub releases页面的URL作为参数。"
        return 1
    fi
    local releases_url=$1
    # 使用curl获取重定向的URL
    latest_url=$(curl -Ls -o /dev/null -w "%{url_effective}" "$releases_url")
    # 使用sed从URL中提取tag值,并保留前导字符'v'
    tag=$(echo $latest_url | sed 's|.*/v|v|')
    # 检查是否成功获取到tag
    if [ -z "$tag" ]; then
        echo "未找到最新的release tag。"
        return 1
    fi
    # 拼接docker-compose下载链接
    if is_x86_64_router; then
        platform="docker-compose-linux-x86_64"
    else
        platform="docker-compose-linux-aarch64"
    fi
    local repo_path=$(echo "$releases_url" | sed -n 's|https://github.com/\(.*\)/releases/latest|\1|p')
    if [[ $(curl -s ipinfo.io/country) == "CN" ]]; then
        docker_compose_download_url="https://cafe.cpolar.cn/wkdaily/docker-compose/raw/branch/main/${platform}"
    else
        docker_compose_download_url="https://github.com/${repo_path}/releases/download/${tag}/${platform}"
    fi
    echo "$docker_compose_download_url"
}

# 下载并安装Docker Compose
do_install_docker_compose() {

    # https://github.com/docker/compose/releases/download/v2.26.0/docker-compose-linux-aarch64
    # 检查/usr/bin/docker是否存在并且可执行
    if [ -f "/usr/bin/docker" ] && [ -x "/usr/bin/docker" ]; then
        echo "Docker is installed and has execute permissions."
    else
        red "警告 您还没有安装Docker"
        exit 1
    fi
    local github_releases_url="https://github.com/docker/compose/releases/latest"
    local docker_compose_url=$(get_docker_compose_url "$github_releases_url")
    cyan "最新版docker-compose 地址:$docker_compose_url"
    cyan "即将下载最新版docker-compose standalone"
    wget -O /usr/bin/docker-compose $docker_compose_url
    if [ $? -eq 0 ]; then
        green "docker-compose下载并安装成功,你可以使用啦"
        chmod +x /usr/bin/docker-compose
    else
        red "安装失败,请检查网络连接.或者手动下载到 /usr/bin/docker-compose 记得赋予执行权限"
        yellow "刚才使用的地址是:$docker_compose_url"
        exit 1
    fi

}

# 安装特斯拉伴侣
install_teslamate() {
    if which docker-compose >/dev/null 2>&1; then
        echo "Docker Compose is installed."
        docker-compose --version
        mkdir -p /tmp/teslamate
        wget -O /tmp/teslamate/docker-compose.yml https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/teslamate/docker-compose.yml
        cd /tmp/teslamate
        docker-compose up -d
    else
        red "Docker Compose is not installed. "
        do_install_docker_compose
    fi
}

install_xiaoya_allinone() {
    if which docker-compose >/dev/null 2>&1; then
        bash -c "$(curl -fsSL https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/xiaoya/xiaoya-all.sh)"
    else
        red "Docker Compose 还未安装,正在尝试安装..."
        green "安装成功后,请您再次执行该选项"
        do_install_docker_compose
    fi
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
    cyan " 4. 安装1panel(iStoreOS版)"
    echo " 5. 安装特斯拉伴侣TeslaMate"
    echo " 6. 安装docker-compose"
    echo " 7. 安装小雅全家桶Emby|Jellyfin"
    echo " 8. 安装1panel面板通用版"
    cyan " U. 更新脚本"
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
        install_istorepanel
        ;;
    5)
        install_teslamate
        ;;
    6)
        do_install_docker_compose
        ;;
    7)
        install_xiaoya_allinone
        ;;
    8)
        install_1panel_on_openwrt
        ;;
    u | U)
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
