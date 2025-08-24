#!/bin/bash

# ================== 检查是否 root ==================
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31m请使用 root 用户运行此脚本！\033[0m"
    exit 1
fi

# ================== 颜色定义 ==================
green="\033[32m"
red="\033[31m"
yellow="\033[33m"
re="\033[0m"

# ================== 固定路径 ==================
LOCAL_SCRIPT="/usr/local/bin/reality_menu.sh"

# ================== 初始化自我复制 ==================
# 如果当前脚本不是 /usr/local/bin/reality_menu.sh，就拷贝自己一份过去
if [[ "$(realpath "$0")" != "$LOCAL_SCRIPT" ]]; then
    mkdir -p /usr/local/bin
    cp -f "$(realpath "$0")" "$LOCAL_SCRIPT"
    chmod +x "$LOCAL_SCRIPT"
fi

# ================== 工具函数 ==================
random_port() { shuf -i 2000-65000 -n 1; }

check_port() {
    local port=$1
    while [[ -n $(lsof -i :$port 2>/dev/null) ]]; do
        echo -e "${red}${port}端口已被占用，请更换端口${re}"
        read -p "请输入端口（直接回车使用随机端口）: " port
        [[ -z $port ]] && port=$(random_port) && echo -e "${green}使用随机端口: $port${re}"
    done
    echo $port
}

install_lsof() {
    if ! command -v lsof &>/dev/null; then
        if [ -f "/etc/debian_version" ]; then
            apt update && apt install -y lsof
        elif [ -f "/etc/alpine-release" ]; then
            apk add lsof
        fi
    fi
}

install_jq() {
    if ! command -v jq &>/dev/null; then
        if [ -f "/etc/debian_version" ]; then
            apt update && apt install -y jq
        elif [ -f "/etc/alpine-release" ]; then
            apk add jq
        fi
    fi
}

# ================== 下载 Reality 安装脚本 ==================
download_reality_script() {
    TMP_SCRIPT="/tmp/azreality.sh"
    curl -fsSL -o "$TMP_SCRIPT" https://raw.githubusercontent.com/Polarisiu/proxy/main/azreality.sh
    chmod +x "$TMP_SCRIPT"
    echo "$TMP_SCRIPT"
}

# ================== 保存自身并创建快捷键（仅一次） ==================
create_shortcut() {
    if [[ ! -f /usr/local/bin/b || ! -f /usr/local/bin/B ]]; then
        ln -sf "$LOCAL_SCRIPT" /usr/local/bin/b
        ln -sf "$LOCAL_SCRIPT" /usr/local/bin/B
        chmod +x /usr/local/bin/b /usr/local/bin/B
        echo -e "${green}✅ 快捷键 b 和 B 已创建，可以直接在终端使用 b 或 B 启动脚本${re}"
    fi
}

# ================== 安装 Reality ==================
install_reality() {
    install_lsof
    install_jq
    read -p "请输入Reality节点端口（回车随机端口）: " port
    [[ -z $port ]] && port=$(random_port)
    port=$(check_port $port)

    echo -e "${green}开始安装 Reality...${re}"
    TMP_SCRIPT=$(download_reality_script)
    PORT=$port bash "$TMP_SCRIPT"

    echo -e "${green}✅ Reality 安装完成！端口: $port${re}"

    create_shortcut
    read -rp "按回车返回菜单..."
}

# ================== 卸载 Reality ==================
uninstall_reality() {
    echo -e "${yellow}正在卸载 Reality...${re}"
    
    # 停止 Reality 服务（如果有）
    systemctl stop reality 2>/dev/null
    systemctl disable reality 2>/dev/null

    # 删除 Reality 文件
    rm -f /usr/local/bin/reality
    rm -f /etc/systemd/system/reality.service

    # 删除菜单脚本
    rm -f "$LOCAL_SCRIPT"

    # 删除快捷方式
    rm -f /usr/local/bin/b
    rm -f /usr/local/bin/B

    systemctl daemon-reload 2>/dev/null

    echo -e "${green}✅ Reality 已成功卸载${re}"
    exit 0
}

# ================== 主菜单 ==================
while true; do
    clear
    echo "--------------"
    echo -e "${green}1. 安装 Reality${re}"
    echo -e "${green}2. 查看 Reality 状态${re}"
    echo -e "${green}3. 更改 Reality 端口${re}"
    echo -e "${green}4. 卸载 Reality${re}"
    echo "--------------"
    echo -e "${green}0. 退出${re}"
    echo "--------------"

    read -p $'\033[1;32m请输入你的选择: \033[0m' sub_choice
    case $sub_choice in
        1) install_reality ;;
        2) # 查看状态
            clear
            echo -e "${green}正在检查 Reality 运行状态...${re}"
            if [ -f "/etc/alpine-release" ]; then
                if pgrep -f 'web' >/dev/null; then
                    echo -e "${green}✅ Reality 正在运行${re}"
                    port=$(jq -r '.inbounds[0].port' ~/app/config.json 2>/dev/null)
                    [[ -n $port ]] && echo -e "${green}当前端口: $port${re}"
                else
                    echo -e "${red}❌ Reality 未运行${re}"
                fi
            else
                if systemctl is-active --quiet xray; then
                    echo -e "${green}✅ Reality 正在运行 (systemd 管理)${re}"
                    port=$(jq -r '.inbounds[] | select(.protocol=="vless").port' /usr/local/etc/xray/config.json 2>/dev/null)
                    [[ -n $port ]] && echo -e "${green}当前端口: $port${re}"
                else
                    echo -e "${red}❌ Reality 未运行${re}"
                fi
            fi
            read -rp "按回车返回菜单..."
            ;;
        3) # 改端口
            clear
            install_jq
            read -p "请输入新 Reality 端口（回车随机端口）: " new_port
            [[ -z $new_port ]] && new_port=$(random_port)
            new_port=$(check_port $new_port)

            if [ -f "/etc/alpine-release" ]; then
                jq --argjson new_port "$new_port" '(.inbounds[] | select(.protocol=="vless")).port = $new_port' ~/app/config.json > tmp.json && mv tmp.json ~/app/config.json
                pkill -f 'web'
                cd ~/app && nohup ./web -c config.json >/dev/null 2>&1 &
            else
                jq --argjson new_port "$new_port" '(.inbounds[] | select(.protocol=="vless")).port = $new_port' /usr/local/etc/xray/config.json > tmp.json && mv tmp.json /usr/local/etc/xray/config.json
                systemctl restart xray.service
            fi
            echo -e "${green}✅ Reality端口已更换成 $new_port${re}"
            read -rp "按回车返回菜单..."
            ;;
        4) uninstall_reality ;;
        0) echo -e "${green}已退出脚本${re}"; exit 0 ;;
        *) echo -e "${red}无效输入！${re}"; sleep 1 ;;
    esac
done
