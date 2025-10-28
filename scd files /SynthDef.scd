//SynthDef.wrap(function, rates, prependArgs)

(
d = SynthDef(\demoWrapping, {
	|out|
	Out.ar(out, SynthDef.wrap({
		|freq|
		SinOsc.ar(freq);
	}));
});
)
d.allControlNames;

SynthDef.synthDefDir;

(
SynthDef(\help_synth, {
	|out, freq=800, sustain=1, amp=0.1|
	Out.ar(out, SinOsc.ar(freq, 0.02) * Line.kr(amp, 0, sustain, doneAction: Done.freeSelf))
}).add;
)
x = Synth(\help_synth);
