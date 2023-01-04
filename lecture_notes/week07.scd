// WEEK 07

s.boot;

// Load samples

(
var path, subfolders;
b = ();
path = thisProcess.nowExecutingPath.dirname;
subfolders = PathName(path +/+ "week07_audio/").entries;
subfolders.do({
	arg dir;
	var bufArray;
	bufArray = dir.entries.collect({
		arg file;
		Buffer.readChannel(s, file.fullPath, channels:[0]) // all files will be loaded as monophonic
	});
	b[dir.folderName.asSymbol] = bufArray;
});
)

// Test samples

b.class;
b.keys;
b.flute.class;
b.flute.size;
b.flute[0].class;
b.flute[4].play;
b.glitch.choose.play;
b.wood.choose.play;

// PlayBuf SynthDef

(
SynthDef.new(\play, {
	arg buf=0, rate=1, spos=0, loop=0, atk=0, sus=0.2, rel=0.2,
	lp=20000, hp=20, pan=0, amp=1, out=0;
	var sig, env;
	sig = PlayBuf.ar(
		1, buf, BufRateScale.ir(buf) * rate,
		startPos: spos, loop: loop
	);
	sig = LPF.ar(sig, lp);
	sig = HPF.ar(sig, hp);
	env = EnvGen.ar(
		Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),
		doneAction:2
	);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

Synth(\play, [\buf, b[\flute].choose,\rate, rrand(-12,12).midiratio]);

// Routines

(
var bufNum = b[\flute][0];

~f = {
	Synth(\play, [\buf, bufNum, \rate, 6.midiratio]);
	Synth(\play, [\buf, bufNum, \rate, 8.midiratio]);
	Synth(\play, [\buf, bufNum, \rate, 11.midiratio]);
};
)

~f.();

//// The below is the same as above

(
var bufNum = b[\flute][0];

~r = Routine.new({
	Synth(\play, [\buf, bufNum, \rate, 6.midiratio]);
	Synth(\play, [\buf, bufNum, \rate, 8.midiratio]);
	Synth(\play, [\buf, bufNum, \rate, 11.midiratio]);
});
)

~r.play;

//// With wait times (wait times are equivalent to beats)

(
var bufNum = b[\flute][0];

~r = Routine.new({
	Synth(\play, [\buf, bufNum, \rate, 6.midiratio]);
	1.wait;
	Synth(\play, [\buf, bufNum, \rate, 8.midiratio]);
	1.wait;
	Synth(\play, [\buf, bufNum, \rate, 11.midiratio]);
	1.wait;
});
)

~r.play;
~r.reset;
~r.next;

//// Simplified notes

(
~r = Routine.new({
	[6,8,11].do({ |note|
		Synth(\play, [\buf, b[\flute][0], \rate, note.midiratio]);
		(1/4).wait; // OR 0.25.wait;
	});
});
)

~r.reset;
~r.play;
~r.stop;

//// Simplified with random notes and infinitely repeating

(
~r = Routine.new({
	inf.do({
		Synth(\play, [\buf, b[\flute][0], \rate, rrand(-12,12).midiratio]);
		(1/4).wait; // OR 0.25.wait;
	});
});
)

~r.reset.play;
~r.stop;

//// Nesting routines

(
~r = Routine.new({
	4.do({
		[6,8,11,4].do({
			arg note;
			Synth(\play, [\buf, b[\flute][0], \rate, note.midiratio]);
			0.2.wait;
		});
	});

	3.do({
		[3,4,6].do({
			arg note;
			Synth(\play, [\buf, b[\flute][0], \rate, note.midiratio]);
			0.2.wait;
		});
	});
});
)

~r.reset.play;

//// Using routines to generate numbers or other data
////// The below example is like a sequence generator

(
~noteGen = Routine.new({
	inf.do({
		[-7,-2,0,2,7,3,2,3,5].do({
			arg n;
			n.wait;
		});
	});
});
)

~noteGen.next;
~noteGen.nextN(2);

~noteGen.reset;

(
~r = Routine.new({
	inf.do({
		Synth(\play, [\buf, b[\flute][0], \rate, ~noteGen.next.midiratio]);
		[0.125,0.25].choose.wait;
	});
});
)

~r.reset.play;

~r.stop;

////// Using the above to do the below, for semi-random sequencing

(
~seqGen = Routine.new({
	var arr = Array.fill(8, {rrand(0, 1)});
	inf.do({
		arr.do({
			arg n;
			n.wait;
		});
	});
});
)

~seqGen.next;
~seqGen.nextN(4);
// Store sequence for later use
~pattern = ~seqGen.nextN(4);
~pattern;

~seqGen.reset;

//// Another routine example

(
~r = Routine.new({
	inf.do({
		Synth(\play, [
			\buf, b[\flute][0],
			\rate, ~noteGen.next.midiratio * rrand(0.97, 1.03) / 2,
			\spos, rrand(0, 2000),
			\lpf, exprand(4000, 20000),
			\sus, 0,
			\rel, exprand(0.05, 0.4),
		]);
		[0.125,0.25].choose.wait;
	});
});
)

~r.reset.play;
~r.stop;

///////////////////////////////////////////////////

// Patterns

//// Like prepackaged routine recipes

(
// A pattern is a recipe/blueprint for sequence, not the sequence itself
p = Pseq([-7,-2,0,2,7,3,2,3,5], inf);
// A stream/routine represents the actualization of that pattern
~noteGen = p.asStream;
)

~noteGen.next;
p.next;

// When given a number, restarts like #.do routine

(
p = Pseq([-7,-2,0,2,7,3,2,3,5], 2);
~noteGen = p.asStream;
)

~noteGen.next;

(
p = Pseq([\sin, \saw, \play], inf);
~seq = p.asStream;
)

~seq.next;

// Prand, fully random

(
p = Prand([3,6,9,10], inf);
~seq = p.asStream;
)

~seq.next;

// Pxrand, will not select the same index in a row

(
p = Pxrand([3,6,9,10], inf);
~seq = p.asStream;
)

~seq.next;

// Pwrand, selects based on weights contained in 2nd array

(
p = Pwrand([3,6,9,10], [2,5,6,30].normalizeSum, inf); // normalizeSum recalculates array to sum to 1
~seq = p.asStream;
)

~seq.nextN(100);

// Pshuf, randomizes order and repeats it

(
p = Pshuf([1,2,3,4,5,6], inf);
~seq = p.asStream;
)

~seq.nextN(24);

// Randomizes order on every loop, ensuring that each item gets played at least once
//// Nice example of how nesting works

(
p = Pseq([ Pshuf([1,2,3,4,5,6], 1) ], inf);
~seq = p.asStream;
)

~seq.nextN(24);

// Negative values between -1 and 1, but no control over the pattern of pos/neg

(
p = Pwhite(-1.0, 1.0, inf);
~seq = p.asStream;
)

~seq.nextN(20);

// Same as above, but with pos/neg pattern applied to alternate

(
p = Pwhite(0.0, 1.0, inf) * Pseq([-1,1], inf);
~seq = p.asStream;
)

~seq.nextN(100);

//rrand
(
p = Pwhite(0, 10.0, inf);
~seq = p.asStream;
)

~seq.nextN(100);

//exprand
(
// p = Pexprand(1, 100, inf).round;
p = Pexprand(1, 100, inf).asInteger;
~seq = p.asStream;
)

~seq.nextN(100);

(
p = Pseries(0, -1, inf);
~seq = p.asStream;
)

~seq.nextN(100);

(
p = Pseq((0,-1..-99), 1);
~seq = p.asStream;
)

~seq.nextN(100);

// The below works well for amplitude fades

(
p = Pgeom(1, 0.5, inf);
~seq = p.asStream;
)

~seq.nextN(10);

(type: \note, instrument: \play, buf: b[\flute][0], amp: 0.8).play;