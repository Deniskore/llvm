# LLVM 13 based obfuscator

This is a new and simplified implementation of a larger project, its development began in 2014 and was used to protect software.<br/>
The project should only be used for research.


## FYI
* Take a look at [obfuscation with NAND/NOR using C++ templates](https://github.com/Deniskore/nand_nor).
* Some of these passes were originally developed for LLVM 3.x, later ported to newer versions. Therefore, all function passes **have not been properly tested** after a complete reimplementation.
* Simple VM constructor, full emulation of addition, subtraction, bit shifts, mul, div, comparison using NAND and NOR are excluded from the project. In any case, they slow down the code quite a lot.
* Machine function passes for the Intel X86 target have also been removed from the current release.

## Features

- [x] Instruction emulation with [NAND](https://en.wikipedia.org/wiki/Sheffer_stroke) / [NOR](https://en.wikipedia.org/wiki/Logical_NOR)
- [x] Random basic block splitting and reordering
- [x] Stack based branch instruction indirection
- [x] Global variable ⟶ stack migration (Only CallInst handled)


## Checkout
```console
git clone git@github.com:Deniskore/llvm.git --branch llvm_13
```
Download [Clang 13](https://github.com/llvm/llvm-project/releases) and extract it to llvm/projects directory

## Compilation requirements
The project is successfully built on Windows and Linux.

- CMake 3.13.4+
- Ninja
- LLD (For Linux, to reduce memory usage while linking)
- GCC / Clang / MSVC with full C++17

## Compilation

```console
cd llvm && mkdir build && cd build
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_FLAGS="-fuse-ld=lld" ..
cmake --build . --target clang
```

## Usage

If you want to switch to obf compiler:
```
export CC=../clang
export CXX=../clang++
```
To turn on obfuscation for a specific function, you should use the option -mllvm -obfuscate="func1,func2"
```
clang -O2 file.cpp -mllvm -obfuscate="func1,func2"
```

## Example

```C
#include <stdlib.h>
#include <stdio.h>

static const int TEST[2] = {12345789, 9876543};

int main()
{
    int test_array[32] = {};
    int a = rand();
    int b = rand();
    printf("a=%d b=%d\n", a, b);
    int g = b ^ a;
    printf("g=%d\n", g);
    if (a > g)
    {
        goto test;
    }
bla:
    printf("12345");
test:
    printf("123456");

    test_array[31] = g + a;
    test_array[30] = test_array[31];
    printf("%d %p %d\n", test_array[31], &test_array[31] + 12345, test_array[30]);
    printf("%d %d\n", TEST[0], TEST[1]);

    if (a != b)
        printf("a!=b %d %d\n", a, b);
    else
    {
        printf("a==b %d %d\n", a, b);
    }
}
```

IDA Pro 7.6 produces the following decompilation output:
```
void __fastcall main()
{
  int v0; // [rsp+5950h] [rbp+58D0h] BYREF
  char v1[16]; // [rsp+59DDh] [rbp+595Dh] BYREF
  char v2[8]; // [rsp+5A56h] [rbp+59D6h] BYREF
  char v3[8]; // [rsp+5A87h] [rbp+5A07h] BYREF
  char v4[8]; // [rsp+5AB8h] [rbp+5A38h] BYREF
  char v5[8]; // [rsp+5ADCh] [rbp+5A5Ch] BYREF
  int *v6; // [rsp+5B00h] [rbp+5A80h]

  strcpy(v2, "%d %d\n");
  strcpy(v3, "123456");
  strcpy(v4, "12345");
  strcpy(v5, "g=%d\n");
  strcpy(v1, "a=%d b=%d\n");
  v6 = &v0;
  JUMPOUT(0x14000720Fi64);
}
```
Ghidra 10.0.4:
```

/* WARNING: Function: __chkstk replaced with injection: alloca_probe */

int main(int _Argc,char **_Argv,char **_Env)

{
  int iVar1;
  undefined local_200 [141];
  undefined8 local_173;
  undefined2 local_16b;
  undefined local_169;
  undefined4 local_fa;
  undefined2 local_f6;
  undefined local_f4;
  undefined4 local_c9;
  undefined2 local_c5;
  undefined local_c3;
  undefined4 local_98;
  undefined2 local_94;
  undefined4 local_74;
  undefined2 local_70;
  undefined *local_50;
  undefined8 uStack56;
  
  uStack56 = 0x140006ea2;
  local_fa = 0x25206425;
  local_f6 = 0xa64;
  local_f4 = 0;
  local_c9 = 0x34333231;
  local_c5 = 0x3635;
  local_c3 = 0;
  local_98 = 0x34333231;
  local_94 = 0x35;
  local_74 = 0x64253d67;
  local_70 = 10;
  local_173 = 0x253d622064253d61;
  local_16b = 0xa64;
  local_169 = 0;
  local_50 = local_200;
                    /* WARNING: Could not recover jumptable at 0x00014000720c. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  iVar1 = (*(code *)0x14000720f)();
  return iVar1;
}
```

## Contributing

If you encounter an error, please try to minimize the code reproducing the problem and localize the error, then create an issue.

## Support

I have no plans to buy a Mac specifically for this project, but you can change it and then full Apple LLVM + Clang support will be added.
It is also possible that I will add new obfuscation passes.