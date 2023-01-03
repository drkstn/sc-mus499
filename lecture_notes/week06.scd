// WEEK 06

// It's usually more desirable to create many synths in a module form (perhaps simply only doing one thing, like a reverb, frequency, delay), rather than a super complex synth that does everything, which leads to lots of set messages

////////////////
// Setup code //
////////////////

/*

Node Tree - flows head to tail, top to bottom

HEAD
 |
 |
 |
 |
 V
TAIL

*/

s.boot;

s.plotTree;

(
SynthDef.new(\sin, {
	arg out=0, gate=1;
	var freq, sig, tenv, env;
	freq = LFDNoise0.kr(16!2).exprange(150, 4000);
	sig = SinOsc.ar(freq);
	tenv = EnvGen.ar(Env.perc(0.001, 0.06), Dust.kr(6!2));
	env = EnvGen.kr(Env.asr(5, 1, 5), gate, doneAction:2);
	sig = sig * tenv * env * 0.1;
	Out.ar(out, sig);
}).add;

SynthDef.new(\pn, {
	arg out=0, gate=1;
	var sig, env, mod;
	sig = PinkNoise.ar(1!2);
	mod = LFPulse.kr(0.6, 0, 0.02);
	sig = sig * mod;
	env = EnvGen.kr(Env.asr(0, 1, 5), gate, doneAction:2);
	sig = sig * env * 0.4;
	Out.ar(out, sig);
}).add;
)

~sin = Synth(\sin);
~sin.set(\gate, 0);

~pn = Synth(\pn);
~pn.set(\gate, 0);

// Effects need to be downstream

(
SynthDef.new(\rev, {
	arg in=0, wetamp=0.3, out=0;
	var sig, wet;
	sig = In.ar(in, 2); // ALWAYS be aware of how many channels you're using
	wet = FreeVerb2.ar(
		sig[0], sig[1],
		mix: 1.0,
		room: 1.0,
		damp: 0.85,
		mul: wetamp
	);
	sig = sig + wet;
	Out.ar(out, sig);
}).add;
)

// Audio Busses are locations in which audio signals can both enter and exit (in/out) and where an audio signal can be shared with other processes

s.options.numAudioBusChannels;

s.options.blockSize; // 64 samples per second

~rev = Synth(\rev, [\in, 6, \out, 0]);

~sin = Synth(\sin, [\out, 6]);

~sin.set(\gate, 0);

~rev.free;

// I/O's must be added down the tree from O's


(
~rev = Synth(
	\rev,
	[\in, 6, \out, 0],
	s.defaultGroup,
	\addToHead
);
)

(
~sin = Synth(
	\sin,
	[\out, 6],
	s.defaultGroup,
	\addToHead
);
)

~sin.set(\gate, 0);


~sin = Synth(\sin, [\out, 6]);
~rev = Synth(\rev, [\in, 6, \out, 0], ~sin, \addAfter);

s.freeAll;

~sin = Synth(\sin, [\out, 6]);
~rev = Synth(\rev, [\in, 6, \out, 0], s.defaultGroup, \addAfter);

s.freeAll;

~sourceGroup = Group.new;
~fxGroup = Group.new(~sourceGroup, \addAfter);

// Order of creation doesn't matter since the groups are already ordered correctly

(
~sin = Synth(\sin, [\out, 6], ~sourceGroup);
~rev = Synth(\rev, [\in, 6, \out, 0], ~fxGroup);
)

~sin.set(\out, 0); // Add/remove fx by changing 'out' param
~sin.set(\gate, 0);

~rev.free;

~sourceGroup.free;
~fxGroup.free;

//////////

~fxGroup = Group.new;
~rev = Synth(\rev, [\in, 6, \out, 0], ~fxGroup);

Synth(\sin, [\out, 6], ~fxGroup, \addBefore);

s.defaultGroup.set(\gate, 0);

//////////

(
~sourceGroup = Group.new;
~fxGroup = Group.new(~sourceGroup, \addAfter);
)

~rev = Synth(\rev, [\in, 6, \out, 0], ~fxGroup);

Synth(\sin, [\out, 6], ~sourceGroup);

~sourceGroup.set(\gate, 0); // everything within this group will receive this \gate message and will be harmless to those items that do not have this parameter

///////////

~fxBus = Bus.audio(s, 2); // Storing a bus in a variable helps track/use/remember usage


(
~sourceGroup = Group.new;
~fxGroup = Group.new(~sourceGroup, \addAfter);
~rev = Synth(\rev, [\in, ~fxBus, \out, 0], ~fxGroup);
~sin = Synth(\sin, [\out, ~fxBus], ~sourceGroup);
)

~sourceGroup.set(\gate, 0);

s.freeAll;

~extraBus = Bus.audio(s, 2); // Bus class handles bus allocation for us

1000.do({ Bus.audio(s, 2); }) // Don't do this!


(
s.newBusAllocators; // resets bus allocation counter
~fxBus = Bus.audio(s, 2);
)

// The below code guarantees the order in which the messages arrive to the server, nullifying any sort race conditions; sends as a single OSC message
(
s.bind({
	~sourceGroup = Group.new;
	~fxGroup = Group.new(~sourceGroup, \addAfter);
	~rev = Synth(\rev, [\in, ~fxBus, \out, 0], ~fxGroup);
	~sin = Synth(\sin, [\out, ~fxBus], ~sourceGroup);
});
)

s.freeAll;

s.options.numOutputBusChannels = 8;
s.options.numInputBusChannels = 1;

s.reboot;
