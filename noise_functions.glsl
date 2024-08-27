#define OCTAVES 6.
#define PI 3.14159265359
#define TWOPI 6.28318530718 

uint wang_hash(inout uint seed){

    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}
 
float RandomFloat01(inout uint seed) { 
	return float(wang_hash(seed)) / 4294967296.0; 
}

vec2 RandomVec201(inout uint seed) { 
	return vec2( 	RandomFloat01(seed),
					RandomFloat01(seed)); 
}

vec3 RandomVec301(inout uint seed) { 
	return vec3( 	RandomFloat01(seed),
					RandomFloat01(seed),
					RandomFloat01(seed)); 
}

vec4 RandomVec401(inout uint seed) { 
	return vec4( 	RandomFloat01(seed),
					RandomFloat01(seed),
					RandomFloat01(seed),
					RandomFloat01(seed)); 
}

vec2 randomUnitVector2(inout uint seed){

    float a = RandomFloat01(seed) * TWOPI;
    return vec2( cos(a), sin(a) );
}

vec3 randomUnitVector3(inout uint seed){

    float z = RandomFloat01(seed) * 2.0f - 1.0f;
    float a = RandomFloat01(seed) * TWOPI;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}

float Normalize(float val) {
 	return (val + 1.) * 0.5;
}
vec3 Normalize(vec3 val) {
 	return (val + 1.) * 0.5;
}

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
	return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
	return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
	return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// The MIT License
// Copyright (C) 2011 by Ashima Arts (Simplex noise)
// Copyright (C) 2011-2016 by Stefan Gustavson (Classic noise and others)
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
float snoise(vec3 v) { 
	const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
	const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

	// First corner
	vec3 i  = floor(v + dot(v, C.yyy) );
	vec3 x0 =   v - i + dot(i, C.xxx) ;

	// Other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );

	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	vec3 x1 = x0 - i1 + C.xxx;
	vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
	vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

	// Permutations
	i = mod289(i); 
	vec4 p = permute( permute( permute( 
	     i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
	   + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
	   + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	vec3  ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);

	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );

	//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
	//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
	vec4 s0 = floor(b0)*2.0 + 1.0;
	vec4 s1 = floor(b1)*2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));

	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

	vec3 p0 = vec3(a0.xy,h.x);
	vec3 p1 = vec3(a0.zw,h.y);
	vec3 p2 = vec3(a1.xy,h.z);
	vec3 p3 = vec3(a1.zw,h.w);

	//Normalise gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value
	vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
	                        dot(p2,x2), dot(p3,x3) ) );
}

vec2 snoise2(vec3 v){
	vec3 b = vec3(v.y+12.33321, v.z+44.33229918883, v.x+91.001938843);
	return vec2(snoise(v), snoise(b));	
}

vec3 snoise3(vec3 v){
	vec3 b = vec3(v.y+12.33321, v.z+44.33229918883, v.x+91.001938843);
	vec3 c = vec3(v.z+46.32219, v.y+75.92199193884, v.x+11.028839183);
	return vec3(snoise(v), snoise(b), snoise(c));
}

vec4 snoise4(vec3 v){
	vec3 b = vec3(v.y+12.33321, v.z+44.33229918883, v.x+91.001938843);
	vec3 c = vec3(v.z+46.32219, v.y+75.92199193884, v.x+11.028839183);
	vec3 d = vec3(v.x+84.20948, v.z+31.44893820481, v.y+43.488291034);
	return vec4(snoise(v), snoise(b), snoise(c), snoise(d));
}

