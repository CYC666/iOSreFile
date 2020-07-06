# CYC666学习iOS逆向留下的宝藏

# class-dump1是官网下载的，不支持swift、OC混编环境。
# class-dump是别人给的，需要修改权限777，支持swift、OC混编环境

【ssh root@10.1.1.192】WiFi登录  
【python tcprelay.py 22:10010】端口映射  
【ssh root@localhost -p 10010】登录本地端口  
【scp ~/.ssh/id_rsa.pub root@localhost:~ -P 10010】拷贝数据  
【cycript -p 进程名称】进入cycript环境  
【ps -A】查看所有进程  
【class-dump -H Mach-O文件路径 -o 头文件存放目录】反编译出头文件  
【otool -l xxx | grep crypt】查看可执行文件的加密方式  
【chmod +x /usr/bin/Clutch】修改文件权限为可执行  
【Clutch -d 序号/ID】对某个ipa进行脱壳  
【DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib ipa路径】  