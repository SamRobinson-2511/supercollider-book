//3. Composition with SuperCollider

//3.1.1: Coding for flexibility
// - environment variables


~something = {Pulse.ar(80)*EnvGen.ar(Env.perc, doneAction:2)};
~something.play;

//3.2: Control Structures
//3.2.1: Clocks, Routines, and Tasks

SystemClock.sched(2, {"foo".postln;});

//"foo" repeats every second
SystemClock.sched(0, {"foo".postln; 1.0});
//"bar" repeats at a random delay
SystemClock.sched(0, {"bar".postln; 1.0.rand});
SystemClock.clear;

//SystemClock: cannot be used to schedule events which affect native GUI widgets on OSX (use AppClock)

//causes an "operation cannot be called from this Process" error
SystemClock.sched(1, {Window.new.front});
//defer reschedules GUI code on the AppClock
SystemClock.sched(1, {{ Window.new.front}.defer});


//TempoClock: schedule events on beats rather than seconds
//Create instance of TempoClock and send sched messages to it

(
t = TempoClock.new; //make new TempoClock
t.sched(0, {"Hello!".postln; 1});
)
t.tempo = 2; //twice as fast
t.clear;


//Routines: like functions that you can evaluate a bit at a time
(
r = Routine({
	"foo".yield;
	"bar".yield;
});
)

r.value; //foo
r.value; //bar
r.value; //yields 'nil', value: next

(
r = Routine({
	"foo".postln;
	1.yield; //reschedule after 1 second
	"bar".postln;
	1.yield;
	"foobar".postln;
});
SystemClock.sched(0, r);
)


//Figure 3.1: A simple Routine illustrating a musical use of yield

s.boot;
(
r = Routine({
	x = Synth(\default, [freq: 76.midicps]);
	1.wait;

	x.release(0.1);
	y = Synth(\default, [freq: 73.midicps]);
	"Waiting...".postln;
	nil.yield; //fermata

	y.release(0.1);
	z = Synth(\default, [freq: 69.midicps]);
	2.wait;
	z.release;
});
)

//do this then wait for the fermata
r.play;
//feel the sweet tonic . . .
r.play;

//Fork: shortcut for creating a Routine and playing it in a Clock
(
{
	"something".postln;
	1.wait;
	"something else".postln;
}.fork;
)


//Figure 3.2: Using Task so you can pause the sequence

(
t = Task({
	loop({ //loop the whole thing
		3.do({
			x.release(0.1);
			x = Synth(\default, [freq: 76.midicps]);
			0.5.wait;
			x.release(0.1);
			x = Synth(\default, [freq: 73.midicps]);
			0.5.wait;
		});
		"I'm waiting for you to press resume".postln;
		nil.yield; // fermata
		x.release(0.1);
		x = Synth(\default, [freq:69.midicps]);
		1.wait;
		x.release;
	});
});

w = Window.new("Task Example", Rect(400, 400,  200, 30)).front;
w.view.decorator = FlowLayout(w.view.bounds);
Button.new(w, Rect(0, 0, 100, 20)).states_([["Play/Resume", Color.black, Color.clear]]).action_({t.resume(0);});
Button.new(w, Rect(0, 0, 40, 20)).states_([["Finish", Color.black, Color.clear]]).action_({
	t.stop;
	x.release(0.1);
	w.close;
});
)


//Task provides ability to pause and prevents calling play twice

r.reset;


//3.2.2: Other Ways of Controlling Time in SC

//Patterns and Score
//Patterns: provide a high-level abstraction based on Streams of events and values, reusable
//value: opportunity for polymorphism (different objects understand the same message)

//Score object: ordered list of timees and OSC commands (nested arrays)

/*
[
[time1, [cmd1]],
[time2, [cmd2]],
...
]
*/

//use Score for "messaging style" rather than "object style"
//provides functionality for non-real-time synthesis

//Figure 3.3: Nesting Tasks inside Routines

(
r = Routine({
	c = TempoClock.new; //make a TempoClock
	//start a 'wobbly' loop
	t = Task({
		loop({
			x.release(0.1);
			x = Synth(\default, [freq: 61.midicps, amp:0.2]);
			0.2.wait;
			x.release(0.1);
			x = Synth(\default, [freq: 67.midicps, amp:0.2]);
			rrand(0.75, 0.25).wait; //random wait from 0.1 to 0.25 seconds
		});
	}, c); //use the TempoClock to play this Task
	t.start;
	nil.yield;

	//now add some notes
	y = Synth(\default, [freq: 73.midicps, amp:0.3]);
	nil.yield;
	y.release(0.1);
	y = Synth(\default, [freq:79.midicps, amp:0.3]);
	c.tempo = 2; //double time
	nil.yield;
	t.stop; y.release(0.1); x.release(0.1); //stop the Task and Synths
});
)
r.next;
r.next;
r.next;
r.next;