// Classic Perlin noise, periodic variant ____________________________________________
float pnoise(vec3 P, vec3 rep) {

	const float n_ = 0.142857142857; // 1.0/7.0
	vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
	vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
	Pi0 = mod289(Pi0);
	Pi1 = mod289(Pi1);
	vec3 Pf0 = fract(P); // Fractional part for interpolation
	vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
	vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
	vec4 iy = vec4(Pi0.yy, Pi1.yy);
	vec4 iz0 = Pi0.zzzz;
	vec4 iz1 = Pi1.zzzz;

	vec4 ixy = permute(permute(ix) + iy);
	vec4 ixy0 = permute(ixy + iz0);
	vec4 ixy1 = permute(ixy + iz1);

	vec4 gx0 = ixy0 * n_;
	vec4 gy0 = fract(floor(gx0) * n_) - 0.5;
	gx0 = fract(gx0);
	vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
	vec4 sz0 = step(gz0, vec4(0.0));
	gx0 -= sz0 * (step(0.0, gx0) - 0.5);
	gy0 -= sz0 * (step(0.0, gy0) - 0.5);

	vec4 gx1 = ixy1 * n_;
	vec4 gy1 = fract(floor(gx1) * n_) - 0.5;
	gx1 = fract(gx1);
	vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
	vec4 sz1 = step(gz1, vec4(0.0));
	gx1 -= sz1 * (step(0.0, gx1) - 0.5);
	gy1 -= sz1 * (step(0.0, gy1) - 0.5);

	vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
	vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
	vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
	vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
	vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
	vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
	vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
	vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

	vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
	g000 *= norm0.x;
	g010 *= norm0.y;
	g100 *= norm0.z;
	g110 *= norm0.w;
	vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
	g001 *= norm1.x;
	g011 *= norm1.y;
	g101 *= norm1.z;
	g111 *= norm1.w;

	float n000 = dot(g000, Pf0);
	float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
	float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
	float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
	float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
	float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
	float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
	float n111 = dot(g111, Pf1);

	vec3 fade_xyz = fade(Pf0);
	vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
	vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
	float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
	return 2.2 * n_xyz;
}

vec2 pnoise2(vec3 v, vec3 rep){
	vec3 b = vec3(v.y+12.33321, v.z+44.33229918883, v.x+91.001938843);
	return vec2(pnoise(v, rep), pnoise(b, rep));	
}

vec3 pnoise3(vec3 v, vec3 rep){
	vec3 b = vec3(v.y+12.33321, v.z+44.33229918883, v.x+91.001938843);
	vec3 c = vec3(v.z+46.32219, v.y+75.92199193884, v.x+11.028839183);
	return vec3(pnoise(v, rep), pnoise(b, rep), pnoise(c, rep));
}

vec4 pnoise4(vec3 v, vec3 rep){
	vec3 b = vec3(v.y+12.33321, v.z+44.33229918883, v.x+91.001938843);
	vec3 c = vec3(v.z+46.32219, v.y+75.92199193884, v.x+11.028839183);
	vec3 d = vec3(v.x+84.20948, v.z+31.44893820481, v.y+43.488291034);
	return vec4(pnoise(v, rep), pnoise(b, rep), pnoise(c, rep), pnoise(d, rep));
}

// Ridged multifractal terrain model. 
// Copyright 1994 F. Kenton Musgrave __________________________________________________________________________________________
float ridgedMultiFractal(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset, float gain) {
	float value = 1.0;
	float signal = 0.0;
	float pwHL = pow(abs(lacunarity), -H);
	float pwr = pwHL;
	float weight = 0.;
	signal = snoise(point * frequency);
	signal = offset - abs(signal);
	signal *= signal;
	value = signal * pwr;
	weight = 1.0;
	pwr *= pwHL;
	for(int i = 1; i < 65535; i++) {
		point *= lacunarity;
		weight = clamp(signal * gain, 0., 1.);
		signal = snoise(point * frequency);
		signal = offset - abs(signal);
		signal *= signal;
		signal *= weight;
		value += signal * pwr;
		pwr *= pwHL;
		if(i == int(octaves) - 1)
			break;
	}
 	return value;
}

vec2 ridgedMultiFractal2(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset, float gain) {

	float a = ridgedMultiFractal(point, H, lacunarity, frequency, octaves, offset, gain);
	float b = ridgedMultiFractal(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset, gain);
	return vec2(a, b);
}

vec3 ridgedMultiFractal3(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset, float gain) {

	float a = ridgedMultiFractal(point, H, lacunarity, frequency, octaves, offset, gain);
	float b = ridgedMultiFractal(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset, gain);
	float c = ridgedMultiFractal(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset, gain);
	return vec3(a, b, c);
}

vec4 ridgedMultiFractal4(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset, float gain) {

	float a = ridgedMultiFractal(point, H, lacunarity, frequency, octaves, offset, gain);
	float b = ridgedMultiFractal(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset, gain);
	float c = ridgedMultiFractal(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset, gain);
	float d = ridgedMultiFractal(point + vec3(82.48194, 321.4812331, 113.483921), H, lacunarity, frequency, octaves, offset, gain);
	return vec4(a, b, c, d);
}

