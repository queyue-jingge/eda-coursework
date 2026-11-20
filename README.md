# EDA 实验 1-20

Quartus II 9.0 SP2 Web Edition，器件 EP1C12Q240C8，实验箱晶振 48 MHz。

每个 `expN_*` 目录是一个独立 Quartus 工程，含：

- Verilog 源码（顶层文件名与模块名一致，Quartus 9.0 的硬要求）
- `.qpf` / `.qsf` 工程文件，管脚已锁定
- 仿真用的 testbench（部分实验）
- 其余为 Quartus 工程生成文件，可删除后重编

## 重建

```bat
quartus_map  <项目名> --part=EP1C12Q240C8
quartus_fit  <项目名> --part=EP1C12Q240C8
quartus_asm  <项目名>
```

器件必须显式指定 EP1C12Q240C8，否则 Quartus 可能静默选成 Stratix II。编完核对 `fit.rpt` 的 Device 与 svf 头的 Device #1。

## 报告

`docs/` 下是各实验报告，与 `expN` 目录一一对应：

- 实验1 加法器、2 计数器、3 静态数码管、4 动态数码管、10 电子琴
- 其余实验报告在 docs 下同名文件

## 已知限制

- 实验一用 Verilog 而非原理图 bdf 输入
- 6/12/13/18/19/20 讲义无完整管脚表，部分管脚未锁
- 实验十六 ROM 128×128 放大有马赛克
- 实验十五、十七用 24 MHz 代替 25 MHz
- 实验十曲源是 MIDI 主旋律轨，裁掉开头 17.6 秒
- 实验十九、十六的严格 PLL 缺 `altpll`，需要在 Quartus 图形向导生成后补入
- 上板实测：3-7、9-11 通过；1 未回现象；14 点阵未出图；15-17 VGA 无信号；12/13 需接 ADC/DAC；18/20 未烧

## 环境

- Quartus II 9.0 SP2：`E:\altera\90sp\quartus`
- ModelSim-Altera ASE：`E:\altera\web\modelsim_ase\win32aloem`
- 烧录：USB-Blaster 驱动 + `quartus_pgm`，JTAG IDCODE `0x020830DD`

## 不纳入仓库

Quartus/ModelSim 安装包、烧录工具、虚拟机镜像、下载缓存、`db/`、`incremental_db/`、`simulation/`、`greybox_tmp/`、`.sof`/`.svf`/`.pof` 等构建产物。
