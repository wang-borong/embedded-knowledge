# Linux 如何管理多个中断源

简而言之，Linux 通过 irq_domain 管理多个中断源中相同中断号的映射。

## irq_domain 中断编号映射库

当前设计的 Linux 内核使用单一的大数字空间，其中每个独立的 IRQ 源分配一个不同的编号。这在只有一个中断控制器时很简单，但在具有多个中断控制器的系统中，内核必须确保每个控制器都被分配了不重叠的 Linux IRQ 编号。

注册为唯一 irqchips 的中断控制器数量呈上升趋势：例如，不同类型的 GPIO 控制器的子驱动程序避免重新实现与 IRQ 核心系统相同的回调机制，通过将它们的中断处理程序建模为 irqchips，即实际上是级联中断控制器。

在这里，中断编号失去了与硬件中断编号的所有对应关系：过去，IRQ 编号可以选择与根中断控制器（即实际向 CPU 发出中断信号的组件）的硬件 IRQ 线相匹配，但现在这个编号只是一个编号。

因此，我们需要一种机制来将控制器本地的中断编号（称为硬件 irq）与 Linux IRQ 编号分开。

irq_alloc_desc*() 和 irq_free_desc*() API 提供了 IRQ 编号的分配，但它们不提供将控制器本地 IRQ（hwirq）编号反向映射到 Linux IRQ 编号空间的支持。

irq_domain 库在 irq_alloc_desc*() API 之上添加了 hwirq 和 IRQ 编号之间的映射。相对于中断控制器驱动程序自行编码反向映射方案，管理映射的 irq_domain 更为理想。

irq_domain 还实现了从抽象的 irq_fwspec 结构到 hwirq 编号的转换（目前支持设备树和 ACPI GSI），并且可以轻松扩展以支持其他 IRQ 拓扑数据源。

### irq_domain 的使用

中断控制器驱动程序通过调用一个 irq_domain_add_*() 函数创建并注册一个 irq_domain（每种映射方法有不同的分配函数，稍后会详细介绍）。该函数将在成功时返回指向 irq_domain 的指针。调用者必须为分配函数提供一个 irq_domain_ops 结构。

在大多数情况下，irq_domain 将开始时为空，没有 hwirq 和 IRQ 编号之间的映射。通过调用 irq_create_mapping() 将映射添加到 irq_domain 中，该函数接受 irq_domain 和 hwirq 编号作为参数。如果 hwirq 的映射不存在，它将分配一个新的 Linux irq_desc，将其与 hwirq 关联，并调用 .map() 回调，以便驱动程序可以执行任何必要的硬件设置。

接收到中断时，应使用 irq_find_mapping() 函数根据 hwirq 编号找到 Linux IRQ 编号。

在任何调用 irq_find_mapping() 之前，必须至少调用一次 irq_create_mapping()，否则描述符将不会被分配。

如果驱动程序有 Linux IRQ 编号或 irq_data 指针，并且需要知道关联的 hwirq 编号（例如在 irq_chip 回调中），那么可以直接从 irq_data->hwirq 获取。

### irq_domain 映射类型

有几种从 hwirq 到 Linux irq 反向映射的机制，每种机制使用不同的分配函数。应根据使用情况选择哪种反向映射类型。下面描述了每种反向映射类型：

#### 线性

```
irq_domain_add_linear()
irq_domain_create_linear()
```

线性反向映射维护一个固定大小的表，由 hwirq 编号索引。当映射一个 hwirq 时，会为 hwirq 分配一个 irq_desc，并将 IRQ 编号存储在表中。

当 hwirq 的最大数量是固定且相对较小时（大约 < 256），线性映射是一个不错的选择。该映射的优点是 IRQ 编号的查找时间是固定的，并且仅为正在使用的 IRQ 分配 irq_descs。缺点是表必须和最大可能的 hwirq 编号一样大。

irq_domain_add_linear() 和 irq_domain_create_linear() 在功能上是等价的，除了第一个参数不同 - 前者接受一个 Open Firmware 特定的 'struct device_node'，而后者接受一个更通用的抽象 'struct fwnode_handle'。

