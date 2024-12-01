#!/bin/bash

# 定义颜色输出函数
red() { echo -e "\033[31m\033[01m[WARNING] $1\033[0m"; }
green() { echo -e "\033[32m\033[01m[INFO] $1\033[0m"; }
greenline() { echo -e "\033[32m\033[01m $1\033[0m"; }
yellow() { echo -e "\033[33m\033[01m[NOTICE] $1\033[0m"; }
blue() { echo -e "\033[34m\033[01m[MESSAGE] $1\033[0m"; }
light_magenta() { echo -e "\033[95m\033[01m[NOTICE] $1\033[0m"; }
highlight() { echo -e "\033[32m\033[01m$1\033[0m"; }
cyan() { echo -e "\033[38;2;0;255;255m$1\033[0m"; }

# 检查是否以 root 用户身份运行
if [ "$(id -u)" -ne 0 ]; then
    green "注意！输入密码过程不显示*号属于正常现象"
    echo "此脚本需要以 root 用户权限运行，请输入当前用户的密码："
    # 使用 'sudo' 重新以 root 权限运行此脚本
    sudo -E "$0" "$@"
    exit $?
fi

declare -a menu_options
declare -A commands
menu_options=(
    "更新系统软件包"
    "安装docker"
    "安装并启动文件管理器FileBrowser"
    "安装1panel面板管理工具"
    "查看1panel用户信息"
    "Sun-Panel导航面板"
    "安装alist"
    "安装小雅alist"
    "安装小雅转存清理工具"
    "安装小雅tvbox"
    "使用docker-compose部署小雅全家桶(建议x86-64设备)"
    "群晖6.2系统安装docker-compose(x86-64)"
    "修改阿里云盘Token(32位)"
    "修改阿里云盘OpenToken(335位)"
    "修改小雅转存文件夹ID(40位)"
    "安装内网穿透工具Cpolar"
    "安装盒子助手docker版"
    "安装特斯拉伴侣TeslaMate"
    "安装CasaOS面板"
    "安装内网穿透工具DDNSTO"
    "更新脚本"
)

commands=(
    ["更新系统软件包"]="update_system_packages"
    ["安装docker"]="install_docker"
    ["安装并启动文件管理器FileBrowser"]="install_filemanager"
    ["设置文件管理器开机自启动"]="start_filemanager"
    ["安装1panel面板管理工具"]="install_1panel_on_linux"
    ["查看1panel用户信息"]="read_user_info"
    ["安装alist"]="install_alist"
    ["安装小雅alist"]="install_xiaoya_alist"
    ["安装小雅转存清理工具"]="install_xiaoya_keeper"
    ["修改阿里云盘Token(32位)"]="update_aliyunpan_token"
    ["修改阿里云盘OpenToken(335位)"]="update_aliyunpan_opentoken"
    ["修改小雅转存文件夹ID(40位)"]="update_aliyunpan_folder_id"
    ["安装内网穿透工具Cpolar"]="install_cpolar"
    ["安装盒子助手docker版"]="install_wukongdaily_box"
    ["安装CasaOS面板"]="install_casaos"
    ["更新脚本"]="update_scripts"
    ["安装小雅tvbox"]="install_xiaoya_tvbox"
    ["安装特斯拉伴侣TeslaMate"]="install_teslamate"
    ["安装内网穿透工具DDNSTO"]="install_ddnsto"
    ["使用docker-compose部署小雅全家桶(建议x86-64设备)"]="install_xiaoya_emby"
    ["群晖6.2系统安装docker-compose(x86-64)"]="do_install_docker_compose"
    ["Sun-Panel导航面板"]="install_sun_panel"

)

# 更新系统软件包
update_system_packages() {
    green "Setting timezone Asia/Shanghai..."
    sudo timedatectl set-timezone Asia/Shanghai
    # 更新系统软件包
    green "Updating system packages..."
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    if ! command -v curl &>/dev/null; then
        red "curl is not installed. Installing now..."
        sudo apt install -y curl
        if command -v curl &>/dev/null; then
            green "curl has been installed successfully."
        else
            echo "Failed to install curl. Please check for errors."
        fi
    else
        echo "curl is already installed."
    fi
}

