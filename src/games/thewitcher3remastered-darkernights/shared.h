#ifndef SRC_GAMES_DARKERNIGHTS_REMASTERED_SHARED_H_
#define SRC_GAMES_DARKERNIGHTS_REMASTERED_SHARED_H_

// Two 14-bit lighting factors in the engine's audited b12 c185.w padding.
// 8191 represents native strength exactly; 0 and 16382 are exact 0x and 2x.
#define WITCHER_NIGHT_TAG 0xD0000000u
#define WITCHER_NIGHT_TAG_MASK 0xF0000000u
#define WITCHER_NIGHT_FACTOR_MASK 0x3FFFu
#define WITCHER_NIGHT_SKY_SHIFT 14u
#define WITCHER_NIGHT_FACTOR_SCALE 8191u

// Independent moon diameter in native b12 c37.w padding. No new root binding.
#define WITCHER_MOON_TAG 0x4D4F0000u
#define WITCHER_MOON_TAG_MASK 0xFFFF0000u
#define WITCHER_MOON_FACTOR_MASK 0xFFFFu
#define WITCHER_MOON_FACTOR_SCALE 8192u

// Rain brightness in native b0 c14.w padding; no extra root binding.
#define WITCHER_RAIN_TAG 0x52410000u
#define WITCHER_RAIN_TAG_MASK 0xFFFF0000u
#define WITCHER_RAIN_FACTOR_MASK 0xFFFFu
#define WITCHER_RAIN_FACTOR_SCALE 8192u

#endif  // SRC_GAMES_DARKERNIGHTS_REMASTERED_SHARED_H_
