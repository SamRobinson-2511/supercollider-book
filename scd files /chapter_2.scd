//2.1:
//2.2: Ugens, scsynth, and SuperCollider

(
SynthDef(\UGen_ex1a, {
	Out.ar(0, SinOsc.ar(440, 0, 0.1))
}).add;
)
a = Synth(\UGen_ex1a);

(
SynthDef(\UGen_ex1b, {
	Out.ar(0, SinOsc.ar([440, 446, 448.5, 882], 0, 0.1))
}).add;
)
a = Synth(\UGen_ex1b)

(
SynthDef(\UGen_ex1c, {
	Out.ar(
		0,
		SinOsc.ar(0, SinOsc.ar([440, 446, 448.5, 882],
			0,
			[0.1, 0.2, 0.3, 0.4])))
}
)
)