# 安装docker
install_docker() {
    bash <(curl -sSL https://linuxmirrors.cn/docker.sh)
}

# 安装文件管理器
# 源自 https://filebrowser.org/installation
install_filemanager() {
    trap 'echo -e "Aborted, error $? in command: $BASH_COMMAND"; trap ERR; return 1' ERR
    filemanager_os="unsupported"
    filemanager_arch="unknown"
    install_path="/usr/local/bin"

    # Termux on Android has $PREFIX set which already ends with /usr
    if [[ -n "$ANDROID_ROOT" && -n "$PREFIX" ]]; then
        install_path="$PREFIX/bin"
    fi

    # Fall back to /usr/bin if necessary
    if [[ ! -d $install_path ]]; then
        install_path="/usr/bin"
    fi

    # Not every platform has or needs sudo (https://termux.com/linux.html)
    ((EUID)) && [[ -z "$ANDROID_ROOT" ]] && sudo_cmd="sudo"

    #########################
    # Which OS and version? #
    #########################

    filemanager_bin="filebrowser"
    filemanager_dl_ext=".tar.gz"

    # NOTE: `uname -m` is more accurate and universal than `arch`
    # See https://en.wikipedia.org/wiki/Uname
    unamem="$(uname -m)"
    case $unamem in
    *aarch64*)
        filemanager_arch="arm64"
        ;;
    *64*)
        filemanager_arch="amd64"
        ;;
    *86*)
        filemanager_arch="386"
        ;;
    *armv5*)
        filemanager_arch="armv5"
        ;;
    *armv6*)
        filemanager_arch="armv6"
        ;;
    *armv7*)
        filemanager_arch="armv7"
        ;;
    *)
        green "Aborted, unsupported or unknown architecture: $unamem"
        return 2
        ;;
    esac

    unameu="$(tr '[:lower:]' '[:upper:]' <<<$(uname))"
    if [[ $unameu == *DARWIN* ]]; then
        filemanager_os="darwin"
    elif [[ $unameu == *LINUX* ]]; then
        filemanager_os="linux"
    elif [[ $unameu == *FREEBSD* ]]; then
        filemanager_os="freebsd"
    elif [[ $unameu == *NETBSD* ]]; then
        filemanager_os="netbsd"
    elif [[ $unameu == *OPENBSD* ]]; then
        filemanager_os="openbsd"
    elif [[ $unameu == *WIN* || $unameu == MSYS* ]]; then
        # Should catch cygwin
        sudo_cmd=""
        filemanager_os="windows"
        filemanager_bin="filebrowser.exe"
        filemanager_dl_ext=".zip"
    else
        green "Aborted, unsupported or unknown OS: $uname"
        return 6
    fi
    green "正在下载文件管理器($filemanager_os/$filemanager_arch) 请稍等..."
    if type -p curl >/dev/null 2>&1; then
        net_getter="curl -fSL -#"
    elif type -p wget >/dev/null 2>&1; then
        net_getter="wget -O-"
    else
        green "Aborted, could not find curl or wget"
        return 7
    fi
    filemanager_file="${filemanager_os}-$filemanager_arch-filebrowser$filemanager_dl_ext"
    filemanager_url="https://wkrepo.vip.cpolar.cn/res/$filemanager_file"

    # Use $PREFIX for compatibility with Termux on Android
    rm -rf "$PREFIX/tmp/$filemanager_file"

    ${net_getter} "$filemanager_url" >"$PREFIX/tmp/$filemanager_file"

    green "下载完成 正在解压..."
    case "$filemanager_file" in
    *.zip) unzip -o "$PREFIX/tmp/$filemanager_file" "$filemanager_bin" -d "$PREFIX/tmp/" ;;
    *.tar.gz) tar -xzf "$PREFIX/tmp/$filemanager_file" -C "$PREFIX/tmp/" "$filemanager_bin" ;;
    esac
    chmod +x "$PREFIX/tmp/$filemanager_bin"
    $sudo_cmd mv "$PREFIX/tmp/$filemanager_bin" "$install_path/$filemanager_bin"
    if setcap_cmd=$(PATH+=$PATH:/sbin type -p setcap); then
        $sudo_cmd $setcap_cmd cap_net_bind_service=+ep "$install_path/$filemanager_bin"
    fi
    $sudo_cmd rm -- "$PREFIX/tmp/$filemanager_file"

    if type -p $filemanager_bin >/dev/null 2>&1; then
        light_magenta "不依赖于docker的 文件管理器安装成功"
        trap ERR
        start_filemanager
        return 0
    else
        red "Something went wrong, File Browser is not in your path"
        trap ERR
        return 1
    fi
}

