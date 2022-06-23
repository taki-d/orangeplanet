---
title: "GCCのmarch=nativeオプション"
date: 2017-12-14
tags: ["GCC"]
draft: false
---

どうも．先程 #GentooInstallBattle を始めました．

ところで，gccの-march=nativeオプションですが，CPUアーキテクチャに合わせた最適化をするという意味ですが，それがどんな感じに展開されてるのか気になり調べてみました．

# Version of GCC
```
$ gcc --version
gcc (GCC) 7.2.1 20171128
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```
 

# man of GCC(L:18896)

```
       -march=cpu-type
           Generate instructions for the machine type cpu-type.  In contrast to
           -mtune=cpu-type, which merely tunes the generated code for the specified cpu-
           type, -march=cpu-type allows GCC to generate code that may not run at all on
           processors other than the one indicated.  Specifying -march=cpu-type implies
           -mtune=cpu-type.

           The choices for cpu-type are:

           native
               This selects the CPU to generate code for at compilation time by
               determining the processor type of the compiling machine.  Using
               -march=native enables all instruction subsets supported by the local
               machine (hence the result might not run on different machines).  Using
               -mtune=native produces code optimized for the local machine under the
               constraints of the selected instruction set.

```
gccは  **-march=native** オプションを使用するとビルドするコンピューターのCPUでサポートされてるすべてのinstruction subsetsを使用するようにしてくれるようです．

# -march=native の展開
-E -vオプションを使えば簡単に出来ました．

### -E
```
       -E  Stop after the preprocessing stage; do not run the compiler proper.  The output
           is in the form of preprocessed source code, which is sent to the standard
           output.

           Input files that don't require preprocessing are ignored.
```

### -v
```
       -v  Print (on standard error output) the commands executed to run the stages of
           compilation.  Also print the version number of the compiler driver program and
           of the preprocessor and the compiler proper.
```

ということでどんな結果が出るのか見てみましょう．

```
$ echo | gcc -E -v -march=native - 2>&1 | grep cc1
 /usr/lib/gcc/x86_64-pc-linux-gnu/7.2.1/cc1 -E -quiet -v - -march=haswell -mmmx -mno-3dnow -msse -msse2 -msse3 -mssse3 -mno-sse4a -mcx16 -msahf -mmovbe -maes -mno-sha -mpclmul -mpopcnt -mabm -mno-lwp -mfma -mno-fma4 -mno-xop -mbmi -mno-sgx -mbmi2 -mno-tbm -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mno-rtm -mno-hle -mrdrnd -mf16c -mfsgsbase -mno-rdseed -mno-prfchw -mno-adx -mfxsr -mxsave -mxsaveopt -mno-avx512f -mno-avx512er -mno-avx512cd -mno-avx512pf -mno-prefetchwt1 -mno-clflushopt -mno-xsavec -mno-xsaves -mno-avx512dq -mno-avx512bw -mno-avx512vl -mno-avx512ifma -mno-avx512vbmi -mno-avx5124fmaps -mno-avx5124vnniw -mno-clwb -mno-mwaitx -mno-clzero -mno-pku -mno-rdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=6144 -mtune=haswell
```

こちらが平常時になります． 

```
$ echo | gcc -E -v  - 2>&1 | grep cc1
 /usr/lib/gcc/x86_64-pc-linux-gnu/7.2.1/cc1 -E -quiet -v - -mtune=generic -march=x86-64
```
上の2つを比較してあげると -march=native でどのオプションが追加されたかがわかります．

```
-march=haswell -mmmx -mno-3dnow -msse -msse2 -msse3 -mssse3 -mno-sse4a -mcx16 -msahf -mmovbe -maes -mno-sha -mpclmul -mpopcnt -mabm -mno-lwp -mfma -mno-fma4 -mno-xop -mbmi -mno-sgx -mbmi2 -mno-tbm -mavx -mavx2 -msse4.2 -msse4.1 -mlzcnt -mno-rtm -mno-hle -mrdrnd -mf16c -mfsgsbase -mno-rdseed -mno-prfchw -mno-adx -mfxsr -mxsave -mxsaveopt -mno-avx512f -mno-avx512er -mno-avx512cd -mno-avx512pf -mno-prefetchwt1 -mno-clflushopt -mno-xsavec -mno-xsaves -mno-avx512dq -mno-avx512bw -mno-avx512vl -mno-avx512ifma -mno-avx512vbmi -mno-avx5124fmaps -mno-avx5124vnniw -mno-clwb -mno-mwaitx -mno-clzero -mno-pku -mno-rdpid --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=6144 -mtune=haswell
```
ちょうど自分の環境ではこのようになります．


これだけでは面白くないのでこのオプションを生成してる部分の[ソース](https://github.com/gcc-mirror/gcc/blob/7c42fa1ff01372e69104d72809d76e386254d6ff/gcc/config/i386/driver-i386.c)
を見に行きましょう．


これの381行目 ** const char \*host_detect_local_cpu (int argc, const char \*\*argv) **で見れます．かなり気合のオプション生成をしてますので見てみると楽しいです．
AArch64では，実は内部で ** f = fopen ("/proc/cpuinfo", "r"); ** をやって ** /cpu/procinfo ** を読みに行ってて，それをゴニョゴニョしてオプションを生成してました．

** gcc/config/${arch}/driver-${arch}.c ** というような規則性があるようですので，他のアーキテクチャのオプション生成もどうやってるか見て楽しむことができそうなので，ぜひ皆さん見てみてください．



