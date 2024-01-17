# 部署方案
用docker部署，尽量不要在原地，否则问题多到爆炸！
测试平台：osv, mirageOS
测试目标：复现论文
测试内容：网络 dns http
测试应用：memcached, mysql

部署unikernel，确保应用能跑起来
学习测试benchmark，给出一个相对精确的方案，测试极限值

## MirageOS
### 部署
<https://mirage.io/docs/install>
```bash
sudo apt-get update
sudo apt-get install opam
opam init
opam install mirage
```
因为使用OPAM包管理，所以要特别注意包的版本
```bash
$ opam --version ## response should be at least 2.1.0 viz.
2.1.2

$ ocaml -version
# if it is not 4.12.1 or higher, then run this
$ opam switch 4.13.1

$ opam install mirage
$ mirage --help

$ eval `opam config env`
# add the above line to your startup shell profile
```
```bash
[ERROR] The compilation of ocamlbuild.0.14.3 failed at "make
        check-if-preinstalled all opam-install".

#=== ERROR while compiling ocamlbuild.0.14.3 ==========================#
context     2.1.2 | linux/x86_64 | ocaml.4.13.1 | https://opam.ocaml.org#cbef5a5f
path        ~/.opam/default/.opam-switch/build/ocamlbuild.0.14.3
command     ~/.opam/opam-init/hooks/sandbox.sh build make check-if-preinstalled all opam-install
exit-code   2
env-file    ~/.opam/log/ocamlbuild-2954831-59b7cc.env
output-file ~/.opam/log/ocamlbuild-2954831-59b7cc.out
output
if test -d /usr/lib/ocaml/ocamlbuild; then\
>&2 echo "ERROR: Preinstalled ocamlbuild detected at"\
"/usr/lib/ocaml/ocamlbuild";\
>&2 echo "Installation aborted; if you want to bypass this"\
"safety check, pass CHECK_IF_PREINSTALLED=false to make";\
exit 2;\
fi
ERROR: Preinstalled ocamlbuild detected at /usr/lib/ocaml/ocamlbuild
Installation aborted; if you want to bypass this safety check, pass CHECK_IF_PREINSTALLED=false to make
make: *** [Makefile:410: check-if-preinstalled] Error 2

<><> Error report <><><><><><><><><><><><><><><><><><><><><><><><><><><>
┌─ The following actions failed
│ λ build ocamlbuild 0.14.3
└─
╶─ No changes have been performed
----------------------------------------------------------------------------------------------------
CHECK_IF_PREINSTALLED=false opam install mirage
问题解决。
miyamo@wark-i1:~/mirage-skeleton/tutorial/hello$ make
using overlay repository mirage: [opam-overlays, mirage-overlays]
Another process has locked /home/miyamo/.opam/repo/lock, waiting (C-c to abort)... ^C这个问题怎么解决
ChatGPT
这个问题表明有另一个进程正在使用或锁定 /home/miyamo/.opam/repo/lock 文件>，因此 make 命令无法继续执行。有几种可能的解决方法：
1. 等待解锁： 这个问题可能是由于其他进程正在进行操作，可以尝试等待一段时>间，然后再运行 make 命令。
2. 手动解锁： 如果确定没有其他进程在使用锁文件，可以手动删除锁文件。请小>心使用这个方法，确保没有其他正在进行的关键操作，以免引起数据损坏。
`rm /home/miyamo/.opam/repo/lock`

```

### mirage-skeleton
- tutorial/ 基础示例
- device-usage/ 特定设备示例，文件系统或者网络
- applications/ 高级示例，可能需要几个不同的设备，DHCP, DNS, and Web servers.

对于几个文件的解释
`config.ml`:一个告诉Mirage unikernel需要做什么任务的配置文件。

