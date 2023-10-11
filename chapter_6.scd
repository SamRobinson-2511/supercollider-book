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




