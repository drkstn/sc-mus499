// WEEK 08

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
SynthDef.new(\samp, {
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

SynthDef.new(\saw, {
	arg freq=60, bend=0.15, lph=40, rq=0.7, gate=1, slev=0.3,
	atk=0.002, dec=0.2, rel=2, acrv=1, dcrv=(-3), rcrv=(-2),
	pan=0, amp=0.3, out=0;
	var sig, fenv, env, bendCtrl;
	bendCtrl = LFNoise2.kr( {Rand(0.4,0.5)}!8 ).bipolar(bend);
	freq = freq * bendCtrl.midiratio;
	sig = VarSaw.ar(
		freq: freq,
		iphase: {Rand(0.0, 1.0)}!8,
		width: {ExpRand(0.001, 0.02)}!8
	);
	sig = Splay.ar(sig) * 0.5;
	sig = RLPF.ar(
		sig,
		(freq * lph).clip(20, 20000),
		rq
	);
	env = EnvGen.ar(
		Env.new([0,1,slev,0],[atk, dec, rel], [acrv, dcrv, rcrv], 2),
		gate,
		doneAction:2
	);
	sig = Balance2.ar(sig[0], sig[1], pan, amp) * env;
	Out.ar(out, sig);
}).add;

SynthDef.new(\sine, {
	arg freq=440, amp=0.2, gate=1, rel=1, pan=0, out=0;
	var sig, env;
	env = EnvGen.kr(Env.asr(0.02, 1, rel), gate, doneAction:2);
	sig = SinOsc.ar(freq);
	sig = Pan2.ar(sig, pan, amp) * env;
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in=0, mix=0.08, out=0;
	var sig, wet;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(
		sig[0], sig[1],
		mix: mix,
		room: 0.999,
		damp: 0.85
	);
	Out.ar(out, sig);
}).add;

s.newBusAllocators;
~bus = Bus.audio(s, 2);
)

Synth(\samp, [\buf, b[\flute].choose,\rate, rrand(-12,12).midiratio]);

Synth(\samp, [\buf, b[\wood][0], \amp, 0.7]);

x = Synth(\saw, [\amp, 0.5, \freq, 400]);
x.set(\gate, 0);

x = Synth(\sine, [\amp, 0.1, \freq, 400]);
x.set(\gate, 0);

~reverb = Synth(\reverb, [\in, ~bus]);

Synth(\samp, [\buf, b[\wood][0], \amp, 0.7, \rate, rrand(-12,12).midiratio, \out, ~bus]);

e = (abc: 7, def: 9, ghi: 13.5);

e.keys;
e.values;
e.getPairs;
e[\abc];

/////////////////////////

// Some event keys have predefined meaning

(freq: 200).play;
(amp: 0.025).play
(sustain: 1).play
(dur: 0.1).play

//

Synth.new(\samp, [\buf, b[\wood][0], \amp, 0.7]);
// These two are equivalent
(instrument:\samp, buf:b[\wood][0], amp:0.7).play;

// What are the advantages to the above? See below.
x = Synth(\saw, [\amp, 0.5, \freq, 40]);
x.set(\gate, 0);

(instrument:\saw, amp:0.5, freq:40).play; // Stops automatically
// This is due to predefined sustain key which triggers the gate after defined interval
(instrument:\saw, amp:0.5, freq:40, sustain:0.05).play;

// Pbind is a way to automate the creation of the above events
(
p = Pbind(
	\instrument, \sine,
	\amp, 0.1,
	\freq, Pseq([200, 300, 400], inf),
);
~seq = p.asStream;
)

// The double parans (()) are necessary for Pbinds
~seq.next(()).postln.play;\

(
p = Pbind(
	\instrument, \sine,
	\amp, Pseq([0.05, 0.4], inf),
	\freq, Pseq([200, 300, 400], inf),
);
~seq = p.asStream;
)

~seq.next(()).postln.play;\

(
p = Pbind(
	\instrument, \samp,
	\buf, Prand([
		b[\flute][0],
		b[\glitch][0],
		b[\wood][0]
	], inf),
	\amp, Pexprand(0.4, 0.8, inf),
	\rate, Pwhite(-12, 0, inf).midiratio,
	\lp, Pseq([400, 8000], inf),
	\out, ~bus,
);
~seq = p.asStream;
)

~seq.next(()).postln.play;\

// Play automatically

(
p = Pbind(
	\instrument, \samp,
	\buf, b[\flute][0],
	\amp, Pexprand(0.4, 0.8, inf),
	\rate, Pseq((-12..0), inf).midiratio,
	\out, ~bus,
);
~seq = p.play; // Creates an EventStreamPlayer instead of Routine
)

~seq.stop;
~seq.resume;

// Play random sample from sample set

(
var buf, bufSize;
buf = b.glitch;
bufSize = buf.size - 1;

p = Pbind(
	\instrument, \samp,
	\buf, Prand(buf[0..bufSize], inf),
	\amp, Pexprand(0.4, 0.8, inf),
	\rate, Prand((-12..12), inf).midiratio,
	\out, 0,
);
~seq = p.play;
)

~seq.stop;
~seq.resume;

// Fun with random stretching of duration intervals

(
var buf, bufSize;
buf = b.wood;
bufSize = buf.size - 1;

p = Pbind(
	\instrument, \samp,
	\buf, Prand(buf[0..bufSize], inf),
	\amp, Pexprand(0.4, 0.8, inf),
	// \rate, Prand((-12..12), inf).midiratio,
	\dur, Pseq((Array.fill(5, {[0.125, 0.25, 0.5].choose}).normalizeSum * 2), inf).trace,
	\out, 0,
);
~seq = p.play;
)

~seq.stop;
~seq.resume;

(Array.fill(8, {[0.125, 0.25, 0.5].choose}).normalizeSum * 8)

////////////////////

(
p = Pbind(
	\instrument, \samp,
	\dur, 0.1,
	\buf, b[\flute][0],
	\amp, Pexprand(0.4, 0.8, inf),
	\rate, Pseq((-12..0), inf).midiratio,
	\out, 0,
);
~seq = p.play;
)

// Tempo Clock

t = TempoClock.new(108/60);

t.beats;

(
p = Pbind(
	\instrument, \samp,
	\dur, 1,
	\buf, b[\flute][0],
	\amp, Pexprand(0.4, 0.8, inf),
	\rate, Pseq((-12..0), inf).midiratio,
	\out, 0,
);
~seq = p.play(t); // Play on clock created
)

t.tempo_(108/60) // Update running clock

~seq.stop; // Cmd+period destroys clocks

t = TempoClock.new(108/60).permanent_(true); // This prevents clock being destroyed from Cmd+period

(
p = Pbind(
	\instrument, \samp,
	\dur, 1,
	\buf, b[\flute][0],
	\amp, Pexprand(0.4, 0.8, inf),
	\rate, Pseq((-12..0), inf).midiratio,
	\out, 0,
);
~seq = p.play(t);
)

~seq.stop;

t.beats;

t.stop; // Destroys clock

//

(
p = Pbind(
	\instrument, \saw,
	\dur, 0.2,
	\amp, Pexprand(0.4, 0.8, inf),
	\freq, Pseq([40, 50, 60], 2), // after 2 cycles, the event stream ends
	\atk, 0.001,
	\dec, 0.08,
	\rel, 0.5,
	\sustain, 0.2,
	\out, 0,
);
~seq = p.play;
)

~seq.stop;

Event.eventTypes.keys.postcs;\ //event types

Event.parentEvents.default[\db].postcs;\ //default value for a certain key

Event.eventTypes[\note].postcs;\ //function associated with 'note' key

Event.parentEvents.default[\play].postcs;\ //function that determines 'play' behavior

(
//a collection of some event keys that have pre-defined meaning
Event.partialEvents.keys.do({ |n|
	n.postln;
	Event.partialEvents[n].keys.postln;
	\.postln;
});\
)

///////////////////////////////////////////////////////////
(
p = Pbind(
	\instrument, \saw,
	\dur, Prand([0.1, 0.2], inf),
	\db, Pwhite(-20, -10, inf),
	// \degree, Pseq((0..4), inf), // first five degree of scale
	\degree, Pwhite(0, 10, inf), // random scale degree of two octaves
	\scale, Scale.minorPentatonic, // OR \scale, [ 0, 3, 5, 7, 10 ],
	\mtranspose, 2, // shifts everything up by (x) scale degrees OR \degree, Pwhite(0, 10, inf) + 2
	\atk, 0.001,
	\dec, 0.08,
	\rel, 0.5,
	\sustain, 0.2,
	\out, 0,
);
~seq = p.play;
)
Scale.minorPentatonic;

(
p = Pbind(
	\instrument, \saw,
	\dur, Prand([0.1, 0.2], inf),
	\db, Pwhite(-20, -10, inf),
	\note, Pseq((0..12),inf), // semitones
	\octaveRatio, 2, // stretches octave, gets microtones
	\octave, 4, //specifies octave, 5 is middle-C
	\gtranspose, 3.4, // gamut transposition - whatever that is
	\atk, 0.001,
	\dec, 0.08,
	\rel, 0.5,
	\sustain, 0.2,
	\out, 0,
);
~seq = p.play;
)

(
p = Pbind(
	\instrument, \saw,
	\dur, Prand([0.1, 0.2], inf),
	\db, Pwhite(-20, -10, inf),
	\midinote, Pseq([40,47,57,62],inf),
	\ctranspose, 3, //chromatic shift by (x)
	\atk, 0.001,
	\dec, 0.08,
	\rel, 0.5,
	\sustain, 0.2,
	\out, 0,
);
~seq = p.play;
)

(
p = Pbind(
	\instrument, \saw,
	\dur, Prand([0.1, 0.2], inf),
	\db, Pwhite(-20, -10, inf),
	\midinote, 29,
	\harmonic, Pseq((1..8), inf), // harmonic series
	\detune, 10, // value in hz
	\atk, 0.001,
	\dec, 0.08,
	\rel, 0.5,
	\sustain, 0.2,
	\out, 0,
);
~seq = p.play;
)

~seq.stop;

-10.dbamp

(
p = Pbind(
	\instrument, \samp,
	\buf, b[\wood][0],
	\dur, Pgeom(0.05, 1.02, inf), // exponential increase/decrease
	\db, Pseries(-6, -0.2, inf),
	\rate, Prand([
		Pgeom(1, -0.1.midiratio, inf),
		Pgeom(1, 0.1.midiratio, inf),
	], 1) * rrand(0.8, 1.5),
	\pan, Pseq([1,-1], inf),
	\out, 0,
);
)

(
~seq.stop;
~seq = p.play;
)

~seq.stop;