```bash
$ cat tutorial/noop/config.ml
let () = Mirage.register "noop" []
```
告诉unikernel入口点     
unikernel的一些工作需要通过设备与外界交互，其中包括时间设备，键值存储，块设备，网络设备。    
函子就是一个模块到一个模块的函数，允许传递依赖到unikernel当中，所以unikernel中的程序可以与外界交互，而不用考虑是建立在哪一个平台之上。   
```bash
$ cat hello/unikernel.ml
open Lwt.Infix

module Hello (Time : Mirage_time.S) = struct
  let start _time =
    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
          Logs.info (fun f -> f "hello");
          Time.sleep_ns (Duration.of_sec 1) >>= fun () ->
          loop (n-1)
    in
    loop 4

end

$ cat tutorial/hello/config.ml
open Mirage

let main =
  main "Unikernel.Hello" (time @-> job) ~packages:[ package "duration" ]

let () = register "hello" [ main $ default_time ]
```
> 主要是服务器科学上网的问题，在构建过程中需要好的网络环境不然原地去世。真让人头秃，尝试了几种方法，v2raya是我从oneitlab的那里订阅地址分享里面一>个一个粘贴过来的，本来从mojie.cyou过来点确定没反应我以为是网站问题，后来>发现是地址解析不了，我都忘了当时弄oneitlab用的哪个网址，后来解析好了还是>不行因为设置大陆白名单之类的，后来都一样了还是不行，很离谱。就算弄好了这个mirage也还是需要很长的时间，先去解决一下osv的问题。感觉现在还是没有解决网络问题，是防火墙的问题，关闭防火墙开放几个端口
```bash
miyamo@wark-i1:~/mirage-skeleton/applications/dns$ make
using overlay repository mirage: [opam-overlays, mirage-overlays]
[opam-overlays] no changes from git+https://github.com/dune-universe/opam-overlays.git
[NOTE] Repository opam-overlays has been added to the selections of switch
       default only.
       Run `opam repository add opam-overlays --all-switches|--set-default'
       to use it in all existing switches, or in newly created switches,
       respectively.

[ERROR] Could not update repository "mirage-overlays": "/usr/bin/git fetch
        -q" exited with code 128 "fatal: unable to access
        'https://github.com/dune-universe/mirage-opam-overlays.git/':
        gnutls_handshake() failed: The TLS connection was non-properly
        terminated."
[ERROR] Initial repository fetch failed
[ERROR] No repository mirage-overlays found
make[4]: *** [Makefile:18: repo-add] Error 5
make[3]: *** [Makefile:34: mirage/resolve-unix.opam.locked] Error 2
make[2]: *** [Makefile:39: lock] Error 2
make[1]: *** [Makefile:51: depends] Error 2
make: *** [Makefile:10: all] Error 2
======================================================
miyamo@wark-i1:~/mirage-skeleton/applications/dns$ make
using overlay repository mirage: [opam-overlays, mirage-overlays] 
Processing  1/1: [opam-overlays: git]
======================================================
 ↳ fetch monorepo dependencies in the duniverse folder

 ==> Using lockfile mirage/resolve-unix.opam.locked
opam-monorepo: [ERROR] Failed to pull /home/miyamo/mirage-skeleton/applications/dns/duniverse/ocaml-pbkdf: https://github.com/abeaumont/ocaml-pbkdf/archive/1.2.0.tar.gz (Curl failed: "/usr/bin/curl --write-out %{http_code}\\n --retry 3 --retry-delay 2 --user-agent opam/2.1.4 -L -o /home/miyamo/mirage-skeleton/applications/dns/duniverse/ocaml-pbkdf/1.2.0.tar.gz.part -- https://github.com/abeaumont/ocaml-pbkdf/archive/1.2.0.tar.gz" exited with code 35)
make[2]: *** [Makefile:43: pull] Error 1
make[1]: *** [Makefile:53: depends] Error 2
make: *** [Makefile:10: all] Error 2
这三个问题都是因为网络问题，不用慌。
```

1. mirage-http
这是一个http服务器
<https://github.com/mirage/mirage-skeleton/tree/main/applications/http>
```bash
$ mirage configure -t unix
$ make depends
$ ./gen.sh foo
$ mirage build
$ ./dist/minipaf --tls
```
```bash
http{,s}://localhost/：
该端点返回一个简单的 text/plain 页面。看起来是一个默认或主页端点。
http{,s}://localhost/random：
该端点需要提供一个 x-length 值，以及一个可选的 x-seed（Base64 编码）种子>，用于生成一个包含随机字节的 Base64 页面。
http{,s}://localhost/hash：
该端点需要提供 x-length 和 x-seed，然后它计算以"random"字节为基础、使用相
同种子生成的随机页面的哈希值。
http{,s}://localhost/transmit：
该端点会复制你发送的内容。
```
使用方法
```bash
$ curl -H x-length:15000 -H x-seed:Vau9IWDa4Jg= --insecure --http1.1 \
  https://localhost:4343/random | base64 -di - | sha256sum > hash.result
$ curl -H x-length:15000 -H x-seed:Vau9IWDa4Jg= --insecure --http2 \
  https://localhost:4343/hash -w "  -\n" > hash.expected
