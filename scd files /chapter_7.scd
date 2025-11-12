//Figure 7.1: A modulo algorithm that operates over states of variables

(
Task {
	x = 4; y = 13;
	loop {
		x = (x * y) % 5;
		(note: x.postln, dur: 0.5).play;
		0.5.wait;
	}
}.play;
)
x = 5;
y = 6;


//Figure 7.2: Synthesis Graph
(
{
	x = SinOsc.kr(2);
	y = SinOsc.kr(3.2);
	SinOsc.ar(x * y % 0.4 * 500 + 600) * 0.2
}.play;
)
x = SinOsc.kr(5);
y = SinOsc.kr(20);


//Figure 7.3: Dynamic Synthesis Graph

s.boot;
(
p = ProxySpace.push;
~x = { SinOsc.kr(4) };
~y = { SinOsc.kr(13) };
~z = { SinOsc.ar(~x * ~y % 0.4 * 500 + 600) * 0.2};
)
~z.play;
~x = { SinOsc.kr(0.4)};
~y = { SinOsc.kr(1.3)};
p.clear(2).pop;


//7.2: Abstraction and Proxies
x = [1910, 1911, 1912];
y = x + 96.rand;

//A BinaryOpFunction
y = x + {96.rand};

y.value;
(
{var x = 1.0; 5.do {x = x * SinOsc.ar(1911.0.rand)}}.play;
)
s.reboot;


//Figure 7.4: Refactoring a synthesis graph at runtime

p = ProxySpace.push;
~a = {Lag.ar(LFClipNoise.ar(2!2, 0.5, 0.5), 0.2)};
(
~b = {
	var c, d;
	c = Dust.ar(20 ! 2);
	d = Decay2.ar(c, 0.01, 0.02, SinOsc.ar(11300));
	d + BPF.ar(c * 5, ~a.ar * 3000 + 1000, 0.1)
}
);
~b.play;


//the above refactored
(
~a = {
	var a;
	a = Lag.ar(LFClipNoise.ar(2!2, 0.5, 0.5), 0.2);
	BPF.ar(~c.ar * 2.5, a * 3000 + 1000, 0.1 )
}
);
~c = { Dust.ar(20 ! 2)};
~d = { Decay2.ar(~c.ar, 0.01, 0.02, SinOsc.ar(11300))};
~b = ~a + ~d;

~b.play;

//Figure 7.6: A dynamic graph of a chaotic linear congruence. Self-reference (~x ) constructs at loop at control rate

~out.play;
~x = 0.2; ~a = 1.1; ~c = 0.13;
~x = (~a * ~x) + ~c % 1.0; //leaving out the .kr message assumes a control rate ugen
~out = { Pan2.ar(SinOsc.ar(~x * 4000 + 200) * 0.1, ~x)};

//Figure 7.7: Creating a proxy object explicitly and changing its source
n = NodeProxy.new;
x = { SinOsc.ar(n.kr * 200 + 300) * 0.1 }.play;
n.source = {LFPulse.kr([1.3, 2.1, 3.2]).sum };
n.clear; x.free;


//Figure 7.8: Unified cereating and access syntax with Ndef
Ndef(\out, { SinOsc.ar(Ndef.kr(\x) * 200 + 300) * 0.1}).play;
Ndef(\x, { LFPulse.kr([1.3, 2.1, 3.2]).sum });
Ndef.clear;

//Figure 7.9: Unified creation and access syntas within an environment
p = ProxySpace.push;
~out = { SinOsc.ar(~x.kr * 200 + 300) * 0.1};
~out.play;
~x = { LFPulse.kr([1.3, 2.1, 3.2]).sum};
p.clear.pop;


//Figure 7.10: Initialization of node proxies in a proxy space
p.clear; // neutralize space, free all busses and synths
p.push; //if needed
~a.ar(3);
~b.kr(8);
~c.play;
~d = { LFNoise0.kr([1, 1, 1, 1])};


//Figure 7.11: Parameter mapping and setting
~out.play; ~out.fadeTime = 3;
(
//name with a_ represents an audio rate argument
~out = { |freq=440, mod=0.4, detune=0.1, a_in = #[1,1]|
	freq = freq*([0, detune] + 1);
	LFTri.ar(LFTri.ar(mod * freq).range(freq*mod, freq)) * a_in * 0.2
}
)

