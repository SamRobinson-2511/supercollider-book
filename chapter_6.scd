//6.1: SynthDefs, Events, and Patterns
//6.1.1: SynthDefs:
//assigns name to a 'patch diagram' of UGens and additional names to control inputs

(
SynthDef(\sine, {
	|gate=1, out=0, freq=400, amp=0.4, pan=0, ar=1, dr=1|
	var audio;
	audio = SinOsc.ar(freq, 0, amp);
	audio = audio * Linen.kr(gate, ar, 1, dr, 2);
	audio = Pan2.ar(audio, pan);
	OffsetOut.ar(out, audio);
}).add;
)

//6.1.2: Events and Key/Value Arrays
//Key: Symbol
//Value: any object of the language (i.e. Number, Array, Symbol, Function)
//Event: collection of key/value pairs that defines a specific action
//Events also specify a time increment that is returned in response to the message 'delta', returned determined by taking the product of the values of the keys \dur and \stretch
//By default, Events specify notes to be played on the server

//Figure 6.2: Example of a key/value Array and a note event
(
a = [
	type: \note,
	instrument: \sine,
	freq: 400,
	amp: 0.1,
	pan: 0,
	ar: 2,
	dr: 4,
	sustain: 2
];

e = (
	type: \note,
	instrument: \sine,
	freq: 400,
	amp: 0.1,
	pan: 0,
	ar: 2,
	dr: 4,
	sustain: 2
);
e.play;
)

//6.1.3: Sequences of Values and Events
//Patterns specify sequences of values

//Figure 6.3: The OSC commands created by the note event
e.asOSC.do{|osc| osc.postcs;}

//Figure 6.4: Two ways of writing the same event pattern
(
Pbind( *[
	dur: 0.2,
	freq: Pseq([100, 200, 300, 400, 500, 600, 700, 800])
]);
)

(
Pbind(
	\dur, 0.2,
	\freq, Pseq([100, 200, 300, 400, 500, 600, 700, 800])
);
)

//Figure 6.5: A more elaborate event pattern
(
p = Pbind(*[
	instrument: \default,
	detune: [0,1,3],
	freq: Pseq( (1..11)*100, 4 * 5 * 7),
	db: Pseq([-20, -40, -30, -40], inf),
	pan: Pseq([-1.0, 0, 1, 0], inf),
	dur: Pseq([0.2, 0.2, 0.2, 0.2, 0.4, 0.4, 0.8], inf),
	legato: Pseq([2, 0.5, 0.75, 0.5, 0.25], inf)
]);
//render 40 seconds of the pattern in the file named "sf.aif"
p.render("sounds/sf.aif", 40);
//now play the pattern in real time
p.play;
)


//6.2: The Default Event
//6.2.1: Event Types
//default Event contains an extensible collection of event types that specify actions to be taken in response to play

//Figure 6.6: Using Event Types
(
(
type: \group,
id: 2
).play;

(
type: \note,
sustain: 100,
group: 2
).play;
)

(
(type: \off, id: 2).play;
(type: \kill, id: 2, lag: 3).play;
)


//Figure 6.7: Chord Events

//2nd inversion - e loudest
(degree: [-3, 0, 2], sustain: 2, db: [-20, -20, -10]).play;

//2nd inversion - c loudest
(degree: [-3, 0, 2], sustain: 2, db: [-20, -10, -20]).play;

//note 'fattened' by three detuned copies
(degree: 0, sustain: 2, detune: [0,3,5]).play;

//each detune is assigned to a different pitch, fat free
(degree: [-3, 2, 4], sustain: 2, detune: [0,3,5]).play;

//detune rotates through each note in the chord
(degree: [-3, 2, 4], sustain: 2, detune: [0,0,0,3,3,3,5,5,5]).play;

//6.2.3: Note Events and Chords

//6.3: Patterns
//6.3.1: An Overview of Patterns and Streams

//Patterns = musical notation
//Trivial Patterns: a pattern that specifies a sequence whose values are simply the sequence itself
//Nontrivial Patterns: specify sequences with changing values (i.e. Numbers and Symbols)

//.asStream: plays pattern, returns Sream object that will generate the sequence
//one element at a time with .next
//Event Streams: streams created by event patterns


//6.3.2: Combining Patterns
//Patterns: can be used recursively in the definition of other patterns

//Numerical patterns can be combined arithmetically

a = Pseq([1, 2, 3], 1);
b = Pseq([a, 3, 2, 1], 2);
a + b;
a * b * 33;
midiratio(b);
a round: 4;

//Event patterns: cannot be combined arithmetically. Sequential and Parallel combinations are made using the patterns Pseq and Ppar

a = Pbind(*[dur: Pseq([0.4], 5)]);
b = Pbind(*[degree: Pseq([10, 6,], inf), dur: Pseq([0.5], 4)]);

