// WEEK 03

s.boot;

3 + [4,5];

(
~fn = {
	arg freq=200, offset=2, lpf=1500, amp=0.2;
	var sig;
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp;
};
)

x = ~fn.play(args: [\freq, 150, \lpf, 3000]);
x.free;




// Synth Defs

(
SynthDef.new(\saw, { |freq=200, offset=2, lpf=1500, amp=0.2, out=0|
	var sig;
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp;
	Out.ar(out, sig)
}).add;
)

x = Synth.new(\saw, [\freq, 150, \lpf, 3000]);
x.free;




// Envelopes

// 'Env' describes a shape
// 'EnvGen' is a unit generator, runs on server generating the 'Env' shape sample

(
Env.new(
	[0, 1, 0.5, 0.5, 0],
	[1, 1, 2, 1],
	[-4, 0, 0, 0,]
);
)

(
SynthDef.new(\saw, { |freq=200, offset=2, lpf=1500, amp=0.2, out=0|
	var sig, env;
	env = EnvGen.ar(
		Env.new(
			[0, 1, 0.5, 0.5, 0],
			[1, 1, 2, 1],
			[1, -2, 0, -3,]
		),
		doneAction: 2
	);
	// env = Line.ar(1, 0, 0.3, doneAction: 2); // straight line from 1 to 0
	// env = XLine.ar(1, 0.01, 2, doneAction: 2); // exp line from 1 tp 0.01, cannot go to 0
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp * env; // 'amp' and 'env' are examples of multiple levels of scaling
	Out.ar(out, sig)
}).add;
)

x = Synth.new(\saw, [\freq, 60, \lpf, 3000]);
x.free;

Window.closeAll;

(
SynthDef.new(\saw, { |freq=200, gate=1, offset=2, lpf=1500, amp=0.2, out=0|
	var sig, env;
	env = EnvGen.ar(
		Env.new(
			[0, 1, 0.5, 0],
			[1, 1, 1],
			[1, -2, -3,],
			2 // specifies the index (node) of the levels array at which to hold the note
		),
		gate, // initialize parameter so it can be dynamically 'played'
		doneAction: 2
	);
	sig = Saw.ar(freq + [0, offset]);
	sig = LPF.ar(sig, lpf);
	sig = sig * amp * env;
	Out.ar(out, sig)
}).add;
)

x = Synth.new(\saw, [\freq, 60, \lpf, 3000]);
x.set(\gate, 0); // begins release phase at defined node, finishes




// Iteration

// YUCK

x = [];

(
x = x.add(Synth.new(\saw, [\freq, 45.midicps, \lpf, 3000, \amp, 0.15]));
x = x.add(Synth.new(\saw, [\freq, 55.midicps, \lpf, 3000, \amp, 0.15]));
x = x.add(Synth.new(\saw, [\freq, 59.midicps, \lpf, 3000, \amp, 0.15]));
x = x.add(Synth.new(\saw, [\freq, 61.midicps, \lpf, 3000, \amp, 0.15]));
x = x.add(Synth.new(\saw, [\freq, 62.midicps, \lpf, 3000, \amp, 0.15]));
x = x.add(Synth.new(\saw, [\freq, 64.midicps, \lpf, 3000, \amp, 0.15]));
)

x[0].set(\gate, 0);
x[1].set(\gate, 0);
x[2].set(\gate, 0);
x[3].set(\gate, 0);
x[4].set(\gate, 0);
x[5].set(\gate, 0);

// Collect
// Iterates over an array and returns a new array

(
y = [45, 55, 59, 61, 62, 64];
x = y.collect({
	arg n;
	n.cubed;
});
)

(
~notes = [45, 55, 59, 61, 62, 64];
~synths = ~notes.collect({
	arg n;
	Synth.new(\saw, [\freq, n.midicps, \lpf, 3000, \amp, 0.15]);
});
)

(
~synths.do({
	arg n;
	n.set(\gate, 0);
});
)

// Do
// Iterates over an array and returns its receiver (its original array), side-effect

(
~synths.do({
	arg n;
	n.set(\gate, 0);
});
)

(
y = [45, 55, 59, 61, 62, 64];
x = y.collect({
	arg n;
	n.cubed;
});
)

(
y = [45, 55, 59, 61, 62, 64];
x = y.do({ // redundant, no point in returning anything from do as it is the same collection
	arg n;
	n.cubed.postln;
});

)

(1..100).do({
	"hello".postln;
});

(
y = [45, 55, 59, 61, 62, 64];
x = y.collect({
	arg n, i;
	[n.cubed, i];
});
)