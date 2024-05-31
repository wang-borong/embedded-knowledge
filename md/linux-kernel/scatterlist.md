#### scatterlist 结构与 API 介绍

本节的代码介绍基于 Linux 5.10.210。

##### 结构设计

本结构体定义于 include/linux/scatterlist.h 中。

```c
struct scatterlist {
	unsigned long	page_link;
	unsigned int	offset;
	unsigned int	length;
	dma_addr_t	dma_address;
#ifdef CONFIG_NEED_SG_DMA_LENGTH
	unsigned int	dma_length;
#endif
};
```

其中，

- page_link 是指内存块所在的页。
  page_link 最低有效位的两个 bit，0 和 1 有特殊的用途，所以它指定的页要求 4 字节对齐。
- offset 指定该内存块在页中的偏移。
- length 指定该内存块的长度。
- dma_address 指定内存块的起始物理地址，用于 DMA 传输。
- dma_length 指定该物理地址的长度。

将单个 scatterlist 扩展为 scatterlist 链表，这样有助于维护所有的单个 scatterlist。
内核使用 sg_table 来维护多个 scatterlist 单元。

```c
struct sg_table {
	struct scatterlist *sgl;	/* the list */
	unsigned int nents;		/* number of mapped entries */
	unsigned int orig_nents;	/* original size of list */
};
```

其中，

- sgl 存放 scatterlist 链表头。
- nents 指示一共映射了多少 scatterlist 条目。
- orig_nents 指示原始的 scatterlist 数量。

SG table 的设计方案如下：

使用 scatterlist 结构中的 unsigned long page_link 字段来放置页面指针以及有关 sg 表的编码信息。
两个最低有效位被保留用于该信息。

- 如果设置了 bit 0，则 page_link 包含指向下一个 sg 表列表的指针。
否则，下一个条目位于 sg + 1。
- 如果设置了 bit 1，则该 sg 条目是列表中的最后一个元素。

下面的代码应证了该设计方案。

```c
/*
 * Notes on SG table design.
 *
 * We use the unsigned long page_link field in the scatterlist struct to place
 * the page pointer AND encode information about the sg table as well. The two
 * lower bits are reserved for this information.
 *
 * If bit 0 is set, then the page_link contains a pointer to the next sg
 * table list. Otherwise the next entry is at sg + 1.
 *
 * If bit 1 is set, then this sg entry is the last element in a list.
 *
 * See sg_next().
 *
 */

#define SG_CHAIN	0x01UL
#define SG_END		0x02UL

/*
 * We overload the LSB of the page pointer to indicate whether it's
 * a valid sg entry, or whether it points to the start of a new scatterlist.
 * Those low bits are there for everyone! (thanks mason :-)
 */
#define sg_is_chain(sg)		((sg)->page_link & SG_CHAIN)
#define sg_is_last(sg)		((sg)->page_link & SG_END)
#define sg_chain_ptr(sg)	\
	((struct scatterlist *) ((sg)->page_link & ~(SG_CHAIN | SG_END)))
```

##### API 介绍

关于 scatterlist 详细 API 请查阅 include/linux/scatterlist.h。
下面我们针对一些常用的 API 进行简略介绍。

```c
/**
 * sg_init_table - Initialize SG table
 * @sgl:	   The SG table
 * @nents:	   Number of entries in table
 *
 * Notes:
 *   If this is part of a chained sg table, sg_mark_end() should be
 *   used only on the last table part.
 *
 **/
void sg_init_table(struct scatterlist *sgl, unsigned int nents);
```

sg_init_table 用于初始化 SG table。

其中函数入参：

| 入参 | 类型 | 说明 |
| ------------- | -------------- | -------------- |
| sgl | struct scatterlist * | SG table 指针 |
| nents | unsigned int | table 的条目数量 |


```c
/**
 * sg_set_buf - Set sg entry to point at given data
 * @sg:		 SG entry
 * @buf:	 Data
 * @buflen:	 Data length
 *
 **/
static inline void sg_set_buf(struct scatterlist *sg, const void *buf,
			      unsigned int buflen);
```

sg_set_buf 用于设置 sg entry 所指向的 buffer。

其中函数入参：

| 入参 | 类型 | 说明 |
| ------------- | -------------- | -------------- |
| sgl | struct scatterlist * | SG entry 指针 |
| buf | const void * | buffer 地址 |
| buflen | unsigned int | buffer 长度 |

```c
/**
 * sg_init_one - Initialize a single entry sg list
 * @sg:		 SG entry
 * @buf:	 Virtual address for IO
 * @buflen:	 IO length
 *
 **/
void sg_init_one(struct scatterlist *sg, const void *buf, unsigned int buflen);
```

sg_init_one 初始化含有一个 entry 的 sg 链表。

其中函数入参：

| 入参 | 类型 | 说明 |
| --------------- | --------------- | --------------- |
| sg | struct scatterlist * | SG entry 指针 |
| buf | const void * | buffer 虚拟地址 |
| buflen | unsigned int | buffer 长度 |

```c
/*
 * Loop over each sg element, following the pointer to a new list if necessary
 */
#define for_each_sg(sglist, sg, nr, __i)	\
	for (__i = 0, sg = (sglist); __i < (nr); __i++, sg = sg_next(sg))
```

for_each_sg 用于遍历 sglist。

其中宏定义参数为：

| 参数 | 类型 | 说明 |
| --------------- | --------------- | --------------- |
| sglist | struct scatterlist * | SG 链表指针 |
| sg | struct scatterlist * | SG 成员指针 |
| nr | unsigned int | 成员数量 |
| __i | int | 遍历计数临时参数 |

