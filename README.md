<div align="center">

# 嵌入式知识体系总结

### 从电路基础、处理器架构，到 Linux、嵌入式边缘 AI 与产品交付

一部面向真实工程闭环、持续维护的中文嵌入式系统技术书。
把分散在芯片手册、体系结构规范、Linux 文档、电路教材与项目实践中的知识，
整理成一张可以学习、查询、评审和落地的工程地图。

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC_BY--NC--SA_4.0-2f855a.svg)](LICENSE)
[![Built with OmniDoc](https://img.shields.io/badge/Built_with-OmniDoc-0891b2.svg)](#使用-omnidoc-构建)
[![Language](https://img.shields.io/badge/Language-简体中文-e11d48.svg)](#内容全景)
[![Output](https://img.shields.io/badge/Output-A4_PDF-7c3aed.svg)](#构建产物)

</div>

> 这里不是命令和名词的简单堆砌。项目更关心机制、边界、失败语义和验证证据：为什么系统这样工作，哪些假设必须显式化，怎样把原型推进到可制造、可升级、可诊断、可长期维护的产品。

## 项目概览

| 项目 | 当前情况 |
| --- | --- |
| 文档形态 | 中文 LaTeX `book`，面向 A4 PDF 阅读与归档 |
| 当前规模 | 约 926 页；最近一次 OmniDoc 1.9.1 严格构建为 926 页，页数会随内容持续变化 |
| 内容入口 | [`main.tex`](main.tex) |
| 章节组织 | [`tex/`](tex/) 下按软件、硬件、边缘 AI、工具、案例与参考资料分层 |
| 构建系统 | OmniDoc → `latexmk` → XeLaTeX |
| 项目配置 | [`.omnidoc.toml`](.omnidoc.toml) |
| 构建快照 | [`omnidoc.lock`](omnidoc.lock) |
| 默认产物 | `build/embedded-knowledge.pdf` |
| 构建报告 | `build/omnidoc-report.json` |
| 许可证 | [CC BY-NC-SA 4.0 International](LICENSE) |
| 维护状态 | 持续扩充、技术校订和排版复核 |

## 为什么做这个工程

嵌入式开发很少只属于某一个学科。一个现场问题可能同时涉及电源时序、缓存一致性、DMA、设备树、文件系统持久化、看门狗、升级状态机和生产工装。只掌握孤立 API，往往难以解释跨层故障。

本工程试图建立几条稳定主线：

- 从电路、器件和板级约束理解软件看到的硬件行为；
- 从 ISA、异常、中断、缓存、MMU 和内存序理解程序执行；
- 从 Boot ROM、Bootloader、内核到 PID 1 理解系统启动与责任交接；
- 从 RTOS、实时 Linux、异构多核和控制算法理解时序与资源边界；
- 从任务定义、数据、训练、评估、量化和运行时理解视觉模型的完整工程闭环；
- 从构建、存储、OTA、安全、测试、制造和质量理解产品全生命周期；
- 用规范引用、公式、状态机、代码示例、检查清单和验收矩阵沉淀可复用知识。

体系结构、内核、工具链、EDA 软件和芯片实现仍在演进。涉及具体寄存器、时序、电气参数、命令或软件行为时，应以目标版本的官方规范、数据手册和勘误为最终依据。

## 工程特色

- **跨层而不割裂**：把硬件、固件、Linux、应用、制造和运维放在同一工程语境中。
- **强调契约**：关注地址、时序、所有权、状态、ABI、缓存、持久化和失败恢复等边界。
- **面向量产**：不仅讨论“能运行”，也讨论掉电、老化、温度、回滚、返修、追溯和认证。
- **证据驱动**：重要结论尽量关联规范、官方文档、测试方法或可复现实验。
- **可执行的检查项**：大量章节包含设计审查、故障注入、验收矩阵和交付清单。
- **可复现构建**：入口、后端、引擎和依赖状态由 OmniDoc 配置与 lock 文件记录。
- **适合持续维护**：章节按主题拆分，正文、参考文献、图表和构建配置均纳入版本控制。

## 内容全景

| 领域 | 主要内容 |
| --- | --- |
| 电路与器件 | 电路基础、半导体、运算放大器、集成电路、FPGA、常见外设协议 |
| 板级硬件 | 电源树、时钟复位、DDR、模拟信号链、接口保护、PCB、EMC 与热设计 |
| 处理器体系结构 | Armv8-A、AArch64、RISC-V、异常、中断、缓存、MMU、内存序与多核一致性 |
| MCU 与实时固件 | Cortex-M、裸机事件模型、中断/DMA、FreeRTOS、低功耗与实时分析 |
| 采样与控制 | ADC 误差、抗混叠、数字滤波、定点运算、PID、状态估计与控制安全 |
| 启动与 Linux | Bootloader、TF-A、UEFI、启动链、Linux 内核、BSP、驱动与用户空间服务 |
| 并发与性能 | C/C++ 内存模型、原子、实时 Linux、性能分析、容量规划和尾延迟 |
| 接口、网络与时间 | API/ABI、数据协议、Ethernet、TCP/UDP、CAN FD、TSN、NTP/NTS、PTP/PHC |
| 无线与 IoT | Wi-Fi、BLE、Thread、Matter、MQTT、CoAP、LwM2M、弱网恢复与无线量产测试 |
| 异构与虚拟化 | remoteproc/RPMsg、跨核 ABI、Arm EL2、RISC-V H、KVM/Xen、virtio 与设备直通 |
| 多媒体系统 | V4L2、DRM/KMS、DMA-BUF、编解码、ALSA 与摄像头到加速器的数据通路 |
| 嵌入式边缘 AI | 视觉任务、采集与标注、真实/合成数据、训练与事件级评估、压缩导出、INT8 量化、加速器运行时、模型 CI/CD 与产品生命周期 |
| 构建、存储与更新 | Buildroot/Yocto、可复现构建、MTD/UBI/UBIFS、eMMC、掉电一致性与 A/B OTA |
| 安全与可信计算 | 威胁建模、可信启动、密钥生命周期、TrustZone、OP-TEE、TPM、DICE 与证明 |
| 功能安全与质量 | HARA、FTTI、FMEDA、免受干扰、Safety Case、环境可靠性与认证 |
| 测试与可观测性 | KUnit、kselftest、QEMU/FVP、HIL、故障注入、日志、指标、追踪和诊断包 |
| 制造与 DFT | 测试点、ICT、飞针、Boundary Scan、量产固件、校准、身份写入与追溯 |
| 工程案例与工具 | FreeRTOS、RISC-V Rust、嵌入式 Linux 设备、工装板、调试工具与 EDA 工作流 |
| 学习与参考 | 学习路线、工程模板、术语、评审清单和跨章节索引 |

## 推荐阅读路径

不必从第一页顺序阅读。可以按目标选择一条主线，再用目录和参考章节补齐背景。

### MCU / RTOS 工程师

[`Cortex-M`](tex/software/cortex-m.tex)
→ [`MCU 与 FreeRTOS`](tex/software/mcu-freertos.tex)
→ [`实时、语言与内存模型`](tex/software/realtime-language-memory-model.tex)
→ [`采样、控制与 DSP`](tex/software/sampling-control-dsp.tex)
→ 低功耗、测试和制造章节。

### 嵌入式 Linux / BSP 工程师

[`Bootloader`](tex/software/bootloader.tex)
→ [`嵌入式 Linux 启动链`](tex/software/linux-boot-chain.tex)
→ [`Linux 操作系统`](tex/software/os-linux.tex)
→ [`Linux BSP`](tex/software/linux-bsp.tex)
→ [`用户空间服务`](tex/software/linux-userspace-services.tex)
→ 构建更新、存储可靠性和现场可观测性章节。

### 处理器与底层软件工程师

[`微体系结构`](tex/software/micro-architecture.tex)
→ [`Armv8-A`](tex/software/armv8.tex)
→ [`RISC-V`](tex/software/risc-v.tex)
→ 实时内存模型
→ 异构多核、虚拟化与编译链接章节。

### 硬件与产品工程师

电路基础
→ 半导体与器件
→ 板级系统设计
→ PCB
→ 制造与 DFT
→ 产品认证、质量和可靠性章节。

### 嵌入式边缘 AI / 视觉模型工程师

[`学习路线与首个闭环`](tex/edge-ai/learning-roadmap.tex)
→ [`视觉张量、神经网络与任务建模`](tex/edge-ai/vision-foundations.tex)
→ [`数据、标签与标注工程`](tex/edge-ai/data-label-engineering.tex)
→ [`模型训练与实验管理`](tex/edge-ai/model-training.tex)
→ [`评估、选型与误差分析`](tex/edge-ai/evaluation-error-analysis.tex)
→ [`压缩、导出与整数量化`](tex/edge-ai/optimization-export-quantization.tex)
→ [`端侧加速器运行时集成`](tex/edge-ai/runtime-deployment.tex)
→ [`产品化、迭代与实战`](tex/edge-ai/product-lifecycle-projects.tex)。

### 系统、安全与交付工程师

[`系统工程方法`](tex/software/system-engineering-method.tex)
→ [`构建与更新`](tex/software/system-build-update.tex)
→ [`存储可靠性`](tex/software/storage-reliability.tex)
→ [`安全生命周期`](tex/software/security-lifecycle.tex)
→ [`可信执行与身份`](tex/software/trusted-execution-identity.tex)
→ [`测试自动化与 HIL`](tex/software/test-automation-hil.tex)。

## 仓库结构

```text
.
├── main.tex                 # 全书入口、书籍元数据和章节装配
├── .omnidoc.toml            # OmniDoc 项目与 PDF 构建配置
├── omnidoc.lock             # OmniDoc 库和工具链解析结果
├── tex/
│   ├── part-software.tex    # 软件部分目录
│   ├── part-hardware.tex    # 硬件部分目录
│   ├── part-edge-ai.tex     # 嵌入式边缘 AI 部分目录
│   ├── part-tool.tex        # 工具部分目录
│   ├── part-case-study.tex  # 工程案例目录
│   ├── part-reference.tex   # 学习与参考目录
│   ├── software/            # 系统软件、实时、网络、安全等正文
│   ├── hardware/            # 电路、器件、PCB、制造和质量正文
│   ├── edge-ai/             # 视觉模型、训练评估、量化部署与产品闭环
│   ├── case-study/          # 可落地的工程案例
│   └── reference/           # 学习路线、模板和术语
├── biblio/                  # BibLaTeX 参考文献数据库
├── figure/                  # 正文图、示意图和渲染资源
├── dac/                     # 可由 OmniDoc 重绘的结构化图描述
├── drawio/                  # Draw.io 图源
├── md/                      # 独立教程与历史技术笔记
├── image/                   # 图片和字体/符号资源
├── LICENSE                  # CC BY-NC-SA 4.0 法律全文
└── build/                   # 生成的 PDF 与构建报告，不纳入版本控制
```

`build/`、`.omnidoc-cache/` 和其他中间文件由构建过程生成。正文修改应落在源文件、参考文献或图源中，不应直接编辑生成的 PDF。

## 使用 OmniDoc 构建

### 1. 构建约定

项目配置如下：

```toml
[project]
entry = "main.tex"
from = "latex"
to = "pdf"
target = "embedded-knowledge"

[build]
outdir = "build"
outputs = ["pdf"]
latex_backend = "latexmk"

[tools]
latex_engine = "xelatex"
```

因此默认构建链为：

```text
main.tex
  └─ OmniDoc
      └─ latexmk
          └─ XeLaTeX
              └─ build/embedded-knowledge.pdf
```

[`omnidoc.lock`](omnidoc.lock) 保存上次显式写入 lock 时的解析快照；实际构建环境则应以
`omnidoc doctor` 和 `build/omnidoc-report.json` 为准。最近一次严格构建的对照如下：

| 组件 | 仓库 lock 快照 | 2026 年 8 月验证环境 |
| --- | --- | --- |
| OmniDoc / lock format | 1.6.1 / 4 | OmniDoc CLI 1.9.1 |
| omnidoc-libs | 1.6.1 | 1.9.1 |
| LaTeX engine | XeTeX / TeX Live 2026 | XeTeX / TeX Live 2026 |
| Pandoc | 3.10 | 3.10.1 |
| pandoc-crossref | 0.3.24 | 0.3.24 |

这组 1.9.1 环境已通过全量严格构建，生成 926 页 PDF，报告中的
`issues` 为空。较新的兼容 CLI/库可以完成构建，但升级库、工具链或 lock 格式仍应作为显式维护动作审查，
不应在普通内容修改中顺手写回 lock。

### 2. 获取项目

```bash
git clone https://github.com/wang-borong/embedded-knowledge.git
cd embedded-knowledge
```

### 3. 检查环境

```bash
omnidoc doctor --strict
```

该命令用于检查 OmniDoc、LaTeX 引擎、字体、Pandoc、文献工具和项目库是否可用。若检查失败，应先修复环境，不要通过删除 lock 或忽略字体错误绕过问题。

### 4. 完整构建

```bash
omnidoc build --force --report
```

这会强制重新生成 PDF，并写出机器可读构建报告。适合提交前、工具链变化后或排版复核前使用。

如需把 lint 警告也作为失败处理：

```bash
omnidoc build --strict --force --report
```

### 5. 增量构建

```bash
omnidoc build
```

输入和配置未发生影响构建的变化时，OmniDoc 会利用缓存减少重复工作。修改正文后若怀疑缓存或辅助文件导致结果异常，应重新执行完整构建。

### 6. 有意更新 lock

只有在升级 OmniDoc 库或确认工具链变化时才写回 lock：

```bash
omnidoc build --strict --force --report --write-lock
git diff -- omnidoc.lock
```

提交 lock 前应检查版本、revision、摘要和工具链变化，确认它们是预期升级，而不是本机环境漂移。

## 构建产物

成功构建后主要关注：

| 路径 | 用途 |
| --- | --- |
| `build/embedded-knowledge.pdf` | 最终 A4 PDF |
| `build/omnidoc-report.json` | 构建输入、工具链、依赖解析和问题报告 |
| `omnidoc.lock` | 受版本控制的解析结果；仅在显式更新时变化 |
| `.omnidoc-cache/` | 本地缓存，不纳入版本控制 |

建议在交付前确认：

- `omnidoc build --strict --force --report` 成功退出；
- `build/omnidoc-report.json` 中 `issues` 为空；
- PDF 页眉、页脚、目录、公式、表格、代码块和章节过渡没有裁切或重叠；
- `git diff --check` 没有空白错误；
- 生成目录和临时渲染图片没有被误加入提交。

## 常见构建问题

### 找不到字体或中文显示异常

先运行：

```bash
omnidoc doctor --strict
```

确认项目要求的中文字体与 XeLaTeX 环境可见。不要用替换成另一套字体的方式掩盖缺失，字体变化可能改变整本书的分页。

### 文献、目录或交叉引用未更新

执行完整构建：

```bash
omnidoc build --force --report
```

OmniDoc 使用 `latexmk` 驱动必要的多轮 LaTeX 和文献处理。若仍失败，可增加详细输出：

```bash
omnidoc build --force --report --verbose
```

然后检查终端错误和 `build/omnidoc-report.json`。

### 本机版本与 lock 不一致

先阅读 [`omnidoc.lock`](omnidoc.lock) 的版本和摘要。普通阅读或内容贡献不应直接删除 lock。若确实需要升级，应单独更新并验证 PDF，再提交清晰的工具链升级说明。

### PDF 已生成但版面异常

文本编译成功不代表排版正确。应渲染受影响页并检查表格、长代码块、公式、图像、页眉页脚和章节起止页；大范围结构调整还应复核目录和后续页码。

## 阅读与贡献原则

欢迎修正错误、补充证据、改进案例和排版。高质量修改通常满足以下条件：

1. **说明适用范围**：架构、芯片、内核、工具或规范版本要明确。
2. **优先引用原始资料**：规范、芯片手册、内核文档和项目官方文档优先于二手文章。
3. **区分事实与建议**：标准要求、实现行为、经验策略和教学示例不要混为一谈。
4. **给出失败语义**：不仅说明正常路径，也说明超时、掉电、损坏、回滚和恢复。
5. **保留可复现性**：命令应尽量非破坏、输入明确、输出可检查。
6. **同步参考文献**：新增重要技术结论时，补充对应 BibLaTeX 条目。
7. **完成构建与视觉检查**：技术正确和版面可读同等重要。
8. **保持提交聚焦**：内容扩写、工具链升级和大规模排版调整尽量分开提交。

发现问题可以通过 [GitHub Issues](https://github.com/wang-borong/embedded-knowledge/issues) 提交；若提供目标版本、日志、页码、规范链接或可复现实验，问题会更容易被验证和修正。

## 免责声明

本项目是一份工程知识索引、学习材料和实践总结，不替代：

- 芯片数据手册、参考手册与勘误；
- Arm、RISC-V、UEFI、Devicetree 等正式规范；
- Linux 内核与具体开源项目对应版本的官方文档；
- EMC、安规、功能安全和行业法规的正式文本；
- 由具备资质的法律、安全、认证或工程专业人员提供的意见。

示例地址、参数、命令和代码用于解释工程方法。将其用于实际产品前，必须结合目标硬件、软件版本、安全策略和适用法规重新验证。

## 许可证

除文件中另有明确说明或第三方材料受其自身条款约束外，本仓库的原创内容，包括正文、LaTeX 源码、构建配置、原创图表、工程模板和示例，统一采用：

**Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International<br>
CC BY-NC-SA 4.0**

法律全文见 [`LICENSE`](LICENSE)，官方说明见 [creativecommons.org/licenses/by-nc-sa/4.0/](https://creativecommons.org/licenses/by-nc-sa/4.0/)。

在许可证条件下，你可以为非商业目的复制、分享和改编本项目，但必须：

- **署名（BY）**：保留作者、项目名称、来源链接和许可证信息；
- **非商业（NC）**：不得将授权材料主要用于商业利益或金钱报酬；
- **相同方式共享（SA）**：公开分享改编版本时，使用相同或兼容的 BY-NC-SA 许可证；
- **标注修改**：清楚说明你修改了哪些内容；
- **不得增加限制**：不得施加妨碍后续接收者行使许可证权利的额外条款或技术措施。

建议署名格式：

```text
《嵌入式知识体系总结》
作者：王伯榕及相应贡献者
来源：https://github.com/wang-borong/embedded-knowledge
许可：CC BY-NC-SA 4.0
修改：说明所做修改及日期
```

商业使用不在本公共许可证授权范围内，需要另行获得权利人的明确许可。第三方商标、专利、隐私权、独立图片、标准文本、代码片段或其他材料的权利不会因本仓库采用 CC BY-NC-SA 4.0 而自动获得授权。

本 README 的中文说明仅用于帮助理解；如与 [`LICENSE`](LICENSE) 法律全文存在差异，以法律全文为准。