(
~mod2 = { LFNoise1.kr(1).range(0,1)};
~mod1 = { LFPulse.kr(~mod2.kr * 30 + 1, 0, 0.3)};
~freq1 = { ~mod1.kr * 13100 + 100 };
~freq2 = { LFTri.kr(30) * 200 + 300};
~audio1 = { BrownNoise.ar(LFClipNoise.kr(10.dup), 1)};
~audio2 = { SinOsc.ar(LFNoise2.kr(1.dup).exprange(4, 1000))};
)
~out.map(\freq, ~freq2, \mod, ~mod1);
~out.set(\detune, 0.01);
~out.map(\freq, ~freq1, \mod, ~mod1);
~out.xmap(\freq, ~freq1, \mod, ~mod2);
~out.xmap(\freq, ~freq2, \mod, ~mod1, \a_in, ~audio2);
~out.map(\a_in, ~audio1);

//Figure 7.12: Rewriting a synth definition and a task definition while running

//this SynthDef is used in the subsequent figures
(
SynthDef(\wave, {
	|out, freq=440, amp=0.1, sustain=0.1, mod=0.2|
	OffsetOut.ar(out,
		EnvGen.ar(Env.perc(ExpRand(0.001, 0.05), sustain, amp), doneAction:2)
		*
		SinOsc.ar(freq, SinOsc.ar(sustain.reciprocal * 8, [0, Rand(0, pi)], mod))
	)
}).add;
)

(
Tdef(\x, {
	x = 4; y = 13;
	loop {
		x = (x * y) % 11;
		(instrument: \wave, note: x.postln, sustain: 0.5, octave: 6).play;
		0.125.wait;
	}
}).play;
)

//Figure 7.13: Combining different task proxies: embed and fork
(

Tdef(\a, {10.do { (instrument: \wave, freq: 50.rand+1500).play;
0.03.wait}});
Tdef(\b, { [1, 5, 1, 2, 8, 4, 12].do {
	|x|
	(
		instrument: \wave,
		note: x + 8
	).play;
	0.8.wait;
}});
Tdef(\c, { "c is just a waiting message".postln;
	2.wait;
});


Tdef(\x, {
	loop {
		Tdef(\a).embed;
		1.wait;
		Tdef(\b).embed;
		2.wait;
		Tdef(\a).fork;
		Tdef(\b).fork;
		Tdef(\c).embed;
	}
}).play;
)


(
//rewrite with infinite loop
Tdef(\a,
	{
		inf.do {
			(
				instrument: \wave,
				freq: 500.rand+100
).play;
			0.1.wait;
}});
)

//rewrite with finite loop
(
Tdef(\a, {10.do {(instrument: \wave, freq: 50.rand+500).play;
	0.1.wait;
}})
)

//Figure 7.14: passing an evironment into a task proxy when embedding it

(
Tdef(\a, {
	|in|
	in.at(\n).do{
		|i|
		in = (instrument: \wave, detune: 5.rand2, freq: 110).putAll(in);
		in.postln.play;
		in.delta.wait;
	}
})
)

(
Tdef(\x, {
	|inevent|
	loop {
		Tdef(\a).embed((note: [15, 17], dur: 0.1, n: 13));
		1.wait;
		Tdef(\a).embed((note: 9, dur: 0.4, n:4));
		1.wait;
	}
}).play;
)

//Figure 7.15: A pattern proxy as an entry point into a pattern
Pdefn(\x, Pseq([0, 2, 0, 7, 6, 5, 4, 3], inf));
(
Task{
	var stream = Pdefn(\x).asStream;
	var val;
	loop {
		val = stream.next;
		(instrument: \wave, note: val).play;
		0.2.wait;
	}
}.play;
)
Pdefn(\x, Pseq([0, 2, 0, 8, 6, 5, 2, 3, 4, 5], inf));
Pdefn(\x, Pseq([0, 2, 0, 7, 6, 5, 4, 3].scramble + 4, inf));



//Figure 7.16: Deriving variations from nonexisting streams by math operations

Pdefn(\y, Pdefn(\x) + 2); //derive a variation
Pdefn(\z, Pdefn(\x) + Pseq([0, 5, 0, 7, 2], inf)); //combined stream arrays
Pdefn(\a, Ptuple([Pdefn(\y), Pdefn(\z)]));

