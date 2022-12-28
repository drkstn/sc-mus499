// WEEK 4

(
f = {
	var sig;
	sig = [
		SinOsc.ar(257),
		SinOsc.kr(257)
	];
	sig = sig * 0.15;
}.plot(0.03);
)

s.sampleRate;

s.options.blockSize;
s.options.blockSize / s.sampleRate;

(
f = {
	var sig, mod, modhz;
	modhz = MouseX.kr(1, 4000, 1).poll;
	mod = SinOsc.kr(modhz).bipolar(400);
	sig = SinOsc.ar(500 + mod);
	sig = sig * 0.2;
}.play;
)

///////////////////

(
f = {
	var sig;
	sig = Saw.ar([40,40.5]);
	sig = sig * 0.1;
}.play;
)

// LPF
// Filters out frequencies above specified range

(
f = {
	var sig, freq=40, lpf;
	lpf = MouseX.kr(20, 20000, 1).poll; // ALWAYS keep filter values within audible spectrum! 20 — 20k
	lpf = lpf.clip(20, 20000); // Use 'clip' to ensure values stay in range
	sig = Saw.ar([freq - 0.5, freq + 0.5]);
	sig = LPF.ar(sig, lpf);
	sig = sig * 0.1;
}.play;
)

FreqScope.new;

// HPF
// Filters out frequencies above specified range

(
f = {
	var sig, filt;
	filt = MouseX.kr(20, 20000, 1).poll;
	filt = filt.clip(20, 20000);
	sig = Saw.ar([40, 40.5]);
	sig = HPF.ar(sig, filt);
	sig = sig * 0.1;
}.play;
)

// BPF
// Filters out frequencies above and below specified range

(
f = {
	var sig, filt;
	filt = MouseX.kr(20, 20000, 1).poll;
	filt = filt.clip(20, 20000);
	sig = WhiteNoise.ar(0.9!2);
	sig = BPF.ar(sig, filt, 1); // 'rq' parameter MSUT always stay > 0 && <= 1
	sig = sig * 0.1;
}.play;
)

(
f = {
	var sig, filt;
	filt = MouseX.kr(20, 20000, 1).poll;
	filt = filt.clip(20, 20000);
	sig = Saw.ar([40, 40.5]);
	sig = BPF.ar(sig, filt, 0.05, 5); // 'rq' parameter MSUT always stay > 0 && <= 1
	sig = sig * 0.1;
}.play;
)

// RLPF

(
f = {
	var sig, filt;
	filt = MouseX.kr(20, 20000, 1).poll;
	filt = filt.clip(20, 20000);
	sig = Saw.ar([40, 40.5]);
	sig = RLPF.ar(sig, filt, 0.02, 0.4);
	sig = sig * 0.1;
}.play;
)

// RHPF

(
f = {
	var sig, filt;
	filt = MouseX.kr(20, 20000, 1).poll;
	filt = filt.clip(20, 20000);
	sig = Saw.ar([40, 40.5]);
	sig = RHPF.ar(sig, filt, 0.04, 0.4);
	sig = sig * 0.1;
}.play;
)

FreqScope.new;

// Pan
// Receives a mono signal

(
SynthDef.new(\pansynth, {
	arg out=0;
	var sig, pan, freq;
	freq = SinOsc.ar(0.15).bipolar(400);
	pan = SinOsc.ar(0.3).bipolar(1);
	sig = PinkNoise.ar(1);
	sig = BPF.ar(sig, 900 + freq, 0.1, 4);
	sig = sig * LFPulse.kr(8);
	sig = Pan2.ar(sig, pan, 0.8);
	Out.ar(out, sig);
}).add;
)

Synth.new(\pansynth);

// Balance
// Receives a stereo signal and balances levels between them

(
SynthDef.new(\pansynth, {
	arg out=0;
	var sig, pan;
	pan = SinOsc.ar(0.2).bipolar(1);
	sig = [Saw.ar(40, mul:0.1), PinkNoise.ar(0.3)];
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

Synth.new(\pansynth);

// Splay
// Receives an array of items of arbitrary size and linearly spaces them in stereo field

(
SynthDef.new(\pansynth, {
	arg out=0;
	var sig, pan;
	pan = SinOsc.ar(0.2).bipolar(0.5);
	sig = Saw.ar(Array.exprand(50, 40, 3000));
	sig = LPF.ar(sig, 4000); // Because lpf receives a 50-chan signal, it also expands into a 50-chan signal
	sig = Splay.ar(sig) * 0.2;
	sig = Balance2.ar(sig[0], sig[1], pan);
	Out.ar(out, sig);
}).add;
)

Synth.new(\pansynth);