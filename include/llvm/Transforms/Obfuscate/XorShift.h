#pragma once
#include <cstdint>

#ifdef _MSC_VER
#include <intrin.h>
#else
#include <x86intrin.h>
#endif

class XorShift {
public:
  XorShift() {
    s[0] = __rdtsc();
    s[1] = (uint64_t)__rdtsc() * rotl(s[0], 5);
    jump();
  }

  uint64_t next(void) {
    const uint64_t s0 = s[0];
    uint64_t s1 = s[1];
    const uint64_t result = rotl(s0 * 5, 7) * 9;

    s1 ^= s0;
    s[0] = rotl(s0, 24) ^ s1 ^ (s1 << 16);
    s[1] = rotl(s1, 37);

    return result;
  }

  uint64_t in_range(uint64_t min, uint64_t max) { return next() % (max - min) + min; }

private:
  uint64_t s[2];

  static inline uint64_t rotl(const uint64_t x, int k) {
    return (x << k) | (x >> (64 - k));
  }

  void jump(void) {
    static const uint64_t JUMP[] = {0xdf900294d8f554a5, 0x170865df4b3201fc};

    uint64_t s0 = 0;
    uint64_t s1 = 0;
    for (int i = 0; i < sizeof JUMP / sizeof *JUMP; i++)
      for (int b = 0; b < 64; b++) {
        if (JUMP[i] & UINT64_C(1) << b) {
          s0 ^= s[0];
          s1 ^= s[1];
        }
        next();
      }

    s[0] = s0;
    s[1] = s1;
  }

  void long_jump(void) {
    static const uint64_t LONG_JUMP[] = {0xd2a98b26625eee7b,
                                         0xdddf9b1090aa7ac1};

    uint64_t s0 = 0;
    uint64_t s1 = 0;
    for (int i = 0; i < sizeof LONG_JUMP / sizeof *LONG_JUMP; i++)
      for (int b = 0; b < 64; b++) {
        if (LONG_JUMP[i] & UINT64_C(1) << b) {
          s0 ^= s[0];
          s1 ^= s[1];
        }
        next();
      }

    s[0] = s0;
    s[1] = s1;
  }
};