(
Task{
	var stream = Pdefn(\a).asStream;
	var val;
	loop {
		val = stream.next.postln;
		(instrument: \wave, note: val, sustain: rrand(0.5, 0.9)).play;
		0.2.wait;
	}
}.play;
)

Pdefn(\x, Pseq([0, 11], inf));
Pdefn(\x, Pseq([0, 2, 0, 7, 6, 5, 4, 3].scramble + 5, inf));
Pdefn(\z, Pdefn(\x) + Pseq([1, 5, 1, 11, 1], inf));
Pdefn(\a, 5);
Pdefn.clear;



//Figure 7.17: Pdef as a player: play, pause, resume
Pdef(\a).play; //play silence in a sequence
Pdef(\a, Pbind(\instrument, \wave)); //insert a sequence of notes
Pdef(\a, Pbind(\instrument, \wave, \dur, Pseq([1, 3, 2, 3], inf)/6));
Pdef(\a).pause;
Pdef(\a).stop;

//Pchain help file: used to combine event patterns
//Examples
(
Pchain(
	Pbind(
		\detune, Pseq([-30, 0, 40], inf),
		\dur, Prand([0.2, 0.4], inf)
	),
	Pbind(
		\degree, Pseq([1,2,3], inf),
		\dur, 1
	)
).trace.play;
)

//also events can be used directly
(
Pchain(
	Pbind(
		\degree, Pseq([1,2,3], inf)
	),
	(detune: [0,4])
).trace.play;
)

//compose some more complicated patterns
(
var a, b;
a = Prand([
    Pbind(\degree, Pseq([0, 1, 3, 5, 6])),
    Pbind(\dur, Pshuf([0.4, 0.3, 0.3]), \degree, Pseq([3, -1]))
], inf);
b = Prand([
    Pbind(\ctranspose, Pn(1, 4)),
    Pbind(\mtranspose, Pn(2, 7))
], inf);
c = Prand([
    Pbind(\detune, Pfuncn({ [0, 10.0].rand }, 5), \legato, 0.2, \dur, 0.2),
    Pbind(\legato, Pseq([0.2, 0.5, 1.5], 2), \dur, 0.3)
], inf);
Pchain(a, b, c).trace.play;
)

//Pattern composition
(Pbind(\degree, Pseq([1,2,3], inf)) <> (detune: [0, 4])).trace.play;

(
a = Pbind(
	\degree, Pseq([1,2,3], inf),
	\dur, Prand([0.2, 0.4], inf
	);

b = Pbind(
	\detune, Pseq([-30, 0, [0, 40]], inf),
	\dur, 0.1
	);

c = b <> a;
c.play; //dur key of a overwritten by b
)
)

//Pbindf
//Examples

(
a = Pbind(
	\x, Pseq([1,2,3]),
	\zzz, 9000
);
b = Pbindf(a,
	\y, Prand([100, 300, 200], inf),
	\zzz, 99
);
x = b.asStream;
)
x.next(());
x.next(());
x.next(());
x.next(());


//Sound examples
(
a = Pbind(\dur, 0.1);
Pbindf(a,
	\freq, Prand([300, 500, 321.2, 399.2], inf)
).play;
Pbindf(a, \freq, Prand([1, 1.2, 2, 2.5, 3, 4], inf) * 200).play;
)

(
//a synthdef
SynthDef(\test, {
	|out, freq=440, amp=0.1, nharms=10, pan=0, gate=1|
	var audio = Blip.ar(freq, nharms, amp);
	var env = Linen.kr(gate, doneAction: Done.freeSelf);
	OffsetOut.ar(out, Pan2.ar(audio, pan, env));
}).add;
)

a = Pbind(\instrument, \wave, \dur, 0.5, \sustain, rand(0.1, 0.4, inf));
Pbindf(a, \freq, Prand([1, 1.2, 2, 2.5, 3, 4], inf) * 200).play;


//Pbindef
//Examples

(
SynthDef(\Pdefhelp, {
	|out, freq, sustain=1, amp=1, pan|
	var env, u = 1;
	env =  EnvGen.ar(Env.perc(0.01, sustain), 1, doneAction: Done.freeSelf);
	5.do {
		var d;
		d = exprand(0.01, 1);
		u = SinOsc.ar(d * 300, u, rrand(0.1, 1.2) * d, 1)
	};
	Out.ar(out, Pan2.ar(SinOsc.ar(u + 1 * freq, 0, amp*env), pan));
}).add;
)

