//Problem Set 3




//----------
//Problem 0.
//The following SynthDef does not produce any errors when created, but the Synth line below it does not produce any sound. Identify the problem, correct it, and add a comment indicating what the problem was.

s.boot;

(
SynthDef.new(\kraftwerkesque, { |out=0| // initialize 'out' arg
	var sig, trnsp, amp, freq;
	freq = 200;
	amp = LFSaw.kr(8,1,-0.5,0.5).pow(4);
	trnsp = LFNoise0.kr(8!4).range(-36,12).round(12);
	sig = Saw.ar(freq * trnsp.midiratio);
	sig = RLPF.ar(sig, LFNoise0.kr(4!4).exprange(200,5000).lag(0.02), 0.2);
	sig = Splay.ar(sig) * amp * 0.3;
	Out.ar(out, sig) // Must add Out UGen to write signal to bus
}).add;
)

Synth(\kraftwerkesque);

//----------
//Problem 1.
//Create a sort of "howling wind" sound effect, by making a SynthDef that passes stereo white noise through a band-pass filter. Add two envelopes: one should be used to sweep the center frequency of the filter up and down over 12 seconds, and the other should fade the amplitude in and out over 12 seconds, beginning and ending with silence. Make sure the Synth frees itself after the envelopes are complete (only one doneAction:2 is necessary). Use a high quality filter (a low rq value) but be sure your filter parameters stay within safe ranges! Use an appropriate panning UGen to make your wind randomly drift across the stereophonic field (LFNoise1, running at a low frequency, is a good option for randomly controlling the pan position). Below your SynthDef, create a Synth to demonstrate your howling wind.

(
SynthDef.new(\howlingWind, { |out=0, amp=0.4|
	var env, pan, wind, bpf, bal, mix;
	env = EnvGen.ar(
		Env.new(
			[0, 1, 0],
			[6, 6],
			'sin',
		),
		doneAction: 2
	);
	pan = LFNoise1.ar(1).bipolar(0.5).poll;
	wind = WhiteNoise.ar(1!2);
	bpf = BPF.ar(wind, 200 + env.bipolar(800), 0.2);
	bal = Balance2.ar(bpf[0], bpf[1], pan);
	mix = bal * amp * env;
	Out.ar(out, mix)
}).add;
)

Synth(\howlingWind);

// Dynamic version with random pitch/speed

(
SynthDef.new(\howlingWind, { |out=0, amp=0.4, speed=12, pitch=800|
	var env, pan, wind, bpf, bal, mix;
	env = EnvGen.ar(
		Env.new(
			[0, 1, 0],
			[speed/2, speed/2],
			'sin',
		),
		doneAction: 2
	);
	pan = LFNoise1.ar(0.5).bipolar(0.5);
	wind = WhiteNoise.ar(1!2);
	bpf = BPF.ar(wind, 100 + env.bipolar(pitch), 0.2);
	bal = Balance2.ar(bpf[0], bpf[1], pan);
	mix = bal * amp * env;
	Out.ar(out, mix)
}).add;
)

Synth(\howlingWind, [\speed, rrand(10, 30).postln, \pitch, exprand(300, 1200).postln]);



//----------
//Problem 2.
//Run Example A and listen to the signal that is produced. Press-command period to stop the sound. Then, change the ".ar" method to ".kr" on the 'freqmod' SinOsc, re-run the Example A code, and listen to the sound. Notice the difference.

//Then, repeat this process with Example B, and notice that the ar/kr versions are sonically indistinguishable. In your own words, write a comment that explains why the first example sounds different when the ar method is changed to kr, but the second example does not seem to change.

(
{	//Ex A
	var freqmod, sig;
	freqmod = SinOsc.ar(325, mul:300); //change ar -> kr
	sig = SinOsc.ar(650 + freqmod);
	sig = sig * 0.1!2;
}.play
)

(
{	//Ex B
	var freqmod, sig;
	freqmod = SinOsc.ar(6, mul:300); //change ar -> kr
	sig = SinOsc.ar(650 + freqmod);
	sig = sig * 0.1!2;
}.play
)

// In Example B, the frequency modulation is modulated at such a low frequency that the sample rate doesn't matter. This is because there are less drastic changes over a longer period of time. When the frequency of the modulation is increased, it requires more resolution (samples) to produce a smooth sound. This is because there are more drastic changes over a smaller period of time.




//----------
//Problem 3.
//Create a SynthDef that makes a juicy synth "stab" sound. Your sound source should be a sawtooth wave (Saw) passed through a resonant lowpass filter (RLPF). Add one envelope to control the cutoff frequency of the filter — it should sweep from a high to low frequency value very quickly. Add another envelope that controls the overall amplitude level of the sound. Again, the envelope should be percussive, starting loud and quickly fading out. You can add other features if you want (try to make it sound cool). Include an argument for the frequency of the sawtooth wave, and create a few Synths with different frequencies to demonstrate that your SynthDef works.

//Here are some reference files. These are just meant to provide a rough guide — you don't have to imitate this sound exactly.

https://uofi.box.com/s/g4dmtqgcw7r67f1bctsc4q1n8gp91zpw
https://uofi.box.com/s/76zkj0m8dm07d3tbaef72ghdsupf88kt

(
SynthDef.new(\stab, { |out=0, freq=40, amp=0.4|
	var ampEnv, freqEnv, saw, rlpf, mix;
	ampEnv = EnvGen.ar(
		Env.new(
			[1, 0],
			[0.8],
			[-1]
		),
		doneAction:2
	);
	freqEnv = EnvGen.ar(
		Env.new(
			[15000, 30],
			[0.3],
			[-10]
		)
	);
	saw = Saw.ar([freq, freq + 4]);
	rlpf = RLPF.ar(saw, freqEnv, 0.05, 0.8);
	mix = rlpf * amp * ampEnv;
	Out.ar(out, mix)
}).add;
)

Synth(\stab, [\freq, 80]);
Synth(\stab, [\freq, 40]);
Synth(\stab, [\freq, 40.midicps]);
Synth(\stab, [\freq, 49.midicps]);




//----------
//Problem 4.
//Create a sine wave "chorus" effect by making a SynthDef that produces a sustained stereophonic drone of 20 sine waves whose frequencies are all randomly clustered around some center frequency, which should be specified as a SynthDef argument. Use multichannel expasion (e.g. something!20) to create the 20 slightly different sine frequencies, and use Splay to mix these 20 signals down to a stereophonic format. Include an overall amplitude envelope with a long duration that frees the Synth when complete. Be mindful of the overall signal amplitude and don't let the output level meters clip above 0 dB. Create a few Synths with different center frequencies to demonstrate that your SynthDef works.

(
SynthDef.new(\drone, { |out=0, amp=0.2, freq=80|
	var env, arr, pan, sin, rlpf, splay, bal, mix;
	env = EnvGen.ar(
		Env.new(
			[0, 1, 1, 0],
			[5, 10, 5],
			'sin'
		),
		doneAction: 2
	);
	pan = LFNoise1.ar(0.5).bipolar(0.75);
	arr = Array.fill(20, {bilinrand(40.0) + freq});
	sin = SinOsc.ar(arr) + Saw.ar(arr); // Added the saw for good fun
	rlpf = BPF.ar(sin, freq, 0.05, 0.1);
	splay = Splay.ar(sin);
	bal = Balance2.ar(splay[0], splay[1], pan);
	mix = bal * amp * env;
	Out.ar(out, mix);
}).add;
)

Synth.new(\drone, [\freq, 80]);
Synth.new(\drone, [\freq, 1000]);
Synth.new(\drone, [\freq, 300]);



