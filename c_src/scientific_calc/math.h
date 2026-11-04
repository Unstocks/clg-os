#ifndef GMU_MATH_H
#define GMU_MATH_H

/* Mathematical constants used by the GMU calculator. */
#define GMU_PI 3.14159265358979323846f
#define GMU_DEGREES_TO_RADIANS (GMU_PI / 180.0f)

/* Return value used when a trigonometric function is undefined. */
#define GMU_TRIG_UNDEFINED 32767.0f
#define GMU_TAN_UNDEFINED GMU_TRIG_UNDEFINED
#define GMU_TRIG_EPSILON 0.0001f
#define GMU_TAN_COS_EPSILON GMU_TRIG_EPSILON

/* Public trigonometric functions accept angles in degrees. */
float gmu_sin(float degrees);
float gmu_cos(float degrees);
float gmu_tan(float degrees);
float gmu_sec(float degrees);
float gmu_cosec(float degrees);
float gmu_cot(float degrees);

#endif /* GMU_MATH_H */
