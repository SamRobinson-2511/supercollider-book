// 2. The Unit Generator

// 2.1. Introduction
// 2.2. UGens, scsynth, and SuperCollider


//figure 2.1: Arrays and Multichannel expansion
s.boot;

z = s.scope(4);

// a) mono output
(
SynthDef(\UGen_ex1a, {
	Out.ar(0, SinOsc.ar(440, 0, 0.1))
}).add;
)

a = Synth(\UGen_ex1a);
a.free;

// b) freq input is an Array of 4 items - outputs to busses 0-3
(
SynthDef(\UGen_ex1b, {
	Out.ar(0, SinOsc.ar([440, 446, 448.5, 882], 0, 0.1));
}).add;
)

a = Synth(\UGen_ex1b);
a.free;

// c) Array is added to the 'mul' arg to show mapping
(
SynthDef(\UGen_ex1c, {
	Out.ar(0, SinOsc.ar([440, 446, 448.5, 882], 0, [0.1, 0,2, 0.3, 0.4]))
}).add;
)
a = Synth(\UGen_ex1c);
a.free;

// d) The output of the SinOsc above is actually an array of four SinOscs. Sum them together for an additive synthesis example

(
SynthDef(\UGen_ex1d,{
	Out.ar(0, SinOsc.ar([440, 446, 448.5, 882], 0, [0.1, 0,2, 0.3, 0.4]).sum);
}).add;
)
a = Synth(\UGen_ex1d);
a.free;

s.queryAllNodes;


// 2.3: UGens Available in SuperCollider

//Figure 2.2: Dynamics Processing
z = s.scope;
(
SynthDef(\UGen_ex2,{
	|freq = 440|
	var src, compressor, limiter, out;

	src = SinOsc.ar(
		Array.series(10, freq, freq),
		0,
		Array.fill(10, {Decay2.ar(
			Dust.ar(0.1,5),
			0.01, 5)})
	).sum;

	compressor = Compander.ar(src, src, 0.5, 1, 0.1);
	limiter = Limiter.ar(compressor, 0.5);
	out = [DelayN.ar(compressor, 0.02, 0.02), limiter];
	Peak.ar(out ++ src, Impulse.kr(1)).poll(1, ["compressed", "limited", "src"]);
	Out.ar(0, out);
}).add;
)

a = Synth(\UGen_ex2, [\freq, 440]);
a.free; z.window.close;

//Figure 2.3: Triggering from within the server
(
SynthDef(\UGen_ex3, {
	|gate=1, amp=1, rate=10|
	var trigger, dur, carfreq, modfreq, index, pan, env;

	trigger = Impulse.ar(rate);
	dur = rate.reciprocal;
	carfreq = LFNoise2.kr.range(100, 115);
	modfreq = LFTri.kr(0.1).exprange(200, 840);
	index = LFCub.kr(0.2).range(4,10);
	pan = WhiteNoise.ar.range(-0.1,0.1);
	env = EnvGen.kr(
		Env([0, 1, 0], [1,1], \sin, 1),
		gate,
		levelScale: amp,
		doneAction: 2);
	Out.ar(0,
		GrainFM.ar(2, trigger, dur, carfreq, modfreq, index, pan, -1) * env)
}).add;
)

a = Synth(\UGen_ex3, [\rate, 80, \amp, 0.2]);
b = Synth(\UGen_ex3, [\rate, 42, \amp, 0.2]);
c = Synth(\UGen_ex3, [\rate, 121, \amp, 0.2]);

[a,b,c].do({|thisSynth| thisSynth.set(\gate, 0)});



//Figure 2.4: Triggers and sending values from the server back to the SuperCollider language