Pbindef(\a, instrument: \Pdefhelp).play;
Pbindef(\a, degree: Pseq([0, 2, 5b, 1b], inf));
Pbindef(\a, dur: 0.1);
Pbindef(\a, degree: Pseq([1b, 5, 3, 1b, 6, 2, 5, 0, 3, 0, 2], inf));
Pbindef(\a, legato: Prand([1.0, 2.4, 0.2], inf), mtranspose: -3);
Pbindef(\a, mtranspose: nil); //remove key

Pbindef(\a, degree: Pseq([1, 2, 3, 4, 5, 6], 1));
Pbindef(\a, degree: Pseq([1, 2, 3, 4, 5, 6], 3), dur: 0.02);
Pbindef(\a, degree: Pseq([1, 2, 3, 4, 5, 6], 3), dur: 0.1);

//apart from this Pbindef behaves like Pdef:

Pbindef(\a).quant = 0.0;
Pbindef(\a, degree: Pseq([1,2,3,4,5,6], 1));
Pbindef(\a).stop;
Pbindef(\a, degree: Pseq([1,2,3,4,5,6], 1)); //does not resume now

Pbindef(\a).playOnce;
Pseq([Pbindef(\a), Pdef(\a)]).play;

Pbindef(\a) === Pdef(\a); //identical

//An already existing Pdef can be incrementally changed

Pdef(\x, Pbind(\instrument, \wave, dur: 0.3));
Pdef(\x).play;

Pbindef(\x, degree: 7.rand+1);
Pbindef(\x, degree: Pseq([0, 7, 3, 7, 4], inf), dur: Pn(Pseries(0.2, -0.02, 10)));
Pbindef(\x, \stretch, 2);
Pdef(\x).stop;


s.boot;
//Figure 7.18:
(
(
Pdef(\x,
	Pbind(
		\instrument, \wave,
		\mod, Pseq([1, 0, 1, 0], inf),
		\dur, Pn(1/2, 8),
		\note, 7
	)
)
);

Pdef(\y,
	Pbindf(
		Pdef(\x),
		\amp, 0.2,
		\note, Pshuf([0, 2, 3, 5], 2) + Prand([0, 5, [0, 4]], inf),
		\dur, Pseq([1,3,2,3], inf) /6
	)
);

(
Pdef(\z, Pbindf(Pdef(\y), \dur, 1/4))
);

//the combination of all placeholders into a new placeholder
(
Pdef(\a,
	Pmul(\dur, Pwhite(-0.02, 0.02) + 1,
		Pseq([
			Ppar([Pdef(\x), Pdef(\y)]),
			Pdef(\x),
			Pdef(\y),
			Pdef(\z),
			Ppar([Pdef(\x), Pbindf(Pdef(\y), \ctranspose, 2)])
		], inf)
	)
)
);
)

//play it
Pdef(\a).play;

(
Pdef(\x,
	Pbind(
		\instrument, \wave,
		\dur, Pseq([1, 2, 3, Prand([3, 2])], inf) / 6,
		\octave, [6,4]
	)
)
)
//release break
(
Pdef(\x,
	Pbind(
		\instrument, \wave,
		\dur, Pseq([1,3,2, Prand([3,2])], 1) /6,
		\octave, [6, 4]
	)
)
)

Pdef(\a).stop;


//Figure 7.19: Simplifying the code in figure 7.18 with Psym
//the combination of all placeholders into a new placeholder
(
Pdef(\b, Pbindf(Pdef(\y), \ctranspose, 2));
Pdef(\a,
	Pmul(\dur, Pwhite(-0.02, 0.02) + 1,
		Psym(Pseq([[\x, \y], \x, \y, \z, [\x, \b]], inf).trace)
	)
).play.fadeTime(4);
)

//Figure 7.20: Using a Pdefn for the sequence of symbols itself
(
Pdefn(\sequence, Pseq([[\x, \y], \x, \y, \z, [\x, \b]], inf));
Pdef(\a,
	Pmul(\dur, Pwhixte(-0.02, 0.02)+1,
		Psym(Pdefn(\sequence).trace)
	)
).play.fadeTime(4);
)

