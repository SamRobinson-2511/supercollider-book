//8.1: Object Orientation, Behavior, and Polymorphism

//8.2: Common Compromises in Programming Languages
//8.3: Keeping Things Around


q = ();
q[\melA] = [0,2,3];


//put and at operations can be written like getter-setter messages
q.melA_([0,2,3]);
//or as
q.melA = [0,2,3];
q.melA + 7;

//organize repositories of objects hierarchically
q.mels = ();
q.mels.melA = [0, 2, 3];
q.mels.melB = [4, 6, 9];

q.playMel = {|ev| Pbind(\note, Pseq(ev.melA), \dur, 0.2).play};
q.playMel;


//8.4: Classes and Events as Object Models
//8.7: A Miniature Cloud Generator

//Figure 8.23: Two Granular SynthDefs and tests for them
(
SynthDef(\gab1st, {
	|out, amp=0.1, freq=440, sustain=0.01, pan|
	var snd = FSinOsc.ar(freq);
	var env = EnvGen.ar(Env.sine(
		sustain,
		amp * AmpComp.ir(freq) * 0.5), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan));
}, \ir ! 5).add;

SynthDef(\percSin, {
	|out, amp=0.1, freq=440, sustain=0.01, pan|
	var snd = FSinOsc.ar(freq);
	var env = EnvGen.ar(
		Env.perc(0.1, 0.9, amp * AmpComp.ir(freq) * 0.5),
		timeScale: sustain, doneAction: 2
	);
	OffsetOut.ar(out, Pan2.ar(snd* env, pan));
}, \ir ! 5).add;
)

Synth(\gab1st);
Synth(\percSin);
Synth(\percSin, [\amp, 0.2, \sustain, 0.1]);
(
Synth(\gab1st, [
	\out, 0,
	\amp, 0.2,
	\freq, 2000,
	\sustain, 0.05,
	\pan, 0.5

]
);
)

(
q = q ? ();
q.paramRNames = [\freqRange, \durRange, \densRange, \ampRange, \panRange];
q.paramNames = [\freq, \grDur, \dens, \amp, \pan];
q.syndefNames = [\gab1st, \gabWide, \percSin, \percSinRev, \percNoise];

Spec.add(\xfadeTime, [0.001, 1000, \exp]);
Spec.add(\ring, [0.03, 30, \exp]);
Spec.add(\grDur, [0.0001, 1, \exp]);
Spec.add(\dens, [1, 1000, \exp]);

Tdef(\cloud)
.set(
	\synName, \gab1st,
	\vol, 0.25,
	\current, (
		freqRange: [200, 2000],
		ampRange: [0.1, 1],
		durRange: [0.001, 0.01],
		densRange: [1, 1000],
		panRange: [-1.0, 1.0]
	)
);

Tdef(\cloud0, {
	|e|

	loop {
		s.sendBundle(s.latency, [
			"s_new", e.synName ? \gab1st,
			-1, 0, 0,
			\freq, exprand(e.current.freqRange[0], e.current.freqRange[1]),
			\amp, exprand(e.current.ampRange[0], e.current.ampRange[1]) * e.vol,
			\sustain, exprand(e.current.durRange[0], e.current.durRange[1]),
			\pan, rrand(e.current.panRange[0], e.current.panRange[1])
		]);
		exprand(e.current.densRange[0].reciprocal, e.current.densRange[1].reciprocal).wait;
	}
}).quant_(0);
)

Tdef(\cloud0).play;
Tdef(\cloud0).envir.current.put('densRange', [ 50, 200 ]);




