(
SynthDef(\UGen_ex4a, {|id, limit = 1|
	var src, pitch, hasPitch, keynum, outOfTune;
	//read input
	src = SoundIn.ar(0);
	//analyze the frequency of the input
	#pitch, hasPitch = Pitch.kr(src);
	//convert to a midi keynum, but don't round! This value will be used later
	pitch = pitch.cpsmidi;
	//if you are within an eighth tone of an equal tempered pitch, send a trigger
	outOfTune = (pitch - pitch.round).abs < 0.25;
	//if outOfTune is true, send a trigger. Limit to 1 trigger every 'limit' seconds
	SendTrig.kr(Trig.kr(outOfTune, limit), id, pitch.round);
}).add;

SynthDef(\UGen_ex4b, {|id1, id2, limit = 1, thresh = 0.5|
	var src, amp, amptrig, timer;
	src = SoundIn.ar(0);
	// analyze the amplitude input, cause a trigger if the output is over the thresh
	amp = Amplitude.kr(src);
	amptrig = Trig.kr(amp > thresh, limit);
	// use amptrig to see how long it is between triggers
	timer = Timer.kr(amptrig);
	// send the values back with two different ids
	SendTrig.kr(amptrig, id1, amp);
	SendTrig.kr(amptrig, id2, timer);
}).add;

//plays a SinOsc of the pitch you were closest to
SynthDef(\UGen_ex4c, {|freq|
	Out.ar(1, SinOsc.ar(freq, 0, XLine.kr(0.1, 0.00001, 0.5, doneAction: 2)))
}).add;

//modulated noise to respond to amp spikes
SynthDef(\UGen_ex4d, {|freq|
	Out.ar(1, LFNoise1.ar(200) * SinOsc.ar(freq, 0, XLine.kr(0.1, 0.00001, 0.5, doneAction: 2)));
}).add;

//allocate three unique ids for the trigger ids

a = UniqueID.next;
b = UniqueID.next;
c = UniqueID.next;

// an envelope to poll for amp values later
e = Env([440, 880], [1], \exp);

// add the responder
o = OSCresponderNode(s.addr, '/tr', {|time, responder, msg|
	// the message is an array with 4 values... post them
	msg.postln;
	//the id send back from the SendTrig is msg[2]... use it to decide what to do
	case
	// pitch trigger
	{msg[2] == a}
	//msg[3] is the rounded keynum
	{Synth(\UGen_ex4c, [\freq, msg[3].midicps])}
	// amp trigger
	{msg[2] == b}
	//play a noise burst, hight the amp value, higher the freq (polls the Env 'e'
	{Synth(\UGen_ex4d, [\freq, e[msg[3]]])}
	// use the Timer value to play a delayed noise burst at 2000Hz
	{msg[2] == c}
	{SystemClock.sched(msg[3], {
		Synth(\UGen_ex4d, [\freq, 2000]);
	})}

}).add;

//schedule the start of our listening synths . . .
// then sing or tap away on the input

SystemClock.sched(1.0, {
	Synth(\UGen_ex4a, [\id, a, \limit, 1]);
	Synth(\UGen_ex4b, [\id1, b, \id2, c, \limit, 0.2, \thresh, 0.25]);

});

// add a command period function to stop the synths and remove the responder
CmdPeriod.doOnce({
	// o.remove; "Removed the responder".postln;
})
)


//Figure 2.5: Random-number generators and random seeding in the server

(
SynthDef(\UGen_ex5, {
	|gate=1, seed=0, id=1, amp=1|
	var src, pitchBase, freq, rq, filt, trigger, env;
	RandID.ir(id);
	RandSeed.ir(1, seed);
	env = EnvGen.kr(Env([0,1,0], [1,4], [4,-4],1), gate, doneAction:2);
	src = WhiteNoise.ar;
	trigger = Impulse.kr(Rand.new(2,5));
	pitchBase = IRand.new(4,9) * 12;
	freq = TIRand.kr(pitchBase, pitchBase+12, trigger).midicps;
	rq = LFDNoise3.kr(Rand.new(0.3, 0.8)).range(0.01, 0.005);
	filt = Resonz.ar(src, Lag2.kr(freq), rq);
	Out.ar(0, Pan2.ar(filt, LFNoise1.kr(0.1)) * env * amp)
}).add;
)

a = Synth(\UGen_ex5, [\seed, 123]);
a.release;

b = Synth(\UGen_ex5, [\seed, 123]);
b.release;

(
r = Routine.run({
	thisThread.randSeed_(123);
	10.do({
		a = Synth(\UGen_ex5, [\seed, 10000.rand.postln, \amp, 3.dbamp]);
	});
});
)

//Figure 2.6: GVerb
(
SynthDef(\UGen_ex6, {
	|gate=1, roomsize=200, revtime=450|
	var src, env, gverb;
	env = EnvGen.kr(Env([0,1,0], [1,4], [4, -4], 1), gate, doneAction:2);
	src = Resonz.ar(
		Array.fill(4, {Dust.ar(6)}),
		1760 * [1, 2.2, 3.95, 8.76] + Array.fill(4, {LFNoise2.kr(1, 20)}), 0.01).sum * 30.dbamp;
	gverb = GVerb.ar(
		src,
		roomsize,
		revtime,
		0.99,
		LFNoise2.kr(0.1).range(0.9, 0.7),
		LFNoise1.kr(0.2).range(0.2, 0.6),
		-60.dbamp,
		-18.dbamp,
		3.dbamp,
		roomsize
	);
	Out.ar(0, gverb * env);
}).add;
)

a = Synth(\UGen_ex6);























