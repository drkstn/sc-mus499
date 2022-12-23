// WEEK 02

// Conditional Logic
// See 'Control Structures' in Help Browser

2 == 2;
2 != 2;
2 > 3;
2 < 3;
2 <= 3;
2 >= 3;


// If

if ([0,1].choose == 0) {"0 was chosen".postln} {"1 was chosen".postln}

~func = { |input| if (input > 5) {"sine".postln} {"noise".postln} }
~func.(6)
~func.value(4)

// Case

(
~func = { |input|
	var result;
	result = case
	{input < 0} {"sine"}
	{input > 10} {"noise"}
	{true} {"sawtooth"};
	result.postln
}
)
~func.(-1)




// Receiver Notation vs. Function Call Notation

3.squared; // Receiver
squared(3); // Function Call

[1, 3, 5, 7, 9].reverse.mirror; // Receiver
mirror(reverse([1, 3, 5, 7, 9])); // Function Call




// Randomness
// See 'Randomness' in Help Browser

rrand(1, 10) // inclusive, uniform distribution,
rrand(1, 10.0) // if a param is float, returns float
rrand(200, -100)

exprand(1, 100) // tends toward the lower limit, useful for logarithmic scales like pitch
exprand(1, 100).asInteger // use .asInteger or .round to get whole number
exprand(-1, -100) // must use same sign




// Useful Audio Server Utilities

s.boot;

(
~mySound = { |freq = 400|
	SinOsc.ar(freq, 0, 0.1, 0);
};
)

~mySound.plot;

s.meter;
s.scope;
s.volume.gui;

// Show Node Tree


// Making Sound - UGens and {}.play

(
~mySound = { |freq|
	var sig;
	sig = SinOsc.ar(freq, 0, 0.1, 0);
	[sig, sig]
};
)

x = ~mySound.play(args: [\freq, 500]);
x.set(\freq, 400);
x.set(\freq, 300);
x.free;


(
{
	var sig;
	sig = PinkNoise.ar(0.3);
	[sig, sig]
}.play;
)
(
{
	var sig;
	sig = PinkNoise.ar(0.3);
	sig.dup(2)
}.play;
)
(
{
	var sig;
	sig = PinkNoise.ar(0.3);
	sig!2
}.play;
)
(
{
	var sig;
	sig = PinkNoise.ar(0.2!2); // multi-channel expansion creates two unique generators
}.play;
)
(
{
	var sig;
	sig = PinkNoise.ar(0.2)!2; // monophonic, only one generator
}.play;
)

////////////////////////////

(
~mySound = { |freq = 400|
	var sig;
	sig =
	SinOsc.ar(freq) +
	SinOsc.ar(freq * 1.01) * 0.1;
	sig!2
}.play;
)

(
~mySound = { |freq = 400|
	var sig, mod;
	mod = SinOsc.ar(0.5).range(0.2, 0.5).poll; // use poll to sample to console
	sig = WhiteNoise.ar(0.1) * mod;
	sig!2
}.play;
)
(
~mySound = { |freq = 400|
	var sig, mod;
	mod = LFPulse.ar(4).range(0.2, 0.5);
	sig = WhiteNoise.ar(0.1) * mod;
	sig!2
}.play;
)