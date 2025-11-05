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









































