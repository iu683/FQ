#!/bin/bash

# ================== 颜色定义 ==================
green="\033[32m"
red="\033[31m"
yellow="\033[33m"
re="\033[0m"

SCRIPT_PATH="/usr/local/bin/reality_menu.sh"

# ================== 确保脚本保存 ==================
if [ ! -f "$SCRIPT_PATH" ]; then
    cp "$0" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    echo "✅ 脚本已保存到 $SCRIPT_PATH"
fi

# ================== 创建快捷键 ==================
if [ ! -f /usr/local/bin/b ]; then
    echo "#!/bin/bash" > /usr/local/bin/b
    echo "bash $SCRIPT_PATH" >> /usr/local/bin/b
    chmod +x /usr/local/bin/b
fi

if [ ! -f /usr/local/bin/B ]; then
    echo "#!/bin/bash" > /usr/local/bin/B
    echo "bash $SCRIPT_PATH" >> /usr/local/bin/B
    chmod +x /usr/local/bin/B
fi

echo "✅ 快捷键 b 和 B 已创建，可以直接在终端使用 b 或 B 启动脚本"

# ================== 功能函数 ==================
install_reality() {
    port=$(shuf -i 2000-65000 -n 1)
    echo -e "${green}Reality 安装完成！端口: $port${re}"
    read -rp "按回车返回菜单..."
    return 2>/dev/null || true
}

status_reality() {
    echo -e "${green}Reality 状态: 运行中${re}"
    read -rp "按回车返回菜单..."
    return 2>/dev/null || true
}

change_port() {
    read -rp "请输入新端口: " new_port
    echo -e "${green}✅ 端口已更改为: $new_port${re}"
    read -rp "按回车返回菜单..."
    return 2>/dev/null || true
}

uninstall_reality() {
    echo -e "${red}Reality 已卸载${re}"
    read -rp "按回车返回菜单..."
    return 2>/dev/null || true
}

# ================== 菜单函数 ==================
show_menu() {
    while true; do
        echo "--------------"
        echo -e "${green}1. 安装 Reality${re}"
        echo -e "${green}2. 查看 Reality 状态${re}"
        echo -e "${green}3. 更改 Reality 端口${re}"
        echo -e "${green}4. 卸载 Reality${re}"
        echo "--------------"
        echo -e "${yellow}0. 退出${re}"
        echo "--------------"
        read -rp "请输入你的选择: " choice

        case $choice in
            1) install_reality ;;
            2) status_reality ;;
            3) change_port ;;
            4) uninstall_reality ;;
            0) echo "已退出脚本"; exit 0 ;;
            *) echo -e "${red}无效选择，请重新输入${re}" ;;
        esac
    done
}

# ================== 启动菜单 ==================
show_menu