//Figure 3.4: Using Patterns within a Task


(
p = Pxrand([64, 66, 68, 70, 71, 73, 74, 76], inf).asStream; //random notes from lydian b7 scale
//ordered sequence of durations
q = Pseq([1, 2, 0.5], inf).asStream;
t = Task({
	loop({
		x.release(2);
		x = Synth(\default, [freq: p.value.midicps]);
		q.value.wait;
	});
});
)
t.start;
t.stop; x.release(2);

//Figure 3.5: Thanks to polymorphism, we can substitute objects that understand the same message

s.boot;
(
p = 64 ;
q = Pseq([1,2,0.5], inf).asStream;
t = Task({
	loop({
		x.release(2);
		x = Synth(\default, [freq:p.value.midicps]);
		q.value.wait;
	});
});
t.start;
)
p = Pseq([64, 66, 68], inf).asStream;
p = { rrand(64, 76) };
t.stop; x.release(2);


//Figure 3.6: Using "messaging style": Score
(
SynthDef(\ScoreSine, {
	|freq=440|
	Out.ar(0, SinOsc.ar(freq, 0, 0.2) * Line.kr(1, 0, 0.5, doneAction:2))
}).add;
x = [
	//args for s_new are synthdef, nodeID, addAction, targetID, synth args . . .
	[0.0, [\s_new, \ScoreSine, 1000, 0, 0, \freq, 1413 ]],
	[0.5, [\s_new, \ScoreSine, 1001, 0, 0, \freq, 712 ]],
	[1.0, [\s_new, \ScoreSine, 1002, 0, 0, \freq, 417 ]],
	[2.0, [\c_set, 0, 0]] // dummy command to mark end of NRT synthesis time
];
z = Score(x);
)
z.play;


//Figure 3.7: Executing one line at a time **FIGURE OUT PATH
(
//here's a SynthDef that allows us to play from a buffer, with a fadeout
SynthDef(\playbuf, {
	|out=0, buf, gate=1|
	Out.ar(out, PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1.0) * Linen.kr(gate, doneAction:2);
	)
}).add;
//load all the paths in the sounds/ folder into buffers
~someSounds = "/Volumes/Samsung 870 QVO/SAMPLES/rhythm-lab.com_amen_vol.1/WAV/*".pathMatch.collect{|path| Buffer.read(s, path)};
)
//now here's the score, so to speak
//execute one line at a time
~nowPlaying = Synth(\playbuf, [buf:~someSounds[0]]);
~nowPlaying.release; ~nowPlaying = Synth(\playbuf, [buf: ~someSounds[1]]);
~nowPlaying.release; ~nowPlaying = Synth(\playbuf, [buf: ~someSounds[2]]);
~nowPlaying.release;
//free buffer memory
~someSoundsBuffered.do(_.free);


//3.2.3: Cue Players
//play from RAM or HD?

~myBuffer = Buffer.read(s, "/Volumes/Samsung 870 QVO/SAMPLES/rhythm-lab.com_amen_vol.1/WAV/cw_amen20_164.wav");
~myBuffer.play; //play it and notice it will release the node after playing



//Figure 3.8: Play cues with a simple GUI

(
SynthDef(\playbuf, {
	|out=0, buf, gate=1|
	Out.ar(out, PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop:1.0) * Linen.kr(gate, doneAction:2) * 0.6;)
}).add;
~someSounds = "/Volumes/Samsung 870 QVO/SAMPLES/rhythm-lab.com_amen_vol.1/WAV/*".pathMatch.collect{|path| Buffer.read(s, path)};
n = 0; //a counter

//GUI code
w = Window.new("Simple CuePlayer", Rect(400, 400, 200, 30)).front;
w.view.decorator = FlowLayout(w.view.bounds);
Button.new(w, Rect(0, 0, 80, 20)).states_([["Play Cue", Color.black, Color.clear]]).action_({
	if(n < ~someSounds.size, {
		if(n != 0, {~nowPlaying.release;});
		~nowPlaying = Synth(\playbuf, [buf: ~someSounds[n]]); n=n+1;
	});
});
//this sets the counter to the first queue
Button.new(w, Rect(0, 0, 80, 20)).states_([["Stop / Reset", Color.black, Color.clear]]).action_({n=0; ~nowPlaying.release; });
//free the buffers when the window is closed
w.onClose = {~someSounds.do(_.free);};
)

//Figure 3.9: Gathering up files for multichannel cues

