# Port nor flash to linux mtd

## probe flow chart (partial)

```
physmap_flash_probe (physmap-core.c)
  do_map_probe (chipreg.c)
    drv->probe(map) (chipreg.c)
      jedec_probe (jedec_probe.c)
        mtd_do_chip_probe (gen_probe.c)
          genprobe_ident_chips (gen_probe.c)
            genprobe_new_chip(map, cp, &cfi) (gen_probe.c)
            cp->probe_chip(map, i << cfi.chipshift, chip_map, &cfi) (gen_probe.c)
```

## Flash porting example

```diff
diff --git a/drivers/mtd/chips/jedec_probe.c b/drivers/mtd/chips/jedec_probe.c
index 6f7e7e1b3fe5..aa857e441423 100644
--- a/drivers/mtd/chips/jedec_probe.c
+++ b/drivers/mtd/chips/jedec_probe.c
@@ -44,6 +44,10 @@
 #define AM29SL800DB	0x226B
 #define AM29SL800DT	0x22EA
 
+/* Spansion chip, AMD compatiable */
+#define S29GL256S	0x227E
+
+
 /* Atmel */
 #define AT49BV512	0x0003
 #define AT29LV512	0x003d
@@ -286,6 +290,8 @@ struct amd_flash_info {
 #define SIZE_2MiB   21
 #define SIZE_4MiB   22
 #define SIZE_8MiB   23
+#define SIZE_16MiB   24
+#define SIZE_32MiB   25
 
 
 /*
@@ -858,6 +864,21 @@ static const struct amd_flash_info jedec_table[] = {
 			ERASEINFO(0x02000,2),
 			ERASEINFO(0x04000,1)
 		}
+	}, {
+		.mfr_id		= CFI_MFR_AMD,
+		.dev_id		= S29GL256S,
+		.name	        = "Spansion S29GL256S90TFI02",
+		/* the flash support X8 and X16, we just use X16 here */
+		.devtypes	= CFI_DEVICETYPE_X16,
+		/* uaddr is cpu address instead of the flash address */
+		.uaddr		= MTD_UADDR_0x0AAA_0x0554,
+		.dev_size	= SIZE_32MiB,
+		.cmd_set	= P_ID_AMD_STD,
+		/* check the flash sector and memory address map in datasheet */
+		.nr_regions	= 1,
+		.regions	= {
+			ERASEINFO(0x20000,256),
+		}
 	}, {
 		.mfr_id		= CFI_MFR_HYUNDAI,
 		.dev_id		= HY29F002T,
@@ -2189,6 +2210,12 @@ static int jedec_probe_chip(struct map_info *map, __u32 base,
 	}
 	cfi_send_gen_cmd(0x90, cfi->addr_unlock1, base, map, cfi, cfi->device_type, NULL);
 	/* FIXME - should have a delay before continuing */
+	/*
+	 * We must add a delay before reading the flash IDs.
+	 * Otherwise, the flash may not read the correct IDs.
+	 * At least the S29GL256S90TFI02 flash can not.
+	 */
+	udelay(1000);
 
 	if (!cfi->numchips) {
 		/* This is the first time we're called. Set up the CFI
diff --git a/drivers/mtd/maps/Kconfig b/drivers/mtd/maps/Kconfig
index fc0aaa03c524..d010e4d16e97 100644
--- a/drivers/mtd/maps/Kconfig
+++ b/drivers/mtd/maps/Kconfig
@@ -118,6 +118,16 @@ config MTD_PHYSMAP_IXP4XX
 	  This provides some extra DT physmap parsing for the Intel IXP4xx
 	  platforms, some elaborate endianness handling in particular.
 
+config MTD_PHYSMAP_FT_PPC464
+	bool "FT PPC464 OF-based physical memory map handling"
+	depends on MTD_PHYSMAP_OF
+	select MTD_COMPLEX_MAPPINGS
+	select MTD_CFI_BE_BYTE_SWAP
+	default ARCH_FT_PPC464
+	help
+	  This provides some extra DT physmap parsing for the FT PPC464
+	  platforms, some elaborate endianness handling in particular.
+
 config MTD_PHYSMAP_GPIO_ADDR
 	bool "GPIO-assisted Flash Chip Support"
 	depends on MTD_PHYSMAP
diff --git a/drivers/mtd/maps/Makefile b/drivers/mtd/maps/Makefile
index 79f018cf412f..ff8e52c7e7ab 100644
--- a/drivers/mtd/maps/Makefile
+++ b/drivers/mtd/maps/Makefile
@@ -22,6 +22,7 @@ physmap-objs-$(CONFIG_MTD_PHYSMAP_BT1_ROM) += physmap-bt1-rom.o
 physmap-objs-$(CONFIG_MTD_PHYSMAP_VERSATILE) += physmap-versatile.o
 physmap-objs-$(CONFIG_MTD_PHYSMAP_GEMINI) += physmap-gemini.o
 physmap-objs-$(CONFIG_MTD_PHYSMAP_IXP4XX) += physmap-ixp4xx.o
+physmap-objs-$(CONFIG_MTD_PHYSMAP_FT_PPC464) += physmap-ft-ppc464.o
 physmap-objs			:= $(physmap-objs-y)
 obj-$(CONFIG_MTD_PHYSMAP)	+= physmap.o
 obj-$(CONFIG_MTD_PISMO)		+= pismo.o
diff --git a/drivers/mtd/maps/physmap-core.c b/drivers/mtd/maps/physmap-core.c
index 69d0ab1f6f94..e14579ec5303 100644
--- a/drivers/mtd/maps/physmap-core.c
+++ b/drivers/mtd/maps/physmap-core.c
@@ -44,6 +44,7 @@
 #include "physmap-bt1-rom.h"
 #include "physmap-gemini.h"
 #include "physmap-ixp4xx.h"
+#include "physmap-ft-ppc464.h"
 #include "physmap-versatile.h"
 
 struct physmap_flash_info {
@@ -389,6 +390,10 @@ static int physmap_flash_of_init(struct platform_device *dev)
 		if (err)
 			return err;
 
+		err = of_flash_probe_ppc464(dev, dp, &info->maps[i]);
+		if (err)
+			return err;
+
 		err = of_flash_probe_versatile(dev, dp, &info->maps[i]);
 		if (err)
 			return err;
diff --git a/drivers/mtd/maps/physmap-ft-ppc464.c b/drivers/mtd/maps/physmap-ft-ppc464.c
new file mode 100644
index 000000000000..523fe6c13ff4
--- /dev/null
+++ b/drivers/mtd/maps/physmap-ft-ppc464.c
@@ -0,0 +1,97 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * FT ppc464 OF physmap add-on
+ *
+ * Based on the ppc464.c map driver, originally written by:
+ * Jason wang <wangborong@cdjrlc.com>
+ */
+#include <linux/export.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/mtd/map.h>
+#include <linux/mtd/xip.h>
+#include "physmap-ft-ppc464.h"
+
+/*
+ * FT PPC464 is peculiar platform, we should swap endianness when we read
+ * or write the flash.
+ */
+
+static inline u16 flash_read16(void __iomem *addr)
+{
+	return swab16(__raw_readw((void __iomem *)((unsigned long)addr)));
+}
+
+static inline void flash_write16(u16 d, void __iomem *addr)
+{
+	__raw_writew(swab16(d), (void __iomem *)((unsigned long)addr));
+}
+
+#define	BYTE0(h)	((h) & 0xFF)
+#define	BYTE1(h)	(((h) >> 8) & 0xFF)
+
+
+static map_word ppc464_read16(struct map_info *map, unsigned long ofs)
+{
+	map_word val;
+
+	val.x[0] = flash_read16(map->virt + ofs);
+	return val;
+}
+
+/*
+ * The ppc464 expansion bus only allows 16-bit wide acceses
+ * when attached to a 16-bit wide device (such as the 28F128J3A),
+ * so we can't just memcpy_fromio().
+ */
+static void ppc464_copy_from(struct map_info *map, void *to,
+			     unsigned long from, ssize_t len)
+{
+	u8 *dest = (u8 *) to;
+	void __iomem *src = map->virt + from;
+
+	if (len <= 0)
+		return;
+
+	if (from & 1) {
+		*dest++ = BYTE1(flash_read16(src-1));
+		src++;
+		--len;
+	}
+
+	while (len >= 2) {
+		u16 data = flash_read16(src);
+		*dest++ = BYTE0(data);
+		*dest++ = BYTE1(data);
+		src += 2;
+		len -= 2;
+	}
+
+	if (len > 0)
+		*dest++ = BYTE0(flash_read16(src));
+}
+
+static void ppc464_write16(struct map_info *map, map_word d, unsigned long adr)
+{
+	flash_write16(d.x[0], map->virt + adr);
+}
+
+int of_flash_probe_ppc464(struct platform_device *pdev,
+			  struct device_node *np,
+			  struct map_info *map)
+{
+	struct device *dev = &pdev->dev;
+
+	/* Multiplatform guard */
+	if (!of_device_is_compatible(np, "ft,ppc464-flash"))
+		return 0;
+
+	map->read = ppc464_read16;
+	map->write = ppc464_write16;
+	map->copy_from = ppc464_copy_from;
+	map->copy_to = NULL;
+
+	dev_info(dev, "initialized FT ppc464-specific physmap control\n");
+
+	return 0;
+}
diff --git a/drivers/mtd/maps/physmap-ft-ppc464.h b/drivers/mtd/maps/physmap-ft-ppc464.h
new file mode 100644
index 000000000000..d364f7c1b76c
--- /dev/null
+++ b/drivers/mtd/maps/physmap-ft-ppc464.h
@@ -0,0 +1,17 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#include <linux/of.h>
+#include <linux/mtd/map.h>
+
+#ifdef CONFIG_MTD_PHYSMAP_FT_PPC464
+int of_flash_probe_ppc464(struct platform_device *pdev,
+			  struct device_node *np,
+			  struct map_info *map);
+#else
+static inline
+int of_flash_probe_ppc464(struct platform_device *pdev,
+			  struct device_node *np,
+			  struct map_info *map)
+{
+	return 0;
+}
+#endif
```

