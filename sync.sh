#!/usr/bin/env bash

# if error occured, then exit
set -e

# path
project_root_path=`pwd`
tmp_path="$project_root_path/.tmp"

if [ ! -d $tmp_path ]; then
    mkdir -p $tmp_path
fi

# git 同步 kenzok8/openwrt-packages 源码
if [ ! -d $tmp_path/kenzok8_packages ]; then
    mkdir -p $tmp_path/kenzok8_packages
    cd $tmp_path/kenzok8_packages
    git init
    git remote add origin https://github.com/kenzok8/openwrt-packages.git
    git config core.sparsecheckout true
fi
cd $tmp_path/kenzok8_packages
if [ ! -e .git/info/sparse-checkout ]; then
    touch .git/info/sparse-checkout
fi
if [ `grep -c "luci-app-passwall" .git/info/sparse-checkout` -eq 0 ]; then
    echo "luci-app-passwall" >> .git/info/sparse-checkout
fi
git pull --depth 1 origin master

# git 同步 kenzok8/small 源码
if [ ! -d $tmp_path/kenzok8_packages_libs ]; then
    mkdir -p $tmp_path/kenzok8_packages_libs
    cd $tmp_path/kenzok8_packages_libs
    git init
    git remote add origin https://github.com/kenzok8/small.git
    git config core.sparsecheckout true
fi
cd $tmp_path/kenzok8_packages_libs
if [ ! -e .git/info/sparse-checkout ]; then
    touch .git/info/sparse-checkout
fi
array_libs=(
brook
chinadns-ng
dns2socks
ipt2socks
kcptun
# openssl1.1
pdnsd-alt
shadowsocksr-libev
simple-obfs
ssocks
# syncthing
# trojan
trojan-go
trojan-plus
v2ray
v2ray-plugin
# verysync
)
for var in ${array_libs[*]}
do
    if [ `grep -c "$var" .git/info/sparse-checkout` -eq 0 ]; then
        echo "$var" >> .git/info/sparse-checkout
    fi
done
git pull --depth 1 origin master

############################################################################################

# luci-app-passwall 同步更新
if [ -d $project_root_path/luci-app-passwall ]; then
    rm -rf $project_root_path/luci-app-passwall
fi
cp -R $tmp_path/kenzok8_packages/luci-app-passwall $project_root_path/

# libs 同步更新
for var in ${array_libs[*]}
do
    if [ -d $project_root_path/$var ]; then
        rm -rf $project_root_path/$var
    fi
done
cp -R $tmp_path/kenzok8_packages_libs/* $project_root_path/

# 提交
# cd $tmp_path/kenzok8_packages
# latest_commit_id=`git rev-parse HEAD`
# latest_commit_msg=`git log --pretty=format:"%s" $current_git_branch_latest_id -1`
# echo $latest_commit_id
# echo $latest_commit_msg

cd $project_root_path
cur_time=$(date "+%Y%m%d-%H%M%S")
git add -A && git commit -m "$cur_time" && git push origin master