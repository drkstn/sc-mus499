//Problem Set 4




//----------
//Problem 0.
//Download the following two audio samples (a desk bell and a drum loop):

https://uofi.box.com/s/vrh8j78mhend29hvyydpt4gygtlb0wfh //drum loop
https://uofi.box.com/s/2jcyp9wic50dqs78fa1weyijihldwwtj //desk bell

//Boot the audio server. As demonstrated in class, create a project folder named "[your last name] Problem Set 4." Save this code file in that folder, naming it "[your last name] Problem Set 4.scd," and also move or copy these two audio files into this folder.

/**NOTE: when you submit your assignment, make sure to compress this folder as a zip file and submit the zip file, so that your submission contains code and audio — don't submit only the scd file!!**/

//Using the "thisProcess.nowExecutingPath" approach, write some code that reads these two files into Buffers, and stores each Buffer in a unique global variable name. If you've done this correctly, I should be able to run this code on my own computer to read these files into buffers, without having to change any of your code.

Buffer.freeAll;

~audiopath = thisProcess.nowExecutingPath.dirname +/+ "problemSet4_audio";

(
b = (
	bell: Buffer.read(s, ~audiopath +/+ "deskBell.aiff"),
	drum: Buffer.read(s, ~audiopath +/+ "drumloop1.wav")
)
)

b.bell.play;
b.drum.play;




//----------
//Problem 1.
//Write a line of code that returns the number of audio channels in the drum loop file, and another line of code that returns the number of audio channels in the desk bell file. No need to produce any sound here — just print/return the channel size information.

b.drum.numChannels;
b.bell.numChannels;




//----------
//Problem 2.
//Write a UGen function (not a SynthDef) that plays the desk bell sample once, at its original playback rate. The Synth should free itself when we reach the end of the sound file. Make sure to compensate for the possibility of a mismatch between the server's sampling rate and the sampling rate at which the sound file was created.

{PlayBuf.ar(2, b.bell, BufRateScale.kr(b.bell) * 1, doneAction:2)}.play;




//----------
//Problem 3.
//Convert the UGen function from the previous problem into a SynthDef. In the SynthDef, declare arguments for the bufnum, the playback rate, the overall signal amplitude, and the output bus. Then, use iteration to play the desk bell sample at five different pitches simultaneously, to create a five-voice chord. Make sure the amplitude of the overall sound doesn't clip above 0 dB.

(
SynthDef(\play2, { |out=0, buf=0, rate=1, amp=0.4|
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, doneAction:2) * amp;
	Out.ar(0, sig);
}).add;
)

Synth(\play2, [\buf, b.bell]);

(
[0, 2, 5, -7, -12].do({ |n|
	Synth(\play2, [\buf, b.bell, \rate, n.midiratio]);
})
)


//----------
//Problem 4.
//Create a new SynthDef or modify the existing SynthDef so that it is capable of looping and non-looping playback. Include a sustaining envelope with a gate argument that controls overall amplitude. Below this new/modified SynthDef, include a line of code that creates a Synth which endlessly loops through the drum sample at its original rate, and a second line of code that closes the envelope gate to fade out the sound.

(
SynthDef(\play_loop, { |out=0, buf=0, rate=1, loop=1, amp=0.4, gate=1|
	var sig, env, mix;
	env = EnvGen.kr(
		Env.new([0, 1, 0],[0.001, 5], [1,-1], 1),
		gate: gate,
		doneAction: 2);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate,
		loop: loop,
		doneAction: 2);
	mix = sig * amp * env;
	Out.ar(out, mix)
}).add;
)

x = Synth(\play_loop, [\buf, b.drum, \loop, 0, \rate, 2])
x = Synth(\play_loop, [\buf, b.drum, \rate, 2])
x.set(\gate, 0);


//----------
//Problem 5.
//Add a similar line of code that creates a Synth that endlessly loops through the drum sample, but backward. Add a second line of code that closes the envelope gate and fades out the sound.

(
SynthDef(\play_reverse, { |out=0, buf=0, rate=1, spos=0, loop=1, amp=0.4, gate=1|
	var sig, env, mix;
	env = EnvGen.kr(
		Env.new([0, 1, 0],[0.001, 5], [1,-1], 1),
		gate: gate,
		doneAction: 2);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate,
		startPos: spos,
		loop: loop,
		doneAction: 2);
	mix = sig * amp * env;
	Out.ar(out, mix)
}).add;
)

x = Synth(\play_reverse, [\buf, b.bell, \loop, 0, \rate, -2, \spos, b.bell.numFrames-2])
x = Synth(\play_reverse, [\buf, b.bell, \rate, -1])
x.set(\gate, 0);




//----------
//Problem 6.
//Use iteration to play three copies of the backward-looping drum sample at very slightly different playback rates (e.g. -0.99, -1.0, -1.01), so that these three Synths drift out of phase with each other over time. Make sure the amplitude of the overall sound doesn't clip above 0 dB. Write another line of code that fades out all three Synths.

(
~rates = [-0.99, -1.0, -1.01];
~drums = ~rates.collect({ |n|
	Synth(\play_reverse, [\buf, b.drum, \rate, n])
});
)

~drums.do({ |n| n.set(\gate, 0);});
