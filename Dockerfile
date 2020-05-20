FROM centos:7
#安装epel repo，以及pip命令，之后安装supervisor和升级setuptools
#RUN rm -rf /etc/yum.repos.d/* 
#Add CentOS-Base.repo /etc/yum.repos.d/
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all && \
    yum makecache && \
    yum install -y epel-release wget && \
#    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum install -y python-pip && \
    pip install supervisor setuptools==36.7.0
#安装openssh组件和cron组件
RUN yum install -y openssh-server openssh-clients openssh cronie && \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
    #/usr/sbin/sshd -D

#暴露22号端口用于ssh连接
EXPOSE 22
#设置机器密码
RUN echo "root:root" | chpasswd
#拷贝supervisor、sshd、crond配置到相关目录
COPY supervisord.conf /etc/supervisor/
COPY supervisord_sshd.conf /etc/supervisor/
COPY supervisord_crond.conf /etc/supervisor/
#设置容器启动时执行的命令
ENTRYPOINT ["/usr/bin/supervisord", "-nc", "/etc/supervisor/supervisord.conf"]