// gather all you folder paths
//this will path match each folder in the collection, i.e. we will have a collection of collections of paths
~groupOfindivCueFolders = "/Volumes/Samsung 870 QVO/SAMPLES/rhythm-lab.com_amen_vol.1/WAV/*".pathMatch.collect{|item| (item.asSymbol++"*").pathMatch };

Post << ~groupOfindivCueFolders; //see them all

//check how many cues you will have in the end
~groupOfindivCueFolders.size;

//automate the buffering process for all cues
~bufferedCues = ~groupOfindivCueFolders.collect{|item, i| item.collect{|path| Buffer.read(s, path)}}; //now all cue files in buffers

~bufferedCues[0]; //here is cue 1

//play them all in a Group, using our previous SynthDef
//we use bind here to ensure they start simultaneously
(
s.bind({
	~nowPlaying = Group.new(s); // a group to put all the channel synths in
	~bufferedCues[0].do({|cue| Synth(\playbuf, [buf:cue], ~nowPlaying)})
});
)
~nowPlaying.release;


//3.3: Generating Sound Material

//3.3.1: Recording
//make a sound that responds idiosyncratically to input amplitude
//Server class:


s.boot;
(
//evaluate first
b = Buffer.read(s, "/Volumes/Samsung 870 QVO/SAMPLES/rhythm-lab.com_amen_vol.1/WAV/cw_amen01_175.wav"); //a source
s.prepareForRecord; //prepare the server to record (you must do this first)
s.recSampleFormat_("int16");
)

(
//simultaneously start the processing and recording
s.bind({
	//here's our funky effect
	x = {var columbia, amp;
		columbia = PlayBuf.ar(1, b, loop:1);
		amp = Amplitude.ar(columbia, 0.5, 0.5, 4000, 250); //'sticky' amp follower
		Out.ar(0, Resonz.ar(columbia, amp, 0.02, 3)); // filter freq follows amp
	}.play;
s.record;
})
)

s.pauseRecording; //pause recording
s.record; //start recording again
s.stopRecording;

x.free;

//3.3.2: Thinking in the abstract

//generalize code
(
{
	Resonz.ar(Dust.ar(5), 300, 0.001, 100) + Resonz.ar(Dust.ar(5), 600, 0.001, 100) + Resonz.ar(Dust.ar(5), 900, 0.001, 100) * 3.reciprocal;
}.play;
)

//abstracted

(
f = 300;
n = 3;
{
	Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), f*(i+1), 0.001, 100)}) * n.reciprocal;
}.play;
)


(
f = 40;
n = 50;
{
	Mix.fill(n, {|i| Resonz.ar(Dust2.ar(5), f*(i+1), 0.001, 100)}) * n.reciprocal;
}.play;
)

//Figure 3.12: A variable number of resonators with an automatically created GUI
(
f = 300;
n = 30; //number of resonators
t = Array.fill(n, {|i|
	{
		Resonz.ar(Dust2.ar(5), f * (i + 1), 0.001, 300) * n.reciprocal; //scale to ensure no clipping
	}.play;
});


//now make a GUI (scrolling window so we don't run out of space)

w = Window.new("Buttons", Rect(50, 100, 290, 250), scroll:true);
w.view.decorator = FlowLayout.new(w.view.bounds); //auto layout the widgets
n.do({|i|
	Button.new(w, Rect(0, 0, 130, 30)).states_([
		["Freq" + (f *(i+1)) + "On", Color.black, Color.white],
		["Freq" + (f *(i+1)) + "Off", Color.white, Color.black]
	])
	.action_({|butt| t[i].run(butt.value == 0);
	});
});
w.front;
)



//3.3.3: Gestures
//3.3.4: Making Empty Gestures

//1. make a list where buffers will be stored
s.boot;

(
//you will be able to add multiple sound files; just shift click when selecting!
var file, soundPath;
~buffers = List[];
Dialog.openPanel({
	|paths|
	paths.do({
		|soundPath|
		soundPath.post;
		~buffers.add(Buffer.read(s, soundPath););
	});
});

)
~buffers.size;
~buffers[0];
~buffers[0].play;
(
//buffer player with done action control of envelope and panning
SynthDef(\samplePlayer, {
	|out=0, buf=0, rate=1, at=0.01, rel=0.1, pos=0, pSpeed=0, lev=0.5|
	var sample, panT, amp, aux;
	sample = PlayBuf.ar(1, buf, rate*BufRateScale.kr(buf), 1, 0, 0);
	panT = FSinOsc.kr(pSpeed);
	amp = EnvGen.ar(Env.perc(at, rel, lev), doneAction:20);
	Out.ar(out, Pan2.ar(sample, panT, amp));
}).add;
)

Synth(\samplePlayer, [\out, 0, \bufnum, ~buffers[0], \rel, 0.25]);