大多数驱动程序应使用线性映射。

#### 树形

```
irq_domain_add_tree()
irq_domain_create_tree()
```

irq_domain 维护一个从 hwirq 编号到 Linux IRQ 的基数树映射。当映射一个 hwirq 时，会分配一个 irq_desc，并将 hwirq 作为基数树的查找键。

当 hwirq 编号可能非常大时，树形映射是一个不错的选择，因为它不需要分配一个和最大 hwirq 编号一样大的表。缺点是 hwirq 到 IRQ 编号的查找依赖于表中的条目数量。

irq_domain_add_tree() 和 irq_domain_create_tree() 在功能上是等价的，除了第一个参数不同 - 前者接受一个 Open Firmware 特定的 'struct device_node'，而后者接受一个更通用的抽象 'struct fwnode_handle'。

很少有驱动程序需要这种映射。

#### 无映射

```
irq_domain_add_nomap()
```

无映射用于当 hwirq 编号在硬件中是可编程时。在这种情况下，最好将 Linux IRQ 编号编程到硬件中，这样就不需要映射。调用 irq_create_direct_mapping() 将分配一个 Linux IRQ 编号，并调用 .map() 回调，以便驱动程序可以将 Linux IRQ 编号编程到硬件中。

大多数驱动程序不能使用这种映射。

#### 传统

```
irq_domain_add_simple()
irq_domain_add_legacy()
irq_domain_add_legacy_isa()
```

传统映射是驱动程序已经为 hwirqs 分配了一系列 irq_desc 的特殊情况。它用于驱动程序无法立即转换为使用线性映射的情况。例如，许多嵌入式系统板支持文件使用一组 #defines 来为 struct 设备注册传递 IRQ 编号。在这种情况下，Linux IRQ 编号不能动态分配，应使用传统映射。

传统映射假设控制器已经分配了一连续范围的 IRQ 编号，并且 IRQ 编号可以通过向 hwirq 编号添加固定偏移量来计算，反之亦然。缺点是它要求中断控制器管理 IRQ 分配，并且要求为每个 hwirq 分配一个 irq_desc，即使它未被使用。

只有在必须支持固定 IRQ 映射时才应使用传统映射。例如，ISA 控制器将使用传统映射来映射 Linux IRQ 0-15，以便现有的 ISA 驱动程序获得正确的 IRQ 编号。

大多数传统映射的用户应使用 irq_domain_add_simple()，它将在系统提供 IRQ 范围时使用传统域，否则将使用线性域映射。该调用的语义是，如果指定了 IRQ 范围，则为其动态分配描述符，如果未指定范围，则会传递给 irq_domain_add_linear()，这意味着不会分配任何 irq 描述符。

简单域的典型用例是 irqchip 提供程序支持动态和静态 IRQ 分配。

为了避免出现使用线性域且没有分配描述符的情况，务必确保在任何 irq_find_mapping() 之前调用驱动程序使用的简单域调用 irq_create_mapping()，因为后者实际上适用于静态 IRQ 分配情况。

### 层次中断域

在某些架构中，可能有多个中断控制器参与从设备到目标 CPU 的中断传递路径。让我们看一下 x86 平台上的典型中断传递路径：

```
设备 --> IOAPIC -> 中断重映射控制器 -> 本地 APIC -> CPU
```

涉及三个中断控制器：

1. IOAPIC 控制器
2. 中断重映射控制器
3. 本地 APIC 控制器

为了支持这种硬件拓扑，并使软件架构与硬件架构匹配，会为每个中断控制器构建一个 irq_domain 数据结构，并将这些 irq_domain 组织成层次结构。在构建 irq_domain 层次结构时，靠近设备的 irq_domain 是子节点，靠近 CPU 的 irq_domain 是父节点。因此，将为上述示例构建如下层次结构：

```
CPU 向量 irq_domain（根 irq_domain，管理 CPU 向量）
    ^
    |
中断重映射 irq_domain（管理 irq_remapping 条目）
    ^
    |
IOAPIC irq_domain（管理 IOAPIC 传递条目/引脚）
```