$ diff hash.result hash.expected
$ curl -H x-length:15000 -H x-seed:w3CJxsQ+deQ= https://localhost:4343/random \
  --insecure --http2 > file.txt
$ cat file.txt | curl https://localhost:4343/transmit --http1.1 -d @- \
  --insecure | base64 -d - | sha256sum > hash.0
$ curl -H x-length:15000 -H x-seed:w3CJxsQ+deQ= --insecure \
  https://localhost:4343/hash -w "  -\n" > hash.1
$ cat file.txt | base64 -di - | sha256sum > hash.2
$ diff hash.0 hash.1
$ diff hash.0 hash.2
```
这个服务器还充当了一个代理，允许HTTP 请求转发到另一个服务器。使用 curl 通过代理向 Google 发送请求的方式。以下是命令：
```bash
$ curl --proxy http://localhost:8080/ https://www.google.com/
这个命令告诉 curl 在向 https://www.google.com/ 发送请求时，通过位于 http://localhost:8080/ 的代理进行转发。
2. static_website_tls
mirage configure -t unix --net socket
make
sudo ./dist/https 
```

访问：80和443端口http://localhost   
就是一个Hello Mirage World!的大空白页
### monitoring mirage
https://hannes.robur.coop/Posts/Monitoring
https://github.com/robur-coop/dns-primary-git
我第一次接触到监控——用MRTG和munin收集和绘制指标——以及简单的网络管理协议SNMP。从整个系统的角度来看，我发现系统的监控部分不增加压力是至关重要的。这>有利于基于推送的设计，在这种设计中，报告是在系统的处置下完成的。
监控的兴起，图形是动态完成的(例如Grafana)，并且可以由操作员编程(使用查询>语言)，这非常简洁，它允许在它们被记录之后将相关指标放在一起-因此，如果有>一个论文为什么会变得疯狂，你可以从过去收集的数据中绘制图表，并证明或反驳>该论文。
从操作的角度来看，要考虑安全性——要么数据应该经过身份验证和完整性保护，要>么在专用网络上传输。我们选择了后者，有一个专用的网络接口，只用于监控。该>网络的访问权限仅授予unikernels和metrics收集器。
对于MirageOS unikernels，我们使用了metrics库——它的设计共享了日志的思想，>即只有注册了报告程序，才会执行工作。我们通过TCP使用流线协议通过Telegraf向
InfluxDB报告。但是由于指标的设计，可以开发和使用其他报告器——普罗米修斯、SNMP、您最喜欢的其他报告器都是可能的。
除了监视指标之外，我们还使用相同的网络接口通过syslog进行日志记录。由于日>志库将日志消息生成(在OCaml库中)与报告分离，因此我们开发了log -syslog，它>注册一个日志报告器，将每条日志消息发送到syslog接收器。
我们在monitoring-experiments包中开发了一个用于MirageOS单内核的指标报告的>小库，它还允许动态调整日志级别和禁用或启用指标源。
linux-native，
直接在裸机上运行的Linux内核，
应用程序的ELF二进制版本；
Linux-pv，一个运行在半虚拟化的Xen domU上的Linux内核，具有ELF二进制版本的>应用程序；
xen - direct，将应用程序构建为type - safe单一内核，直接在Xen上运行。
unix在未修改的Linux内核上作为一个正常进程运行，尽管它可能需要root权限。
hvt在Linux和FreeBSD上使用Solo5和硬件虚拟化，这需要一些设置工作，例如IP路>由。
xen要求xen在您的操作系统下运行，而Mirage将直接在xen之上运行。安装Xen并不>困难(大约20分钟)，如果您不想将主机专用于Xen，它可以方便地作为双引导环境共
存。

https://github.com/Solo5/solo5/blob/v0.6.3/docs/building.md

## OSv
https://github.com/cloudius-systems/osv/wiki
### 部署
```bash
miyamo@wark-i1:~/osv$ sudo ./scripts/run.py
OSv v0.57.0-122-gfb7ab251
Assertion failed: mmu::phys_bits <= mmu::max_phys_bits (arch/x64/arch-setup.cc: arch_setup_free_memory: 140)
Halting.
QEMU: Terminated
```
>已经排查不是因为qemu版本的问题，本来是6.2，换了7.0.0还是不work，所以需要>继续排查。
> =======================================================
```bash
# ./scripts/build -j4 fs=rofs image=native-example
root@server-f1pv6l03:~/osv# ./scripts/run.py --vnc :2
OSv v0.57.0-122-gfb7ab251
OSv v0.57.0-122-gfb7ab251
Error reading disk (real mode): 00000000000000e7
QEMU: Terminated
=======================================================
oot@server-f1pv6l03:~/osv# ./scripts/run.py -e '--bootchart /hello' --vnc :2
OSv v0.57.0-122-gfb7ab251
eth0: 192.168.122.15
        disk read (real mode): 327.42ms, (+327.42ms)
        uncompress lzloader.elf: 454.68ms, (+127.26ms)
        TLS initialization: 475.84ms, (+21.16ms)
        .init functions: 508.29ms, (+32.45ms)
                SMP launched: 523.09ms, (+14.80ms)
        VFS initialized: 690.42ms, (+167.33ms)
        Network initialized: 779.49ms, (+89.07ms)
        pvpanic done: 781.30ms, (+1.82ms)
        pci enumerated: 884.65ms, (+103.34ms)
        drivers probe: 885.28ms, (+0.64ms)
        drivers loaded: 2205.93ms, (+1320.65ms)
        ZFS mounted: 2885.86ms, (+679.93ms)
        Total time: 2915.33ms, (+29.47ms)