Pseq([a, b], 2).play;
Ppar([a, b], 4).play;


//6.3.3: Time-Based Pattern Classes
//Pstep + Pseg: specify sequences that are sampled as functions of time

//6.3.4: Interdependent Key Values in Event Patterns

(
Pbind(*[
	#[degree, dur], Pseq([[0,1], [3, 1/2], [6, 1/3], [8, 1/4], [7, 1]]),
	db: -20
]).play;
)

//Figure 6.8: Interdependent key values in a pattern
(
Pbind(*[
	stretch: Pseg([0, 0.1, 0.2, 1], 8).linexp(0, 1, 1, 0.125),
	midinote: 100.cpsmidi,
	harmonic: Pwhite(1, 16),
	legato: Pkey(\stretch) * Pkey(\harmonic)/2,
	db: -10 - Pkey(\harmonic),
	detune: Pwhite(0.0, 3.0),
	dur: 0.2
]).play;
)

//Figure 6.9: Chaining event patterns
(
a = Pbind(*[
	scale: Pn( Pstep([[0,2,4,5,7,9,11], [0,1,3,5,6,8,11]], 5) ),
	db: Pn(Pseg([-20, -30, -25, -30], 0.4))
]);

b = Pbind(*[
	degree: [0,2,4],
	mtranspose: Pbrown(0, 6, 1),
	dur: 0.4,
	db: -35
]);

c = Pbind(*[
	degree: [0, 2, 4],
	mtranspose: Pbrown(0, 6, 1),
	dur: 0.4,
	db: -35
]);
d = Pchain(Ppar([b, c]),a);
d.play;
)
d.free;


//6.3.5: Defining Patterns with Pfunc and Prout
(
Prout({|ev| //modifies protoEvents
	ev = (freq: 400).embedInStream(ev.copy);
	ev = (freq: 500).embedInStream(ev.copy);
	ev = (freq: 600).embedInStream(ev.copy);
	ev = (freq: 700).embedInStream(ev.copy);
	ev = (freq: 800).embedInStream(ev.copy);
	ev = (freq: 900).embedInStream(ev.copy);
}).play;
)


//Figure 6.10: Using a Prout to define and play patterns on the fly

(
Prout({
	|ev|
	var pat, refPat;
	refPat = Pbind(*[dur: 0.2, note: Pseq([0, 0, 0, 7, 0, 7])]);

	loop {
		ev = refPat.embedInStream(ev);

		pat = Pbind(*[
			dur: [0.2, 0.4].choose,
			note: Pseq(Array.fill(5, { 10.rand }), 3.rand )
		]);
		ev = pat.embedInStream(ev);

	}
}).play;
)

//Figure 6.11: Using Prout to define value and event patterns

(
~patA = Pbind(*[
	dur: 0.2,
	degree: Prout({ |ev|
		var noteArray = (0..5);
		loop {
			ev = Pseq(noteArray).embedInStream(ev);
			noteArray[6.rand] = 7.rand;
		}
	})
]);

~patB = Prout({|ev|
	var pat, pats = [
		Pbind(*[degree: Pseq([ 0, 7]), dur: 0.2 ]),
		Pbind(*[degree: Pseq([ 11, 7]), dur: 0.2 ]),
		Pbind(*[degree: Pseq([ 16, 7]), dur: 0.2 ]).
		(type: \rest, delta: 1)
	];

	loop {
		pat = pats.choose;
		ev = pat.embedInStream(ev);
	}
});

Pchain(
	Pbind(*[
		db: Pn(Pstep([-15, -25, -25, -20, -30, -25], 0.2)) + Pseg([-30, -5, -10, -40], 12)
	]),
	Ptpar([
		0, ~patA,
		0, ~patA,
		12, ~patB
	])
).play;
)

//Figure 6.12: Rendering and playing a pattern

(
~pattern = Pbind(*[
	instrument: \default,
	freq: Pseq([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100], 5),
	db: Pseq([-10, -30, -20, -30], inf),
	dur: Pseq([0.2, 0.2, 0.2, 0.2, 0.4, 0.4, 0.8], inf),
	legato: Pseq([2, 0.5, 0.75, 0.5, 0.25], inf)
]);

~score = ~pattern.asScore(24 * 11/7);
~score.render(thisProcess.platform.recordingsDir ++ "/test.aif");
SoundFile(thisProcess.platform.recordingsDir ++ "/test.aif").play;
)



//6.4: Timing Considerations

//6.4.1: Timing and Articulation

//using \lag and \timingOffset and \strum


(lag: 0, strum: 0.1, note: [12, 16, 19], sustain: 1).play;

//negative values for \strum will cause the notes in the chord to precede the beat

//strumEndsTogether = true: individual notes will be lengthened or shortened to end the chord at the time specified by \sustain

(lag: 0, strum: -1, note: [12, 16, 19], sustain: 1).play;



