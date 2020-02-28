DOCKRE 使用笔记
================================

### 常用命令

	docker build -t myname 								# 使用此目录的 Dockerfile 创建镜像
	docker run -p 4000:80 myname						# 运行端口 4000 到 90 的“myname”映射
	docker run -d -p 4000:80 myname						# 内容相同，但在分离模式下
	docker run --name myname -d -p 4000:80 myname		# 内容相同，但在分离模式下，并指定容器名称
	docker ps											# 查看所有正在运行的容器的列表
	docker stop <hash>									# 平稳地停止指定的容器
	docker ps -a										# 查看所有容器的列表，甚至包含未运行的容器
	docker kill <hash>									# 强制关闭指定的容器
	docker kill $(docker ps -a -q)						# 强制关闭所有正在运行的容器
	docker rm <hash>									# 从此机器中删除指定的容器
	docker rm $(docker ps -a -q)						# 从此机器中删除所有容器
	docker images -a									# 显示此机器上的所有镜像
	docker rmi <imagename>								# 从此机器中删除指定的镜像
	docker rmi $(docker images -f "dangling=true" -q)	# 从此机器中删除指定 dangling 类型的镜像
	docker rmi $(docker images -q)						# 从此机器中删除所有镜像
	docker login										# 使用您的 Docker 凭证登录此 CLI 会话
	docker tag <image> username/repository:tag			# 标记 <image> 以上传到镜像库
	docker push username/repository:tag					# 将已标记的镜像上传到镜像库
	docker run username/repository:tag					# 运行镜像库中的镜像

### WIN7 下 docker 的使用

* 下载并安装 **DockerToolbox** ，参考 [Windows下运用Docker部署Node.js开发环境](https://segmentfault.com/a/1190000007955073)

* 设置环境变量（默认情况下 docker 宿主虚拟机的储存目录是在 C 盘）

		MACHINE_STORAGE_PATH=D:\docker

* 运行 **Docker Quickstart Terminal** ，提示成功后，即可在命令行中执行 docker 命令

### WIN10 下 docker 的使用（撰写中）

* 开启 Linux 子系统（Debian/Ubuntu）
* 在 Linux 子系统中安装 Docker