# 启动文件管理器
start_filemanager() {
    # 检查是否已经安装 filebrowser
    if ! command -v filebrowser &>/dev/null; then
        red "Error: filebrowser 未安装，请先安装 filebrowser"
        return 1
    fi

    # Add configuration file generation and editing
    $sudo_cmd mkdir -p /etc/filebrowser
    $sudo_cmd touch /etc/filebrowser/.filebrowser.json
    $sudo_cmd chown $(id -u):$(id -g) /etc/filebrowser/.filebrowser.json

    # Set the desired port
    desired_port="38080"
    cat >/etc/filebrowser/.filebrowser.json <<EOF
{
    "port": "$desired_port",
    "root": "/etc/filebrowser",
    "database": "/etc/filebrowser/filebrowser.db",
    "auth": {
        "username": "admin",
        "password": "admin"
    }
}
EOF

    green "设置文件管理器的端口为: $desired_port"

    # 启动 filebrowser 文件管理器
    green "启动 filebrowser 文件管理器..."

    # 使用 nohup 和输出重定向，记录启动日志到 filebrowser.log 文件中
    nohup sudo filebrowser -r / --address 0.0.0.0 --port $desired_port >filebrowser.log 2>&1 &

    # 检查 filebrowser 是否成功启动
    if [ $? -ne 0 ]; then
        red "Error: 启动 filebrowser 文件管理器失败"
        return 1
    fi
    local host_ip
    host_ip=$(hostname -I | awk '{print $1}')
    green "filebrowser 文件管理器已启动，可以通过 http://${host_ip}:${desired_port} 访问"
    green "登录用户名：admin"
    green "默认密码：admin（请尽快修改密码）"
    # 创建 Systemd 服务文件
    cat >/etc/systemd/system/filebrowser.service <<EOF
[Unit]
Description=File Browser Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/filebrowser -r / --address 0.0.0.0 --port ${desired_port}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo chmod +x /etc/systemd/system/filebrowser.service
    sudo systemctl daemon-reload              # 重新加载systemd配置
    sudo systemctl start filebrowser.service  # 启动服务
    sudo systemctl enable filebrowser.service # 设置开机启动
    sudo systemctl restart NetworkManager     # 重启网络 保证hostname生效
    yellow "已设置文件管理器开机自启动,下次开机可直接访问文件管理器"

    SCRIPT_PATH="/usr/trim/bin/show_startup_info.sh"
    # 判断脚本是否存在
    if [ ! -f "$SCRIPT_PATH" ]; then
        return 1
    fi
    HOST_NAME=$(hostname)
    cp "$SCRIPT_PATH" "${SCRIPT_PATH}.bak"
    # 在飞牛OS开机命令行界面插入Filebrowser地址和端口信息
    INSERT_INFO="Filebrowser Web console: http://$HOST_NAME:$desired_port or http://${host_ip}:${desired_port}\n"
    sed -i "/^Filebrowser Web console/d" "$SCRIPT_PATH"
    sed -i "/INFO_CONTENT=/a $INSERT_INFO" "$SCRIPT_PATH"
    light_magenta "文件管理器的访问地址和端口 已追加到飞牛OS开机命令行界面 预览如下"
    bash "$SCRIPT_PATH"
    cat /etc/issue

}
# 安装1panel面板
install_1panel_on_linux() {
    curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh
    intro="https://1panel.cn/docs/installation/cli/"
    if command -v 1pctl &>/dev/null; then
        echo '{
  "registry-mirrors": [
    "https://docker.1panel.live"
  ]
}' | sudo tee /etc/docker/daemon.json >/dev/null
        sudo /etc/init.d/docker restart
        green "如何卸载1panel 请参考：$intro"
    else
        red "未安装1panel"
    fi

}

# 查看1panel用户信息
read_user_info() {
    sudo 1pctl user-info
}