//rewrite the sequence
Pdefn(\sequence, Pseq([\x], inf));
Pdefn(\sequence, Pseq([\x, \y, \x, [\x, \y]], inf));

Pdef(\a).stop;

//Figure 7.21: Event type: "phrase"
(instrument: \x, type: \phrase).play;
//a pattern of overlapping phrases
(
Pbind(
	\type, \phrase,
	\instrument, \x,
	\legato, 2.5,
	\note, Pseq([0, 5, 7], inf)
).play;
)


//Figure 7.22: Recursive Phrasing

(
Pdef(\x, {
	|note=0, n=6, step=3, modulo=15, sustain=1|
	Pbind(
		\instrument, \wave,
		\note, note.value + (Pseries(1, step, n) % modulo) + 7,
		\dur, sustain.value / n
	)
})
)

(
Pdef(\a,
	Pbind(
		\type, \phrase,
		\instrument, \x,
		\note, Pseq([3, [4, 3, 5], [13, 15]], inf),
		\dur, Pseq([1,2,0.5,1.5], inf)
	)
).play;
)

(
Pdef(\a,
	Pbind(
		\type, \phrase,
		\instrument, \x,
		\note, Pseq([0, 5, 4, 8, 0], inf),
		\n, 5,
		\modulo, Prand([3, [4, 3, 5], [13, 15]], inf),
		\recursionLevel, 1,
		\dur, Pseq([1,2,0.5, 1.5], inf) * 2,

	)
).play;
)


//Figure 7.25: Combinations between patterns and ugen graphs using a ProxySpace

(
SynthDef(\train, {
	|out, xfreq=15, sustain=1.0, amp=0.1, pan|
	Line.ar(1, 1, sustain, doneAction: Done.freeSelf);
	OffsetOut.ar(out, Pan2.ar(Impulse.ar(xfreq), pan, amp));
}).add;
)

p = ProxySpace.push;
~z.play;

(
~x = Pbind(
	\instrument, \train,
	\xfreq, Pseq([50, Pwhite(30, 800, 1), 5, 14, 19], inf),
	\sustain, Pseq([Pwhite(0.01, 0.1, 1), 0.1, 1, 0.5, 0.5], inf),
	\pan, Prand([-1, 1], inf) * 0.1
)
)
~y = { Ringz.ar(~x.ar, 5000 * [1, 1.2], 0.01)};
~mod = { LFNoise1.kr(0.1).exprange(200, 5000)};
~z = { ~y.ar * (SinOsc.ar(~mod.kr) + 1)};

(
~x = Pbind(
	\instrument, \train,
	\xfreq, Pseq([50, ~mod, 5, ~mod, 19], inf),
	\sustain, Pseq([Pwhite(0.01, 0.1, 1), 0.1, 1, 0.5, 0.5], inf),
	\pan, Prand([-1, 1], inf) * 0.1
)
)


//Figure 7.26: Combninations between patterns and ugen graphs
Ndef(\z).play;

//a pattern in an audio rate node proxy
(
Ndef(\x,
	Pbind(
		\instrument, \train,
		\xfreq, Pseq([50, Pwhite(30, 800, 1), 5, 14, 19], inf),
		\sustain, Pseq([Pwhite(0.01, 0.1, 1), 0.1, 1, 0.5, 0.5], inf),
		\pan, Prand([-1, 1], inf) * 0.1
	)
)
)


//History
History.clear.end;
History.start;
1 + 2;
p = ProxySpace.push(s.boot);
~a = { Dust.ar([1, 1] * 30) * 0.3};
~a.play;
~a.end(3);

History.started;
History.end;
History.document;
History.logFolder;
History.showLogFile;




//Figure 7.27: Using a Tdef to create textures of overlapping synths within a node proxy
Ndef(\x).play;
Ndef(\x, { |freq=5, detune=0| Impulse.ar(freq * [detune, 1-detune])*0.2});

(
Tdef(\c, {
	loop {
		Ndef(\x).fadeTime = rrand(0.1, 3.5);
		Ndef(\x).send([\freq, exprand(2, 400), \detune, [0.0, 1.0].choose.rand]);
		2.wait;
	}
}).play;
)


g = History.makeWin;
History.play(0);






























































































































