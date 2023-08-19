// 2. The Unit Generator

// 2.1. Introduction
// 2.2. UGens, scsynth, and SuperCollider


//figure 2.1: Arrays and Multichannel expansion

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
	carfreq = LFNoise2.kr.range(100, 110);
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







