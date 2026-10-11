#ifndef SRC_GAMES_DARKERNIGHTS_REMASTERED_SHARED_H_
#define SRC_GAMES_DARKERNIGHTS_REMASTERED_SHARED_H_

// Two 14-bit lighting factors in the engine's audited b12 c185.w padding.
// 8191 represents native strength exactly; 0 and 16382 are exact 0x and 2x.
#define WITCHER_NIGHT_TAG 0xD0000000u
#define WITCHER_NIGHT_TAG_MASK 0xF0000000u
#define WITCHER_NIGHT_FACTOR_MASK 0x3FFFu
#define WITCHER_NIGHT_SKY_SHIFT 14u
#define WITCHER_NIGHT_FACTOR_SCALE 8191u
// Normalized cloud gains need up to 8x. Use a distinct tag to preserve the
// original precision/encoding exactly when normalization is Off.
#define WITCHER_NORMALIZED_TAG 0xE0000000u
#define WITCHER_NORMALIZED_FACTOR_SCALE 2047u

// Independent celestial diameters in native b12 padding. No new root binding.
// Moon c37.w packs a 16-bit diameter and 10-bit brightness with a 6-bit tag.
// Sun mesh c206.w retains its tagged 16-bit diameter.
#define WITCHER_MOON_TAG 0x4C000000u
#define WITCHER_MOON_TAG_MASK 0xFC000000u
#define WITCHER_MOON_BRIGHTNESS_SHIFT 16u
#define WITCHER_MOON_BRIGHTNESS_MASK 0x3FFu
#define WITCHER_MOON_BRIGHTNESS_SCALE 511u
#define WITCHER_SUN_TAG 0x53550000u
#define WITCHER_CELESTIAL_TAG_MASK 0xFFFF0000u
#define WITCHER_CELESTIAL_FACTOR_MASK 0xFFFFu
#define WITCHER_CELESTIAL_FACTOR_SCALE 8192u

// Rain brightness in native b0 c14.w padding; no extra root binding.
#define WITCHER_RAIN_TAG 0x52410000u
#define WITCHER_RAIN_TAG_MASK 0xFFFF0000u
#define WITCHER_RAIN_FACTOR_MASK 0xFFFFu
#define WITCHER_RAIN_FACTOR_SCALE 8192u

#endif  // SRC_GAMES_DARKERNIGHTS_REMASTERED_SHARED_H_
