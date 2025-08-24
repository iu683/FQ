#!/bin/bash

# ================== 颜色 ==================
green="\033[32m"
red="\033[31m"
yellow="\033[33m"
re="\033[0m"

SCRIPT_PATH="/usr/local/bin/reality_menu.sh"

# ================== 自保存 ==================
if [ ! -f "$SCRIPT_PATH" ]; then
    mkdir -p /usr/local/bin
    cp "$0" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    echo -e '#!/bin/bash\nbash /usr/local/bin/reality_menu.sh' > /usr/local/bin/b
    echo -e '#!/bin/bash\nbash /usr/local/bin/reality_menu.sh' > /usr/local/bin/B
    chmod +x /usr/local/bin/b /usr/local/bin/B
    echo -e "${green}✅ 脚本已保存到 $SCRIPT_PATH，快捷键 b/B 可用${re}"
fi

# ================== 功能函数 ==================
install_reality() {
    port=$((20000 + RANDOM % 40000))
    echo -e "${green}Reality 安装完成！端口: ${port}${re}"
}

status_reality() {
    echo -e "${yellow}Reality 正在运行 (示例)${re}"
}

change_port() {
    new_port=$((20000 + RANDOM % 40000))
    echo -e "${green}Reality 端口已修改为: ${new_port}${re}"
}

uninstall_reality() {
    echo -e "${red}Reality 已卸载${re}"
}

# ================== 菜单循环 ==================
while true; do
    echo "--------------"
    echo "1. 安装 Reality"
    echo "2. 查看 Reality 状态"
    echo "3. 更改 Reality 端口"
    echo "4. 卸载 Reality"
    echo "--------------"
    echo "0. 退出"
    echo "--------------"
    read -rp "请输入你的选择: " choice
    case $choice in
        1) install_reality ;;
        2) status_reality ;;
        3) change_port ;;
        4) uninstall_reality ;;
        0) echo "已退出脚本"; exit 0 ;;
        *) echo -e "${red}无效选项，请重新输入${re}" ;;
    esac
    echo
    read -rp "按回车返回菜单..."
done