Cmdline: /hello
Failed to load object: /hello. Powering off.
```

### docker 部署方案
```bash
cd osv/docker
docker search osv //会看到两个build镜像；一个是fedora,另一个是ubuntu
docker build -t osv/builder-ubuntu-20.10 -f Dockerfile.builder --build-arg DIST="ubuntu-20.10" .
//！发现错误，git账号未登录
vim Dockerfile.builder
//把这一行改成
RUN git clone https://Gege-Wang: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@github.com/${GIT_ORG_OR_USER}/osv.git
//也就是加上自己的git账号和token
docker run -it --privileged osv/builder-ubuntu-20.10
//这之后你就能进入/git-repos/osv目录，在这里你可以构建OSv内核

./scripts/build -j4 image=native-example

./scripts/run.py -i /root/osv_related/osv_image/mysql.img [--vnc :2]

//如果要更新osv，则在此目录下
git pull
//如果要更新fedora/ubuntu包，则
./scripts/setup.py

cp build/last/usr.img /root/osv_related/osv_image/mysql.img 
```
尝试了native-example成功     
mysql缺少包，镜像构建不成功。    
nginx镜像构建成功，启动看起来不成功   
osv-memcached编译失败   
tomcat成功   
应用程序兼容性问题      
在linux.cc当中，syscall(long number, ...)根据系统调用号，变成了SYSCALL(fn, ...)   
是否支持动态链接   
是否支持静态链接   
是否为了支持unikernel从源码重新编译   
 
only supports a single user - with uid=0 and gid=0
单用户单应用单地址空间没有fork(),exec()家族
[] 换句话说，OSv在源代码级别上一直与linux兼容，但在二进制级别上却不兼容。
[] 大多数linux /proc/*文件在OSV上还不支持。“/dev/random”和“/dev/random”两
个路径可用。它们都是在使用Yarrow算法的FreeBSD CPRNG之上实现的。注:大多数>熵来自硬件源，例如virtio-rng;中断时序被用作软件的熵源)。
创建OSv映像需要使用Capstan或基于python的构建脚本将其内核和应用程序文件融>合在一起。
1. 查看网页
links http://localhost:2017
w3m http://localhost:2017
通过vscode可以在本地查看远程浏览器
5-level 页表问题
2. 查看是否支持5-level页表
grep 5LEVEL /boot/config-$(uname -r)
CONFIG_X86_5LEVEL=y
调试
debug模式 栈回溯不会看到内联函数
https://registry-1.docker.io/v2/osvunikernel/osv-ubuntu-20.04-builder-base/manifests/latest"
架构
[图片]
void spin_lock(spinlock_t *sl){
    sched::preempt_disable();
    while(__sync_lock_test_and_set(&sl->lock, 1)){
        while (sl->lock){
        barrier();
        }
    }
}
## 可以做的问题
ASLR：https://github.com/cloudius-systems/osv/issues/651
UEFI and AMD SEV : https://github.com/cloudius-systems/osv/issues/1098
missing library:https://github.com/cloudius-systems/osv/issues/1036
在 sqlite的运行过程中 不能使用上下键进行命令的交换，而且不能使用左右键移>动，输入正确没有给出提示，而是给出fchown() stubbed
命令不正确有时候不能通过；结束，而是结束不了了！

## 可以做的问题
ASLR：https://github.com/cloudius-systems/osv/issues/651
UEFI and AMD SEV : https://github.com/cloudius-systems/osv/issues/1098
missing library:https://github.com/cloudius-systems/osv/issues/1036
在 sqlite的运行过程中 不能使用上下键进行命令的交换，而且不能使用左右键移>动，输入正确没有给出提示，而是给出fchown() stubbed
命令不正确有时候不能通过；结束，而是结束不了了！
## HermiTux
关于二进制兼容的unikernel的测评
<https://github.com/ssrg-vt/hermitux/wiki/Documents>
为了在动态链接的二进制文件中实现快速系统调用，我们在运行时加载一个“unikernel-aware”的C库，并在内核中使用函数调用来进行系统调用调用。这个C库是一个>特殊版本的Musl libc，可以完全自动地从普通的Musl创建。这是用Coccinelle代码
转换工具完成的。要构建它并对其进行测试，请执行以下步骤。
https://github.com/ssrg-vt/hermitux#run-an-application
### docker 部署方案
https://github.com/ssrg-vt/hermitux/wiki/Docker
```bash
docker pull olivierpierre/hermitux
docker run --device=/dev/kvm -it olivierpierre/hermitux
cd apps/npb/is
# let's compile it as a static binary:
gcc *.c -o is -static
# let's launch it with HermiTux:
sudo HERMIT_ISLE=uhyve HERMIT_TUX=1 ../../../hermitux-kernel/prefix/bin/proxy \
        ../../../hermitux-kernel/prefix/x86_64-hermit/extra/tests/hermitux is