#安装alist
install_alist() {
    local host_ip
    host_ip=$(hostname -I | awk '{print $1}')
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

# 安装小雅alist
install_xiaoya_alist() {
    local host_ip
    host_ip=$(hostname -I | awk '{print $1}')
    rm -rf /mnt/xiaoya/mytoken.txt >/dev/null 2>&1
    rm -rf /mnt/xiaoya/myopentoken.txt >/dev/null 2>&1
    rm -rf /mnt/xiaoya/temp_transfer_folder_id.txt >/dev/null 2>&1
    cyan '
        根据如下三个网址的提示完成token的填写
        阿里云盘Token(32位):        https://alist.nn.ci/zh/guide/drivers/aliyundrive.html
        阿里云盘OpenToken(335位):   https://alist.nn.ci/tool/aliyundrive/request.html
        阿里云盘转存目录folder id:   https://www.aliyundrive.com/s/rP9gP3h9asE
        '
    # 调用修改后的脚本
    bash -c "$(curl https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/xiaoya/xiaoya.sh)"
    # 检查xiaoyaliu/alist 是否运行，如果运行了 则提示下面的信息，否则退出
    if ! docker ps | grep -q "xiaoyaliu/alist"; then
        echo "Error: xiaoyaliu/alist Docker 容器未运行"
        return 1
    fi

    echo '
    小雅docker已启动
    webdav 信息如下
    用户: guest 
    密码: guest_Api789
    '
    green 请您耐心等待xiaoya数据库更新完毕,建议5分钟后再访问
    green 建议使用1panel查看xiaoya容器日志 观察进度
    green 浏览器访问:http://${host_ip}:5678

}

# 安装小雅转存清理工具
install_xiaoya_keeper() {
    green "正在安装小雅转存清理工具..."
    bash -c "$(curl -sLk https://xiaoyahelper.ddsrem.com/aliyun_clear.sh | tail -n +2)" -s 5
    green "已设置实时清理，只要产生了播放缓存一分钟内立即清理转存文件夹里的文件."
}

# 更新阿里云盘Token
update_aliyunpan_token() {
    local token_file="/mnt/xiaoya/mytoken.txt"
    cyan '
        根据如下网址的提示完成token的填写
        阿里云盘Token(32位): https://alist.nn.ci/zh/guide/drivers/aliyundrive.html#%E5%88%B7%E6%96%B0%E4%BB%A4%E7%89%8C
        
        '
    # 提示用户输入 token
    read -p "请输入一个 阿里云盘token(32位): " token

    if [[ -z "$token" ]]; then
        echo "输入的 token 为空，无法写入文件。"
        return 1
    fi

    # 删除旧的 token 文件（如果存在）
    if [[ -f "$token_file" ]]; then
        sudo rm -rf "$token_file"
    fi

    # 将 token 写入新的文件
    sudo echo "$token" >"$token_file"
    green "成功写入 token 到文件: $token_file"
    cat $token_file
    red "重启小雅docker容器之后 才会生效,请记得在1panel面板手动重启该容器"
}

# 更新阿里云盘opentoken
update_aliyunpan_opentoken() {
    local token_file="/mnt/xiaoya/myopentoken.txt"
    cyan '
        根据如下网址的提示完成opentoken的填写
        阿里云盘OpenToken(335位): https://alist.nn.ci/tool/aliyundrive/request.html
        '
    # 提示用户输入 token
    read -p "请输入一个 阿里云盘OpenToken(335位): " token

    if [[ -z "$token" ]]; then
        echo "输入的 token 为空，无法写入文件。"
        return 1
    fi

    # 删除旧的 token 文件（如果存在）
    if [[ -f "$token_file" ]]; then
        sudo rm -rf "$token_file"
    fi

    # 将 token 写入新的文件
    sudo echo "$token" >"$token_file"
    green "成功写入 OpenToken 到文件: $token_file"
    cat $token_file
    red "重启小雅docker容器之后 才会生效,请记得在1panel面板手动重启该容器"
}

# 更新小雅转存文件夹id
update_aliyunpan_folder_id() {
    local token_file="/mnt/xiaoya/temp_transfer_folder_id.txt"
    cyan '
        根据如下网址的提示完成小雅转存文件夹ID的填写
        阿里云盘小雅转存文件夹ID(40位): https://www.aliyundrive.com/s/rP9gP3h9asE
        注意,首次使用 应该先转存该目录到自己的资源盘中
        然后在自己的资源盘找到该转存目录的id
        不要填写别人的文件夹id哦
        '
    # 提示用户输入 token
    read -p "请输入一个 阿里云盘小雅转存文件夹ID(40位): " token

    if [[ -z "$token" ]]; then
        echo "输入的 id 为空，无法写入文件。"
        return 1
    fi

    # 删除旧的 token 文件（如果存在）
    if [[ -f "$token_file" ]]; then
        sudo rm -rf "$token_file"
    fi

    # 将 token 写入新的文件
    sudo echo "$token" >"$token_file"
    green "成功写入 转存文件夹ID 到文件: $token_file"
    cat $token_file
    red "重启小雅docker容器之后 才会生效,请记得在1panel面板手动重启该容器"
}

# 安装内网穿透
install_cpolar() {
    local host_ip
    host_ip=$(hostname -I | awk '{print $1}')
    curl -L https://www.cpolar.com/static/downloads/install-release-cpolar.sh | sudo bash
    if command -v cpolar &>/dev/null; then
        # 提示用户输入 token
        green "访问 https://dashboard.cpolar.com/auth  复制您自己的AuthToken"
        read -p "请输入您的 AuthToken: " token
        # 执行 cpolar 命令并传入 token
        cpolar authtoken "$token"
        # 向系统添加服务
        green "正在向系统添加cpolar服务"
        sudo systemctl enable cpolar
        # 启动服务
        green "正在启动cpolar服务"
        sudo systemctl start cpolar
        # 查看状态
        green "cpolar服务状态如下"
        sudo systemctl status cpolar | tee /dev/tty
        green 浏览器访问:http://${host_ip}:9200/#/tunnels/list 创建隧道

    else
        red "错误：cpolar 命令未找到，请先安装 cpolar。"
    fi
}

# 安装盒子助手docker版
install_wukongdaily_box() {
    sudo mkdir -p /mnt/tvhelper_data
    sudo chmod 777 /mnt/tvhelper_data
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
        local host_ip
        host_ip=$(hostname -I | awk '{print $1}')
        green "盒子助手docker版已启动，可以通过 http://${host_ip}:2288 验证是否安装成功"
        green "还可以通过 ssh root@${host_ip} -p 2299 连接到容器内 执行 ./tv.sh 使用该工具 ssh密码password"
        green "文档和教学视频：https://www.youtube.com/watch?v=xAk-3TxeXxQ \n  https://www.bilibili.com/video/BV1Rm411o78P"
    fi
}

# 安装CasaOS
install_casaos() {
    curl -fsSL https://get.casaos.io | sudo bash
}

# 更新自己
update_scripts() {
    wget -O pi.sh https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/zero3/pi.sh && chmod +x pi.sh
    echo "脚本已更新并保存在当前目录 pi.sh,现在将执行新脚本。"
    ./pi.sh
    exit 0
}

# 安装小雅xiaoya-tvbox
# 参考 https://har01d.cn/notes/alist-tvbox.html
install_xiaoya_tvbox() {
    local host_ip
    host_ip=$(hostname -I | awk '{print $1}')
    #wget -qO xt.sh https://d.har01d.cn/update_xiaoya.sh
    curl -fsSL https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/xiaoya/xiaoya_tvbox.sh -o xt.sh
    sudo chmod +x xt.sh
    sudo ./xt.sh -d /mnt/xiaoya
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
# 安装特斯拉伴侣
install_teslamate() {
    check_docker_compose
    sudo mkdir -p /opt/teslamate/import
    wget -O /opt/teslamate/docker-compose.yml https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/teslamate/docker-compose.yml
    cd /opt/teslamate
    sudo docker-compose up -d
}

check_docker_compose() {
    if which docker-compose >/dev/null 2>&1; then
        echo "Docker Compose is installed."
        docker-compose --version
    else
        echo "Docker Compose is not installed. You can install 1panel first."
        exit 1
    fi
}

# 安装DDNSTO
install_ddnsto() {
    green "请登录 https://www.ddnsto.com/app/#/devices  在控制台复制 令牌 令牌=token"
    sh -c "$(curl -sSL http://fw.koolcenter.com/binary/ddnsto/linux/install_ddnsto_linux.sh)"
}

# 安装小雅全家桶
install_xiaoya_emby() {
    bash -c "$(curl -fsSL https://cafe.cpolar.cn/wkdaily/zero3/raw/branch/main/xiaoya/xiaoya-all.sh)"
}

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

    platform="docker-compose-linux-x86_64"
    local repo_path=$(echo "$releases_url" | sed -n 's|https://github.com/\(.*\)/releases/latest|\1|p')
    if [[ $(curl -s ipinfo.io/country) == "CN" ]]; then
        docker_compose_download_url="https://cafe.cpolar.cn/wkdaily/docker-compose/raw/branch/main/${platform}"
    else
        docker_compose_download_url="https://github.com/${repo_path}/releases/download/${tag}/${platform}"
    fi
    echo "$docker_compose_download_url"
}

# 适配群晖6.2 先行安装 docker-compose
do_install_docker_compose() {
    # /usr/local/bin/docker-compose
    local github_releases_url="https://github.com/docker/compose/releases/latest"
    local docker_compose_url=$(get_docker_compose_url "$github_releases_url")
    cyan "最新版docker-compose 地址:$docker_compose_url"
    cyan "即将下载最新版docker-compose standalone"
    wget -O /usr/local/bin/docker-compose $docker_compose_url
    if [ $? -eq 0 ]; then
        green "docker-compose下载并安装成功,你可以使用啦"
        chmod +x /usr/local/bin/docker-compose
    else
        red "安装失败,请检查网络连接.或者手动下载到 /usr/local/bin/docker-compose 记得赋予执行权限"
        yellow "刚才使用的地址是:$docker_compose_url"
        exit 1
    fi
}

install_sun_panel() {
    docker run -d --restart=always -p 3002:3002 \
        -v ~/docker_data/sun-panel/conf:/app/conf \
        -v /var/run/docker.sock:/var/run/docker.sock \
        --name sun-panel \
        hslr/sun-panel:latest
    if ! docker ps | grep -q "hslr/sun-panel"; then
        echo "Error: sun-panel 未运行成功"
    else
        local host_ip
        host_ip=$(hostname -I | awk '{print $1}')
        green "sun-panel已启动，可以通过 http://${host_ip}:3002 验证是否安装成功"
        green "默认用户名: admin@sun.cc"
        green "默认密码: 12345678"
    fi
}

show_menu() {
    clear
    greenline "————————————————————————————————————————————————————"
    echo '
    ***********  DIY docker轻服务器  ***************
    环境: (Ubuntu/Debian/synology etc)
    脚本作用:快速部署一个省电无感的小透明轻服务器
            --- Made by wukong with YOU ---'
    echo -e "    https://github.com/wukongdaily/OrangePiShell"
    greenline "————————————————————————————————————————————————————"
    echo "请选择操作："

    # 高亮菜单项
    special_items=("安装docker" "安装1panel面板管理工具" "安装小雅tvbox" "安装特斯拉伴侣TeslaMate" "安装盒子助手docker版" "安装内网穿透工具Cpolar" "Sun-Panel导航面板")
    for i in "${!menu_options[@]}"; do
        if [[ " ${special_items[*]} " =~ " ${menu_options[i]} " ]]; then
            # 如果当前项在特殊处理项数组中，使用特殊颜色
            cyan "$((i + 1)). ${menu_options[i]}"
        else
            # 否则，使用普通格式
            echo "$((i + 1)). ${menu_options[i]}"
        fi
    done
}

handle_choice() {
    local choice=$1
    # 检查输入是否为空
    if [[ -z $choice ]]; then
        echo -e "${RED}输入不能为空，请重新选择。${NC}"
        return
    fi

    # 检查输入是否为数字
    if ! [[ $choice =~ ^[0-9]+$ ]]; then
        echo -e "${RED}请输入有效数字!${NC}"
        return
    fi

    # 检查数字是否在有效范围内
    if [[ $choice -lt 1 ]] || [[ $choice -gt ${#menu_options[@]} ]]; then
        echo -e "${RED}选项超出范围!${NC}"
        echo -e "${YELLOW}请输入 1 到 ${#menu_options[@]} 之间的数字。${NC}"
        return
    fi

    # 执行命令
    if [ -z "${commands[${menu_options[$choice - 1]}]}" ]; then
        echo -e "${RED}无效选项，请重新选择。${NC}"
        return
    fi

    "${commands[${menu_options[$choice - 1]}]}"
}

while true; do
    show_menu
    read -p "请输入选项的序号(输入q退出): " choice
    if [[ $choice == 'q' ]]; then
        break
    fi
    handle_choice $choice
    echo "按任意键继续..."
    read -n 1 # 等待用户按键
done