// Hybrid additive/multiplicative multifractal terrain model. 
// Copyright 1994 F. Kenton Musgrave ______________________________________________________________________________________________________________
float hybridMultiFractal(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {
	float value = 1.0;
	float signal = 0.0;
	float rmd = 0.0;
	float pwHL = pow(abs(lacunarity), -H);
	float pwr = pwHL;
	float weight = 0.;
	value = pwr * (snoise(point * frequency) + offset);
	weight = value;
	point *= lacunarity;
	pwr *= pwHL;
	for(int i = 1; i < 65535; i++) {
		weight = weight > 1. ? 1. : weight;
		signal = pwr * (snoise(point * frequency) + offset);
		value += weight * signal;
		weight *= signal;
		pwr *= pwHL;
		point *= lacunarity;
		if(i == int(octaves) - 1)
			break;

	}
	rmd = octaves - floor(octaves);
	if(rmd != 0.0)
		value += (rmd * snoise(point * frequency) * pwr);
	return value;
}

vec2 hybridMultiFractal2(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = hybridMultiFractal(point, H, lacunarity, frequency, octaves, offset);
	float b = hybridMultiFractal(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	return vec2(a, b);
}

vec3 hybridMultiFractal3(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = hybridMultiFractal(point, H, lacunarity, frequency, octaves, offset);
	float b = hybridMultiFractal(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	float c = hybridMultiFractal(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset);
	return vec3(a, b, c);
}

vec4 hybridMultiFractal4(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = hybridMultiFractal(point, H, lacunarity, frequency, octaves, offset);
	float b = hybridMultiFractal(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	float c = hybridMultiFractal(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset);
	float d = hybridMultiFractal(point + vec3(82.48194, 321.4812331, 113.483921), H, lacunarity, frequency, octaves, offset);
	return vec4(a, b, c, d);
}

// Procedural multifractal 
// Ebert, D., F. K. Musgrave, D. Peachey, K. Perlin, and S. Worley. 2003. Texturing and modeling: A procedural approach, 440. Third Edition. San Francisco: Morgan Kaufmann.
float multifractalA(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {
	float value = 1.0;
	float rmd = 0.0;
	float pwHL = pow(abs(lacunarity), -H);
	float pwr = 1.0;
	for(int i = 0; i < 65535; i++) {
		value *= pwr * snoise(point * frequency) + offset;
		pwr *= pwHL;
		point *= lacunarity;
		if(i == int(octaves) - 1)
			break;
	}

	rmd = octaves - floor(octaves);
	if(rmd != 0.0)
		value += (rmd * snoise(point * frequency) * pwr);
	return value;
}

vec2 multifractalA2(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = multifractalA(point, H, lacunarity, frequency, octaves, offset);
	float b = multifractalA(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	return vec2(a, b);
}

vec3 multifractalA3(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = multifractalA(point, H, lacunarity, frequency, octaves, offset);
	float b = multifractalA(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	float c = multifractalA(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset);
	return vec3(a, b, c);
}

vec4 multifractalA4(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = multifractalA(point, H, lacunarity, frequency, octaves, offset);
	float b = multifractalA(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	float c = multifractalA(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset);
	float d = multifractalA(point + vec3(82.48194, 321.4812331, 113.483921), H, lacunarity, frequency, octaves, offset);
	return vec4(a, b, c, d);
}

// Heterogeneous procedural terrain function 
// Ebert, D., F. K. Musgrave, D. Peachey, K. Perlin, and S. Worley. 2003. Texturing and modeling: A procedural approach, 500. Third Edition. San Francisco: Morgan Kaufmann.
float heteroTerrainA(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {
	float value, increment, remainder;
	float pwrHL = pow(abs(lacunarity), -H);
	float pwr = pwrHL;
	value = offset + snoise(point * frequency);
	point *= lacunarity;
	for(int i = 1; i < 65535; i++) {
		increment = (snoise(point * frequency) + offset) * pwr * value;
		value += increment;
		point *= lacunarity;
		if(i == int(octaves))
			break;
	}
	remainder = mod(octaves, floor(octaves));
	if(remainder != 0.0) {
		increment = (snoise(point * frequency) + offset) * pwr * value;
		value += remainder * increment;
	}
	return value;
}

vec2 heteroTerrainA2(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = heteroTerrainA(point, H, lacunarity, frequency, octaves, offset);
	float b = heteroTerrainA(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	return vec2(a, b);
}

vec3 heteroTerrainA3(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = heteroTerrainA(point, H, lacunarity, frequency, octaves, offset);
	float b = heteroTerrainA(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	float c = heteroTerrainA(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset);
	return vec3(a, b, c);
}

vec4 heteroTerrainA4(vec3 point, float H, float lacunarity, float frequency, float octaves, float offset) {

	float a = heteroTerrainA(point, H, lacunarity, frequency, octaves, offset);
	float b = heteroTerrainA(point + vec3(43.29918, 122.4999382, 182.992811), H, lacunarity, frequency, octaves, offset);
	float c = heteroTerrainA(point + vec3(12.33921, 902.4894471, 233.472881), H, lacunarity, frequency, octaves, offset);
	float d = heteroTerrainA(point + vec3(82.48194, 321.4812331, 113.483921), H, lacunarity, frequency, octaves, offset);
	return vec4(a, b, c, d);
}

// Procedural fBm 
// Ebert, D., F. K. Musgrave, D. Peachey, K. Perlin, and S. Worley. 2003. Texturing and modeling: A procedural approach, 437. Third Edition. San Francisco: Morgan Kaufmann. 
float fBmA(vec3 point, float H, float lacunarity, float frequency, float octaves) {
	float value = 0.0;
	float remainder = 0.0;
	float pwrHL = pow(abs(lacunarity), -H);
	float pwr = 1.0;
	for(int i = 0; i < 65535; i++) {
		value += snoise(point * frequency) * pwr;
		pwr *= pwrHL;
		point *= lacunarity;
		if(i == int(octaves) - 1)
			break;
	}
	remainder = octaves - floor(octaves);
	if(remainder != 0.0) {
		value += remainder * snoise(point * frequency) * pwr;
	}
	return value;
}

vec2 fBmA2(vec3 point, float H, float lacunarity, float frequency, float octaves) {
	vec2 value = vec2(0.0);
	float remainder = 0.0;
	float pwrHL = pow(abs(lacunarity), -H);
	float pwr = 1.0;
	for(int i = 0; i < 65535; i++) {
		value += snoise2(point * frequency) * pwr;
		pwr *= pwrHL;
		point *= lacunarity;
		if(i == int(octaves) - 1)
			break;
	}
	remainder = octaves - floor(octaves);
	if(remainder != 0.0) {
		value += remainder * snoise2(point * frequency) * pwr;
	}
	return value;
}

vec3 fBmA3(vec3 point, float H, float lacunarity, float frequency, float octaves) {
	vec3 value = vec3(0.0);
	float remainder = 0.0;
	float pwrHL = pow(abs(lacunarity), -H);
	float pwr = 1.0;
	for(int i = 0; i < 65535; i++) {
		value += snoise3(point * frequency) * pwr;
		pwr *= pwrHL;
		point *= lacunarity;
		if(i == int(octaves) - 1)
			break;
	}
	remainder = octaves - floor(octaves);
	if(remainder != 0.0) {
		value += remainder * snoise3(point * frequency) * pwr;
	}
	return value;
}

vec2 hash2( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return fract(sin(p)*43758.5453);
}

float animate( float p, float t ) {
	return 0.5 + 0.5 * sin( t + 6.2831 * p );
}

vec2 animate2( vec2 p, float t ) {
	return 0.5 + 0.5 * sin( t + 6.2831 * p );
}

vec3 animate3( vec3 p, float t ) {
	return 0.5 + 0.5 * sin( t + 6.2831 * p );
}

float checker(vec3 point) {
	float cx = floor(2. * point.x);
	float cy = floor(2. * point.y);
	float cz = floor(point.z);
	float result = mod(cx + cy + cz, 2.0);
	return sign(result);
}

float noise_cell(vec3 point) {
	float cx = floor(2. * point.x);
	float cy = floor(2. * point.y);
	float cz = point.z;//floor(point.z);
	return snoise(vec3(cx, cy, cz));
}

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// http://www.iquilezles.org/www/articles/voronoilines/voronoilines.htm
vec3 voronoi( vec2 point, float t, float jitter) {
	vec2 n = floor(point);
	vec2 f = fract(point);
	vec2 mg, mr;
	float md = 8.0;
	for( int j=-1; j<=1; j++ ) {
		for( int i=-1; i<=1; i++ ){
			vec2 g = vec2(float(i),float(j));
			vec2 o = hash2( n + g ) * vec2(jitter);
			o = animate2(o, t);
			vec2 r = g + o - f;
			float d = dot(r,r);
			if( d<md ) {
				md = d;
				mr = r;
				mg = g;
			}
		}
	}
	md = 8.0;
	for( int j=-2; j<=2; j++ ) {
		for( int i=-2; i<=2; i++ ) {
			vec2 g = mg + vec2(float(i),float(j));
			vec2 o = hash2( n + g ) * vec2(jitter);
			o = 0.5 + 0.5*sin( t + 6.2831*o );
			vec2 r = g + o - f;
			if( dot(mr-r,mr-r)>0.00001 )
				md = min( md, dot( 0.5*(mr+r), normalize(r-mr) ) );
		}
	}
    return vec3( md, mr );
}

// The MIT License
// Copyright © 2017 Jan Forst
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
float VoronoiCrackle(vec3 pos, float multiply, float reduce, float off, float jitter) {
	vec2 w = voronoi(pos.xy, pos.z, jitter).xy;
	return max(1., (w.x) * multiply) / reduce - off;
}

vec2 VoronoiCrackle2(vec3 pos, float multiply, float reduce, float off, float jitter) {
	float a = VoronoiCrackle(pos, multiply, reduce, off, jitter);
	float b = VoronoiCrackle(pos + vec3(43.29918, 122.4999382, 182.992811), multiply, reduce, off, jitter);
	return vec2(a, b);
}

vec3 VoronoiCrackle3(vec3 pos, float multiply, float reduce, float off, float jitter) {
	float a = VoronoiCrackle(pos, multiply, reduce, off, jitter);
	float b = VoronoiCrackle(pos + vec3(43.29918, 122.4999382, 182.992811), multiply, reduce, off, jitter);
	float c = VoronoiCrackle(pos + vec3(43.29918, 122.4999382, 182.992811), multiply, reduce, off, jitter);
	return vec3(a, b, c);
}

vec4 VoronoiCrackle4(vec3 pos, float multiply, float reduce, float off, float jitter) {
	float a = VoronoiCrackle(pos, multiply, reduce, off, jitter);
	float b = VoronoiCrackle(pos + vec3(43.29918, 122.4999382, 182.992811), multiply, reduce, off, jitter);
	float c = VoronoiCrackle(pos + vec3(12.33921, 902.4894471, 233.472881), multiply, reduce, off, jitter);
	float d = VoronoiCrackle(pos + vec3(82.48194, 321.4812331, 113.483921), multiply, reduce, off, jitter);
	return vec4(a, b, c, d);
}

// The MIT License
// Copyright © 2014 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
float smoothVoronoi( vec2 x, float t, float falloff, float jitter ) {
	vec2 p = floor( x );	
	vec2  f = fract( x );
	float res = 0.0;
	for( int j=-1; j<=1; j++ ) {
		for( int i=-1; i<=1; i++ ) {
			vec2 b = vec2( i, j );
			vec2 r = vec2( b ) - f;
			vec2 o = hash2( p + b ) * vec2(jitter);
			o = animate2(o, t);
			float d = length( r + o );
			res += exp( -falloff * d );
		}
	}
	return -(1.0/falloff)*log( res );
}

vec3 hash3( vec2 p ) {
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453);
}

// The MIT License
// Copyright © 2014 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// This is a procedural pattern that has 2 parameters, that generalizes cell-noise, 
// perlin-noise and voronoi, all of which can be written in terms of the former as:
// cellnoise(x) = pattern(0,0,x)
// perlin(x) = pattern(0,1,x)
// voronoi(x) = pattern(1,0,x)
float voronoise( in vec2 x, float t, float v, float u ) {
	vec2 p = floor(x);
	vec2 f = fract(x);
	float k = 1.0+63.0*pow(1.0-v,4.0);
	float va = 0.0;
	float wt = 0.0;
	for( int j=-2; j<=2; j++ ) {
		for( int i=-2; i<=2; i++ ) {
			vec2 g = vec2( float(i), float(j) );
			vec3 o = hash3( p + g )*vec3(u,u,1.0);
			o = animate3(o, t);
			vec2 r = g - f + o.xy;
			float d = dot(r,r);
			float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
			va += o.z*ww;
			wt += ww;
		}
	}
    return va/wt;
}

// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
vec2 voronoiID( vec2 x, float t, float jitter ) {
	vec2 n = floor( x );
	vec2 f = fract( x );
	vec3 m = vec3( 8.0 );
	for( int j=-1; j<=1; j++ ) {
		for( int i=-1; i<=1; i++ ) {
			vec2  g = vec2( float(i), float(j) );
			vec2  o = hash2( n + g ) * vec2(jitter);
			vec2  r = g - f + animate2(o, t);
			float d = dot( r, r );
			if( d<m.x )
				m = vec3( d, o );
		}
	}
	return vec2( sqrt(m.x), m.y+m.z );
}