# Now let's try with a dynamically linked program:
gcc *.c -o is-dyn
# We can run it by having hermitux execute the dynamic linux loader:
sudo HERMIT_ISLE=uhyve HERMIT_TUX=1 \
        ../../../hermitux-kernel/prefix/bin/proxy \
        ../../../hermitux-kernel/prefix/x86_64-hermit/extra/tests/hermitux \
        /lib64/ld-linux-x86-64.so.2 ./is-dyn


HERMIT_ISLE=uhyve HERMIT_TUX=1 ../../hermitux-kernel/prefix/bin/proxy \
        ../../hermitux-kernel/prefix/x86_64-hermit/extra/tests/hermitux prog
```

### redis部署教程
https://github.com/ssrg-vt/hermitux/tree/master/apps/redis-2.0.4
动态链接库
step1: 安装coccinelle 这是一个代码转换工具，也就是将系统调用转换为函数调>用吗？
step2:根据不同的架构为musl libc打补丁
step3:libc需要知道系统调用实现在虚拟地址的位置。（这个位置在每次编译的时>候会发生变化，有一个脚本来生成这个信息。）
step4:编译和安装musl

### OSv启动
cfi annotations    
call frame information annotations，用于调试时调用栈的信息注解。  
通常包括 `.cfi_startproc` 代表一个函数的起始，`.cfi_endproc` 代表一个函数的结尾。   
通常用于 x86架构 的 GAS 汇编器。    
intel 汇编器使用 intel 风格的汇编， GNU 的工具链使用 AT&T 风格的汇编。    
```bash
# macros for cfi annotations

.macro pushq_cfi reg
        pushq \reg
        .cfi_adjust_cfa_offset 8
        .cfi_rel_offset \reg, 0
.endm

.macro popq_cfi reg
        popq \reg
        .cfi_adjust_cfa_offset -8
        .cfi_restore \reg
.endm
```
CR0寄存器的 WP 位写保护。当设置时，禁止管理员级程序写入只读页面;当设置为clear时，允许主管>级程序写入只读页面(与U/S位设置无关)。该标志有助于实现写时复制方法，用于创建UNIX等操作系统使用的新进程(fork)。在软件设置CR4.CET之前，必须设置此标志


## Lupine-Linux
```bash
#!/bin/bash
# this script is a wrapper to rebulid all kernels used in the paper
# base is an empty file for cleaner scripts
for app in base redis nginx; do
    ./scripts/build-with-configs.sh nopatch configs/lupine-djw-nokml.config \
        configs/apps/$app.config;
    ./scripts/build-with-configs.sh nopatch configs/lupine-djw-nokml-tiny.config \
        configs/apps/$app.config
    ./scripts/build-with-configs.sh configs/lupine-djw-kml.config \
        configs/apps/$app.config;
    ./scripts/build-with-configs.sh configs/lupine-djw-kml-tiny.config \
        configs/apps/$app.config
done
```
### docker 部署方案
`sudo docker pull hlefeuvre/lupine`
