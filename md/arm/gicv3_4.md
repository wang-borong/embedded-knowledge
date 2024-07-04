# 前言

本文档是 *GICv3 and GICv4 Software Overview* 文档翻译。
提供了对 GIC 的概述，该文档受众为软件开发人员。

## 术语与缩写

| Term | Description |
| ------------- | -------------- |
| ARE | Affinity Routing Enable |
| BPR | Binary Point Register |
| EL | Exception level (ARMv8-A) |
| EOIR | End of Interrupt Register |
| GIC | Generic Interrupt Controller |
| GICv3 | Version 3 of the Generic Interrupt Controller Architecture |
| GICv4 | Version 4 of the Generic Interrupt Controller Architecture |
| IAR | Interrupt Acknowledge Register |
| ITS | Interrupt Translation Service |
| ITT | Interrupt Translation Table |
| LPI | Locality-specific Peripheral Interrupt |
| PE | Processing element. The abstract machine defined in the␍ARM architecture, as documented in an ARM Architecture Reference Manual. See also ARM® Architecture␍Reference Manual, ARMv8, for ARMv8-A architecture profile. |
| PPI | Private Peripheral Interrupt |
| RAO/WI | Read-As-One, Writes Ignored |
| RAZ/WI | Read-As-Zero, Writes Ignored |
| SGI | Software Generated Interrupt |
| SPI | Shared Peripheral Interrupt |
| SRE | System Register Enable |
| VM  | Virtual Machine |
| vPE | Virtual PE |
| VPT | Virtual LPI Pending Table |

# GICv3 基础

# 配置 GIC

# 处理中断

# 配置 LPI

# 发送与接收 SGI

# 虚拟化

# GICv4：虚拟 LPI 直接注入
