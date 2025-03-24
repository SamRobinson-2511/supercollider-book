//16.2 Perception at the Micro Time Scale
{Impulse.ar(XLine.kr(12, 48, 6, doneAction: 2)) * 0.1!2}.play; //up
{Impulse.ar(XLine.kr(48, 12, 6, doneAction: 2)) * 0.1!2}.play; //down
{Impulse.ar(MouseX.kr(12, 48, 1)) * 0.5!2}.play; //mouse-controlled

(
Pbindef(\grain,
	\instrument, \gabor1, \freq, 1000, \dur, 1,
	\sustain, Pseq([0.001, 0.1], inf),
 	\amp, Pseq([0.1, 0.1], inf)
).play;
)

(
Pbindef(\grain, \sustain, Pseq([0.001, 0.1], inf), \amp, Pseq([0.2, 0.1], inf)).play;
)

//Figure 16.1: short grain durations, transitions from pitched to colored clicks

(
SynthDef(\gabor, {
	|out, freq=440, sustain=1, pan, amp=0.1, width=0.25|
	var env = LFGauss.ar(sustain, width, loop: 0, doneAction: 2);
	var son = FSinOsc.ar(freq, 0.5pi, env);
	OffsetOut.ar(out, Pan2.ar(son, pan, amp));
}, \ir ! 6).add;

SynthDef(\gabor1, {
	|out, amp=0.1, freq=440, sustain=0.01, pan|
	var snd = FSinOsc.ar(freq);
	var env = EnvGen.ar(Env.sine(sustain, amp), doneAction: 2);
	OffsetOut.ar(out, Pan2.ar(snd*env, pan));
}, \ir ! 5).add;
)

(
Pbindef(\grain,
	\instrument, \gabor,
	\freq, 1000,
	\dur, 0.5,
	\sustain, 20/1000,
	\amp, 0.2
).play;
)

Pbindef(\grain, \sustain, 10/Pkey(\freq));
Pbindef(\grain, \sustain, 5/Pkey(\freq));
Pbindef(\grain, \sustain, 3/Pkey(\freq));
Pbindef(\grain, \sustain, 2/Pkey(\freq));
Pbindef(\grain, \sustain, 1/Pkey(\freq));

Pbindef(\grain, \sustain, Pseq((10..1)) / Pkey(\freq)).play;
Pbindef(\grain, \sustain, Pbrown(1, 10, 3) / Pkey(\freq), \dur, 0.1).play;


//Figure 16.2: Perception of short silences

(
p = ProxySpace.push;

~source = { SinOsc.ar * 0.1 };
~silence = { |silDur=0.01|
	EnvGen.ar(
		Env([0, 1, 1, 0, 0, 1, 1, 0], [0.01, 2, 0.001, silDur, 0.001, 2, 0.01]),
		doneAction: 2) ! 2
};
~listen = ~source * ~silence;
~listen.play;
)
~silence.spawn([\silDur, 0.001]);
~silence.spawn([\silDur, 0.003]);
~silence.spawn([\silDur, 0.01]);
~silence.spawn([\silDur, 0.03]);

~source = { WhiteNoise.ar * 0.1 };

p.pop;

//Figure 16.3: Order confusion with sounds in fast succession

(
SynthDef(\percSin, {
	|out, amp=0.1, freq=440, sustain=0.01, pan|
	var snd = FSinOsc.ar(freq);
	var env = EnvGen.ar(
		Env.perc(0.1, 0.9, amp), timeScale: sustain, doneAction:2);
	OffsetOut.ar(out, Pan2.ar(snd*env, pan));
},
\ir ! 5
).add;
)


(
Pbindef(\lo,
	\instrument, \percSin,
	\sustain, 0.5,
	\freq, 250,
	\amp, 0.2,
	\dur, 0.5,
	\lag, 0
).play;
Pbindef(\hi,
	\instrument, \percSin,
	\sustain, 0.05,
	\freq, 875,
	\amp, 0.1,
	\dur, 0.5,
	\lag, 0
).play;
)
Pbindef(\hi, \lag, 0.1);
Pbindef(\hi, \lag, 0.03);
Pbindef(\hi, \lag, 0.01);
Pbindef(\hi, \lag, 0.003);


//Figure 16.12: Control Strategies applied to different parameters