## configure kernel mtd

```
Memory Technology Device (MTD) support
  Partition parsers
    [*] Command line partition table parsing
    [*] OpenFirmware (device tree) partitioning parser
  RAM/ROM/Flash chip drivers
    [*] Detect non-CFI AMD/JEDEC-compatible flash chips
    [*] Flash chip driver advanced configuration options // ported driver, case-by-case
      Flash cmd/query data swapping (BIG_ENDIAN_BYTE)
        (x) BIG_ENDIAN_BYTE // case-by-case
      [*] Specific CFI Flash geometry selection
        [*] Support 16-bit buswidth
        [*] Support 1-chip flash interleave
    [*] Support for CFI command set 0002 (AMD/Fujitsu/Spansion chips)
  Mapping drivers for chip access
    -*- Support non-linear mappings of flash chips
    <*> Flash device in physical memory map // the default physmap has default read, write interface
      [*] Memory device in physical memory map based on OF description
      [*] FT PPC464 OF-based physical memory map handling // ported driver, case-by-case
```

## configure kernel UBI and UBIFS

```
Memory Technology Device (MTD) support
  <*> Enable UBI - Unsorted block images

Miscellaneous filesystems
  <*> UBIFS file system support
```

## How to use UBIFS

To use UBIFS, we should create an UBIFS Image, format an UBI device, attach UBI device, create UBI volumes and using UBIFS partitions.
The verbose tutorial can be got in [here](https://linuxlink.timesys.com/docs/wiki/engineering/HOWTO_Use_UBIFS).

There are two ways to create the UBIFS Image, using buildroot and manually.

### Use buildroot to create UBIFS Image

```
Filesystem images
  [*] ubi image containing an ubifs root filesystems
    (0x20000) physical eraseblock size
    (1) sub-page size
  -*- ubifs root filesystems
    (0x1ff80) logical eraseblock size
    (0x1) minimum I/O unit size
    (192) maximum logical eraseblock count
```

* physical eraseblock size: tells ubinize that physical eraseblock size of the flash chip the UBI image is created for is 128KiB.
* sub-page size: tells ubinize that the flash does not support sub-pages with 0.
* logical eraseblock size: logical eraseblock size of the UBI volume this image is created for. This value is *not* the Physical Erase Block size found in the datasheet.
* minimum I/O unit size: tells mkfs.ubifs that the minimum input/output unit size of the flash this UBIFS image is created for is 2 bytes (16-bit nor flash in this case).
* maximum logical eraseblock count: specifies maximum file-system size in logical eraseblocks; this means that it will be possible to use the resulting file-system on volumes up to this size (less or equivalent); so in this particular case, the resulting FS may be put on volumes up to about 24MiB (192 multiplied by 0x1fe00).

If you want to create an UBIFS image manually, check the [FAQ: How do I create an UBIFS image?](http://www.linux-mtd.infradead.org/faq/ubifs.html#L_mkfubifs)

**TIPS: some infos of mtd can be get by mtdinfo on your board linux, like this:**

```
# mtdinfo /dev/mtd2
mtd2
Name:                           data
Type:                           nor
Eraseblock size:                131072 bytes, 128.0 KiB
Amount of eraseblocks:          192 (25165824 bytes, 24.0 MiB)
Minimum input/output unit size: 1 byte
Sub-page size:                  1 byte
Character device major/minor:   90:4
Bad blocks are allowed:         false
Device is writable:             true 
```

After buildroot have compiled all packages and generated all images, you can get the UBIFS image from `/path/to/buildroot/output/images`.
The image file is named as `rootfs.ubifs`.

By the way, there is another image file under the same directory, it is the UBI image contains UBIFS.
You can program it to a raw flash.

### Brief steps to use ubifs

> The more detail tutorial can be found in [here](https://bootlin.com/blog/creating-flashing-ubi-ubifs-images/).

#### Format UBIFS on a booted linux system

Once you have your UBIFS image at hand, let’s sing the UBI song:

```bash
ubiformat /dev/mtdX
ubiattach -p /dev/mtdX
ubimkvol /dev/ubi0 -N volume_name -s 64MiB
ubiupdatevol /dev/ubi0_0 /path/to/ubifs.img
mount -t ubifs ubi0:volume_name /mount/point
```

ubiformat erases an MTD partition but keeps its erase counters ('X' is the number of the partition you want to use).
ubiattach creates a UBI device from the MTD partition.
This UBI device is then referred to by UBI as ubi0 (if it is the first device).
ubimkvol creates a volume on a UBI device; this volume is referred to as ubi0_0 (if it is the first volume on the device).
ubiupdatevol puts an image on an empty volume (use ubiupdatevol -t /dev/ubi0_0 to empty a volume).
At last, the well-known mount can be invoked using <device>:<volume>

#### Prepare a UBI image ready to be flashed

It is more common to directly flash filesystem images directly from the bootloader.

It is made possible by ubinize to prepare a UBI device image containing one or more volumes.

buildroot will generate the UBI image to be flashed, read the [section](#use-buildroot-to-create-ubifs-image).

You can also make an UBI image manually, as follows.

```bash
ubinize -vv -o <output image> -m <min io size>
  -p <PEB size>KiB <configuration file>
```

the configuration file example like this:

```
[rootfs_volume]
mode=ubi
image=rootfs.ubifs
vol_id=1
vol_type=static
vol_name=rootfs
vol_alignment=1

[rwdata_volume]
mode=ubi
image=data.ubifs
vol_id=2
vol_type=dynamic
vol_name=data
vol_alignment=1
vol_flags=autoresize
```

or the other example:

```
[ubifs]
mode=ubi
image=rootfs.ubifs
vol_id=0
vol_size=22MiB
vol_type=dynamic
vol_name=rootfs
vol_alignment=1
vol_flags=autoresize
```

#### Boot on the rootfs UBIFS partition

Some options need to be passed to the kernel to boot on a ubi volume and on a UBIFS partition:

```
ubi.mtd=<mtd partition number>
root=<ubi device>:<volume>
rootfstype=ubifs
```

For instance, with the previous examples and assuming the UBI device has been created/flashed on /dev/mtd1.

```ubi.mtd=1 root=ubi0:rootfs rootfstype=ubifs```