使用层次 irq_domain 的四个主要接口：

1. irq_domain_alloc_irqs()：分配 IRQ 描述符和相关的中断控制器资源以传递这些中断。
2. irq_domain_free_irqs()：释放与这些中断相关联的 IRQ 描述符和中断控制器资源。
3. irq_domain_activate_irq()：激活中断控制器硬件以传递中断。
4. irq_domain_deactivate_irq()：停用中断控制器硬件以停止传递中断。

支持层

次 irq_domain 需要以下更改：

1. 在 struct irq_domain 中添加新字段 'parent'；用于维护 irq_domain 层次信息。
2. 在 struct irq_data 中添加新字段 'parent_data'；用于构建与层次 irq_domains 匹配的层次 irq_data。irq_data 用于存储 irq_domain 指针和硬件 irq 编号。
3. 在 struct irq_domain_ops 中添加新的回调以支持层次 irq_domain 操作。

通过层次 irq_domain 和层次 irq_data 的支持，将为每个中断控制器构建一个 irq_domain 结构，并为每个与 IRQ 相关的 irq_domain 分配一个 irq_data 结构。现在，我们可以进一步支持堆叠（层次）irq_chip。即，一个 irq_chip 与层次中的每个 irq_data 关联。子 irq_chip 可以自行实现所需操作，或与其父 irq_chip 合作实现。

通过堆叠 irq_chip，中断控制器驱动程序只需处理自己管理的硬件，并在需要时请求其父 irq_chip 的服务。因此，我们可以实现更清晰的软件架构。

为了使中断控制器驱动程序支持层次 irq_domain，它需要：

1. 实现 irq_domain_ops.alloc 和 irq_domain_ops.free。
2. 可选地实现 irq_domain_ops.activate 和 irq_domain_ops.deactivate。
3. 可选地实现 irq_chip 以管理中断控制器硬件。
4. 不需要实现 irq_domain_ops.map 和 irq_domain_ops.unmap，因为它们在层次 irq_domain 中未使用。

层次 irq_domain 绝不是 x86 特有的，并且被广泛用于支持其他架构，例如 ARM、ARM64 等。

### 调试

通过启用 CONFIG_GENERIC_IRQ_DEBUGFS，大多数 IRQ 子系统的内部结构都可以在 debugfs 中看到。


## 添加级联 irq_domain

```c
#define IRQ_MAX_NUM 32

/*
 * int (*alloc)(struct irq_domain *d, unsigned int virq,
 * 	     unsigned int nr_irqs, void *arg);
 * void (*free)(struct irq_domain *d, unsigned int virq,
 * 	     unsigned int nr_irqs);
 * int (*activate)(struct irq_domain *d, struct irq_data *irqd, bool reserve);
 * void (*deactivate)(struct irq_domain *d, struct irq_data *irq_data);
 * int (*translate)(struct irq_domain *d, struct irq_fwspec *fwspec,
 *			 unsigned long *out_hwirq, unsigned int *out_type);
 */
static const struct irq_domain_ops my_irq_domain_ops = {
	.alloc = my_irq_domain_alloc,
	.free = irq_domain_free_irqs_common,
	.activate = my_irq_domain_activate,
	.deactivate = my_irq_domain_deactivate,
	.translate = my_irq_domain_translate,
};

static irq_driver_probe(struct platform_device *pdev) {
  struct irq_domain *parent_domain;
  struct irq_domain *own_domain;

  // ...

	parent_np = of_irq_find_parent(dev->of_node);
	if (!parent_np)
		return -ENXIO;

	parent_domain = irq_find_host(parent_np);
	of_node_put(parent_np);
	if (!parent_domain)
		return -EPROBE_DEFER;


	own_domain = irq_domain_create_hierarchy(
					parent_domain, 0,
					IRQ_MAX_NUM,
					of_node_to_fwnode(dev->of_node),
					&my_irq_domain_ops, priv);

	if (!priv->domain)
		return -ENOMEM;

  // ...

  return 0;
}
```
