# unikernel 测评
## 基本测评
- 不修改应用程序
- 关于测评的unikernel: unikraft, mirageos, osv, HermiTux, Lupine-linux
- 关于使用的虚拟化平台：KVM, QEMU, firecracker, solo5
- 关于CPU的设置
>unikraft:禁用了超线程，并使用内核引导参数( isolcpus = 4 - 7nht)为主机隔离了4个CPU核；从剩下的4个CPU核中，我们把一个挂在VM上，另一个挂在VMM ( e.g . , qemu-system)上，另一个挂在客户端工具( e.g. , wrk或redis-benchmark)上，并设置调速器来执行。 Lupine:为了公平比较，单一内核(或客户)被限制为1个VCPU (钉扎到一个物理核心上)，因为大多数单一内核是单线程的，内存(除记忆足迹实验外)为512 MB。    

| unikernel            |             |
|----------------------|-------------|
| MirageOS             |  ✅ hello   | 
| OSv                  |  ✅ hello   |
| HermiTux             |  ✅ hello   |
| Lupine               |             |
| Unikraft             |             |
| docker               |             |
| linux                |             |
## unikernel特性
- 支持的平台
- 支持的语言
- 支持的优化方案（链接时/编译时/运行时）
- 支持的应用程序
- 支持的C库(如何验证二进制兼容性:hermitux)
## 测试准备
- 绑定CPU
- 网络
## 测试内容
- 镜像大小
【小的镜像有利于磁盘存储和快速启动？通过实验看一下相关关系】
  - 关于是否使用优化手段生成镜像
  - 加上linux二进制程序的大小
  - 平台+应用+libos

| unikernel            |   hello     |    nginx    |    redis    |sqlite       |
|----------------------|-------------|-------------|-------------|-------------|
| MirageOS             |             |             |             |             | 
| OSv                  |             |             |             |             |
| HermiTux             |             |             |             |             |
| Lupine               |             |             |             |             |
| Unikraft             |             |             |             |             |
| docker               |             |             |             |             |
| linux                |             |             |             |             |

- 启动时间
【快速实例化和VM密度，反应性和弹性】
> “The hypervisors are modified to take a timestamp right before the start of guest execution. The guest kernels are instrumented by inserting right after the kernel boot process a trap to the hypervisor which in turn takes a timestamp.” (Olivier 等, 2021, p. 7)
  - 将VMM和VM的启动时间分开
  - 确定几个应用：unikraft的测试只有helloworld

| unikernel            |firecracker  |    qemu     | qemu1nic    | qemumicrovm |
|----------------------|-------------|-------------|-------------|-------------|
| MirageOS             |             |             |             |             | 
| OSv                  |             |             |             |             |
| HermiTux             |             |             |             |             |
| Lupine               |             |             |             |             |
| Unikraft             |             |             |             |             |
| docker               |             |             |             |             |

- 内存占用
【RAM存在瓶颈情况下可以启动多少unikernel】
  - 排除VMM的内存占用
  - 使用循环迭代unikernel类型，分别运行 dichotomic_search 函数以测试不同的应用程序（hello、redis、sqlite、nginx）的最小内存情况。

| unikernel            |   hello     |    nginx    |    redis    |sqlite       |
|----------------------|-------------|-------------|-------------|-------------| 
| OSv                  |             |             |             |             |
| HermiTux             |             |             |             |             |
| Lupine               |             |             |             |             |
| Unikraft             |             |             |             |             |
| docker               |             |             |             |             |
| microvm              |             |             |             |             |
| rump                 |             |             |             |             |

- 应用吞吐量
  - 应用的选取：nginx, redis, mysql, memcached
  - 版本：unikernel支持的尽量相同版本
  - unikernel模块：说明使用的内存分配器，调度器等等，是否进行unikernel优化
  - HermiTux 不支持nginx；

| unikernel            |   redis        |    nginx    |memcached    |sqlite       |
|----------------------|----------------|-------------|-------------|-------------|
| bench                |redis-benchmark |  wrk        |    libevent |             | 
| OSv                  |                |             |             |             |
| HermiTux             |                |             |             |             |
| Lupine               |                |             |             |             |
| Unikraft             |                |             |             |             |
| docker               |                |             |             |             |
| linux                |                |             |             |             |
| rump                 |                |             |             |             |

## 测试内容（optional）
- 文件系统
  - 读写延迟
  - 不同块大小
- dns测试
- http测试
- unikernel中是否具有内存布局随机化
## 测评工具
- OSv memcached
<安装：https://www.cnblogs.com/WindSun/p/12142656.html>
/sample里面有一些样例可以学习
Libevent 是一个用C语言编写的、轻量级的开源高性能事件通知库，主要有以下几个亮点：事件驱动（ event-driven），高性能;轻量级，专注于网络，不如 ACE 那么臃肿庞大；源代码相当精炼、易读；跨平台，支持 Windows、 Linux、 *BSD 和 Mac Os；支持多种 I/O 多路复用技术， epoll、 poll、 dev/poll、 select 和 kqueue 等；支持 I/O，定时器和信号等事件；注册事件优先级。Libevent 已经被广泛的应用，作为底层的网络库；比如 memcached、 Vomit、 Nylon、 Netchat等
- redis-benchmark
## 参考文献   
[1] unikraft   
[2] HermiTux   
[3] Lupine-linux   
