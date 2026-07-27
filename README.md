# 嵌入式知识体系总结

一本面向嵌入式工程实践的长期维护型中文技术书，尝试把分散在芯片手册、体系结构规范、Linux 文档、电路教材和工程经验中的知识，整理成一张能够持续扩展的知识地图。

本书不只回答“命令怎么写”，也关注命令背后的硬件与软件机制：处理器如何执行指令，缓存和 MMU 如何影响程序，Bootloader 与 Linux 如何完成系统启动，电源、接口和 PCB 设计如何决定产品最终的可靠性。

> 当前版本于 2026 年 7 月完成一轮结构、技术内容和排版校订。体系结构、内核和 EDA 工具仍在持续演进；涉及具体寄存器、芯片参数或软件版本时，请始终以对应版本的官方手册为最终依据。

## 内容地图

| 领域 | 主要内容 |
| --- | --- |
| 处理器体系结构 | Armv8-A、AArch64、RISC-V、异常、中断、缓存、MMU、内存序、多核一致性、安全与调试 |
| 实时固件 | MCU 启动、裸机事件模型、中断与 DMA、实时调度、FreeRTOS 内核对象与低功耗 |
| 实时分析与语言 | 响应时间分析、EDF、WCET、C/C++ 内存模型、Rust unsafe、原子、MMIO 与 DMA |
| 系统软件 | Boot ROM 至 PID 1 启动链、Linux 内核与用户空间、BSP、标准子系统驱动、编译链接与程序装载 |
| 用户空间服务 | 进程边界、Unix Socket、D-Bus、事件循环、服务管理、权限、容器与健康管理 |
| 接口与数据契约 | API/ABI、消息封装、字节序、schema 演进、幂等、背压、持久格式与兼容测试 |
| 实时与异构 | FreeRTOS、PREEMPT_RT、实时调度与准入、IRQ/softirq、CPU/housekeeping 隔离、延迟追踪、remoteproc、RPMsg 与跨核 ABI |
| 采样与控制 | ADC 误差、抗混叠、数字滤波、定点运算、PID、状态估计与控制安全 |
| 系统交付 | Buildroot/Yocto、只读根文件系统、MTD/UBI/UBIFS、eMMC/RPMB、fsync/flush、掉电一致性、可复现构建与 A/B OTA |
| 网络与时间 | Ethernet 数据路径、TCP/UDP、CAN FD、TSN、Linux 时钟域、NTP/NTS、PTP/PHC、硬件时间戳与同步验收 |
| 无线与 IoT | 链路预算与共存、Wi-Fi/BLE/Thread/Matter、MQTT/CoAP/LwM2M、设备影子、弱网恢复、安全通道与无线量产测试 |
| 质量与安全 | 威胁建模、安全需求、可信启动、默认安全、SBOM 与供应链、PSIRT 与漏洞响应、密钥轮换、安全更新和退役处置 |
| 现场运维 | 结构化日志、指标、分布式追踪、崩溃证据、诊断包、设备管理与分批发布 |
| 可信计算 | TrustZone、OP-TEE、PMP、TPM、安全元件、DICE、可信存储、Measured Boot、证明证据、背书、Reference Value、隐私与验收 |
| 功能安全 | Item/HARA、安全目标与 FTTI、FMEDA 与共因失效、免受干扰、黑通道、SEooC、Safety Case、Proof Test 和量化验收 |
| 多媒体与 AI | Media Controller、V4L2、DRM/KMS、DMA-BUF/fence、编解码、ALSA 与音画同步、端侧 AI 契约、多模型调度、热稳态和量化验收 |
| 虚拟化与隔离 | Arm EL2/RISC-V H、二阶段页表、vCPU 调度、虚拟时间、KVM/Xen、virtio、VFIO/IOMMU、设备直通、混合关键性与量化验收 |
| 性能与容量 | SLO、分位数、排队、CPU/PMU、内存与 DDR、I/O、热稳态、容量预算与回归门 |
| 低功耗系统 | 功耗与能量预算、状态收支、MCU 深睡与 Tickless、Linux runtime PM/suspend、CPUIdle/DVFS、异构唤醒、板级漏电与波形验收 |
| 测试工程 | KUnit、kselftest、LTP、软件在环、QEMU、FVP、HIL、电源循环、故障注入、长稳与工装校准 |
| 二进制工程 | 目标 ABI、链接脚本、启动代码、LTO、ELF/DWARF、二进制分析与可复现构建 |
| 电路与器件 | 电路基础、半导体器件、运算放大器、集成电路、FPGA、常见外设协议 |
| 硬件工程 | 电源树与时序、时钟复位、DDR、接口保护、模拟信号链、PCB、EMC 与制造输出 |
| 制造与 DFT | 测试点、ICT、飞针、Boundary Scan、量产固件、校准、身份写入与追溯 |
| 认证与质量 | EMC、安规、环境可靠性、EVT/DVT/PVT、GR&R、SPC、RMA 与 FRACAS |
| 功率与电机 | MOSFET、Gate Driver、PWM、电流采样、六步换相、FOC、保护、热与 EMC |
| 系统工程 | 需求、架构视图、接口契约、资源预算、ADR、变更影响与完成定义 |
| 学习与参考 | MCU、Linux BSP、复杂 SoC 和硬件制造学习路径，工程模板、评审清单与统一术语约定 |
| 工程实践 | 多平台 FreeRTOS、RISC-V Rust 内核、嵌入式 Linux 专用设备与多工位工装板 |
| 工程工具 | Linux 命令行、调试与性能分析、OrCAD、Altium Designer、KiCad 与 SPICE |

## 适合谁阅读

- 希望建立系统知识框架的嵌入式软件或固件工程师；
- 需要理解软硬件边界的 Linux、驱动、Bootloader 和 BSP 开发者；
- 正在从单片机开发走向复杂 SoC、Arm 或 RISC-V 平台的学习者；
- 希望快速回顾电路、PCB、体系结构和系统软件基础的工程师。

本书是一份工程知识索引和学习笔记，不替代芯片数据手册、Arm/RISC-V 架构规范、Linux 内核文档、电气标准或 EDA 厂商文档。

## 使用 OmniDoc 构建

项目由 OmniDoc 管理，入口和构建参数保存在 `.omnidoc.toml`。推荐使用 OmniDoc 1.5.1 与 omnidoc-libs 1.2.1 或更新的兼容版本。

```bash
# 检查本机 LaTeX、字体和 OmniDoc 库
omnidoc doctor --strict

# 生成 build/embedded-knowledge.pdf
omnidoc build --force --report --write-lock

# 内容未变化时使用增量构建
omnidoc build
```

主要目录：

```text
main.tex       书籍入口、元数据与章节组织
tex/           LaTeX 正文和项目级排版主题
biblio/        参考文献数据库
figure/        正文插图
dac/           可由 OmniDoc 重绘的位域图描述
build/         构建产物与诊断报告（不提交）
```

## 阅读与贡献原则

- 技术结论尽量注明适用架构、软件版本和前提条件；
- 命令示例优先采用可复现、非破坏性的写法；
- 对性能、时序和电气参数使用“典型值”时，应同时说明它们依赖具体实现；
- 发现错误或过时内容时，欢迎提交带有规范、手册或可复现实验依据的修正。

## 许可说明

仓库当前的 `LICENSE` 文件为 GNU GPL v3；书籍正文中的版权声明采用 CC BY-NC-SA 4.0。两者分别约束工程源码/构建材料与可阅读内容。转载、修改或再发行前，请核对目标文件中的版权声明；如需调整整个仓库的许可方式，应同步更新 `LICENSE` 和书内声明，避免产生歧义。
