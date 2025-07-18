#!/bin/bash
[ $EUID -ne 0 ] && { echo "请以 root 运行: sudo $0"; exit 1; }
apt update -y && apt install -y dante-server
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 6666
external: $(ip route | grep default | awk '{print $5}')
socksmethod: username
user.privileged: root
user.unprivileged: nobody
client pass { from: 0.0.0.0/0 to: 0.0.0.0/0 socksmethod: username }
socks pass { from: 0.0.0.0/0 to: 0.0.0.0/0 command: bind connect udpassociate socksmethod: username }
EOF
useradd -r -s /usr/sbin/nologin 6666
echo "6666:6666" | chpasswd
touch /var/log/danted.log
chown nobody:nogroup /var/log/danted.log
systemctl restart danted
systemctl enable danted
systemctl is-active --quiet danted || { echo "启动失败，查看日志: /var/log/danted.log"; exit 1; }
command -v ufw &> /dev/null && ufw allow 6666/tcp
echo -e "\nSOCKS5 配置：\n服务器: $(curl -s ifconfig.me)\n端口: 6666\n用户名: 6666\n密码: 6666\n\n安装完成！"
