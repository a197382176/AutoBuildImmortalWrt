#!/bin/bash
# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
echo "Include Docker: $INCLUDE_DOCKER"
# yml 传入的固件大小 ROOTFS_PARTSIZE
echo "Building for ROOTFS_PARTSIZE: $ROOTSIZE"

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."

# 定义所需安装的包列表
PACKAGES=""
PACKAGES="$PACKAGES curl"

# 简体中文包（保留不变）
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES fdisk"
PACKAGES="$PACKAGES script-utils"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"

# 新增繁體中文包
PACKAGES="$PACKAGES luci-i18n-base-zh-tw"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-tw"
PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-tw"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-tw"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-tw"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-tw"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-tw"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-tw"

# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    # 简体 Docker 管理界面
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    # 繁體 Docker 管理界面
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-tw"
    echo "Adding package: luci-i18n-dockerman-zh-cn and luci-i18n-dockerman-zh-tw"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE \
           PACKAGES="$PACKAGES" \
           FILES="/home/build/immortalwrt/files" \
           ROOTFS_PARTSIZE=$ROOTSIZE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
