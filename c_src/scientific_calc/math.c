#include "math.h"

/*
 * Reduce an angle to the first quadrant and retain the signs for its
 * original quadrant. This keeps the Taylor series inside 0 to PI/2.
 */
static float gmu_reduce_angle(float degrees, int *sin_sign, int *cos_sign)
{
    while (degrees < 0.0f) {
        degrees += 360.0f;
    }
    while (degrees >= 360.0f) {
        degrees -= 360.0f;
    }

    if (degrees <= 90.0f) {
        *sin_sign = 1;
        *cos_sign = 1;
        return degrees;
    }
    if (degrees <= 180.0f) {
        *sin_sign = 1;
        *cos_sign = -1;
        return 180.0f - degrees;
    }
    if (degrees <= 270.0f) {
        *sin_sign = -1;
        *cos_sign = -1;
        return degrees - 180.0f;
    }

    *sin_sign = -1;
    *cos_sign = 1;
    return 360.0f - degrees;
}

/* Taylor series evaluated only after quadrant reduction. */
static float gmu_sin_quadrant(float radians)
{
    float radians_squared = radians * radians;
    float term = radians;
    float result = term;

    term *= -radians_squared / 6.0f;
    result += term;
    term *= -radians_squared / 20.0f;
    result += term;
    term *= -radians_squared / 42.0f;
    result += term;
    term *= -radians_squared / 72.0f;
    result += term;
    term *= -radians_squared / 110.0f;
    result += term;
    term *= -radians_squared / 156.0f;
    result += term;

    return result;
}

static float gmu_cos_quadrant(float radians)
{
    float radians_squared = radians * radians;
    float term = 1.0f;
    float result = term;

    term *= -radians_squared / 2.0f;
    result += term;
    term *= -radians_squared / 12.0f;
    result += term;
    term *= -radians_squared / 30.0f;
    result += term;
    term *= -radians_squared / 56.0f;
    result += term;
    term *= -radians_squared / 90.0f;
    result += term;
    term *= -radians_squared / 132.0f;
    result += term;

    return result;
}

float gmu_sin(float degrees)
{
    int sin_sign;
    int cos_sign;
    float reduced_degrees;
    float radians;

    reduced_degrees = gmu_reduce_angle(degrees, &sin_sign, &cos_sign);
    radians = reduced_degrees * GMU_DEGREES_TO_RADIANS;
    (void)cos_sign;

    return (float)sin_sign * gmu_sin_quadrant(radians);
}

float gmu_cos(float degrees)
{
    int sin_sign;
    int cos_sign;
    float reduced_degrees;
    float radians;

    reduced_degrees = gmu_reduce_angle(degrees, &sin_sign, &cos_sign);
    radians = reduced_degrees * GMU_DEGREES_TO_RADIANS;
    (void)sin_sign;

    return (float)cos_sign * gmu_cos_quadrant(radians);
}

float gmu_tan(float degrees)
{
    float sine = gmu_sin(degrees);
    float cosine = gmu_cos(degrees);
    float abs_cos = cosine < 0.0f ? -cosine : cosine;

    if (abs_cos < GMU_TRIG_EPSILON) {
        return GMU_TRIG_UNDEFINED;
    }

    return sine / cosine;
}

float gmu_sec(float degrees)
{
    float cosine = gmu_cos(degrees);
    float abs_cos = cosine < 0.0f ? -cosine : cosine;

    if (abs_cos < GMU_TRIG_EPSILON) {
        return GMU_TRIG_UNDEFINED;
    }

    return 1.0f / cosine;
}

float gmu_cosec(float degrees)
{
    float sine = gmu_sin(degrees);
    float abs_sin = sine < 0.0f ? -sine : sine;

    if (abs_sin < GMU_TRIG_EPSILON) {
        return GMU_TRIG_UNDEFINED;
    }

    return 1.0f / sine;
}

float gmu_cot(float degrees)
{
    float sine = gmu_sin(degrees);
    float cosine = gmu_cos(degrees);
    float abs_sin = sine < 0.0f ? -sine : sine;

    if (abs_sin < GMU_TRIG_EPSILON) {
        return GMU_TRIG_UNDEFINED;
    }

    return cosine / sine;
}
