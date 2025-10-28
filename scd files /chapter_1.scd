


Server.default = s = Server.internal.boot;

//1.1: Hello World

"Hello World" // client side

play({SinOsc.ar(LFNoise0.kr(12, mul: 600, add: 1000), 0.3)})

play({RLPF.ar(Dust.ar([12, 15]), LFNoise1.ar(1/[3,4], 1500, 1600), 0.02)})

//Figure 1.1: example of additive synthesis

(
play({
	var sines = 5, speed = 6;
	Mix.fill(sines,
		{
			|x|
			Pan2.ar(
				SinOsc.ar(
					x+1*100,
					mul: max(
						0,
						LFNoise1.kr(speed) +
						Line.kr(1, -1, 30)
					)
				), rand2(1.0)
			)
		}
	)/sines
})
)

//1.2 Messages and Arguments
rand(100)
rand(100.0)

//exponentially weighted randomness
exprand(1.0, 100.0);

thisThread.randSeed = 666; {rand(10.0)} ! 10; //seeding the random number generator

dup("echo", 20);
round([3.141, 5.9265, 359.98], 0.01)
sort([23, 54, 678, 1, 91, 34, 78])
round(dup({exprand(1,10)}, 100), 0.1)
sort(round(dup({exprand(1, 10)}, 100), 0.1))

//1.3: Nesting

(
play(
	{
		CombN.ar(
			SinOsc.ar(
				midicps(
					LFNoise1.ar(3, 24,
						LFSaw.ar([5, 5.123], 0, 3, 80)
					)
				),
				0, 0.4),
			1, 0.3, 2)
	}
)
)


//1.4: Receiver.message, Comments
[45, 13, 10, 498, 78].sort // collection of items, do this; sort yourself "echo". dup (20) / / echo, do this; repeat yourself 20 times
50.midicps // the number 50, do this; convert yourself into Hz
444. cpsmidi // 444, do this; convert yourself into a midi number
100. rand // 100, do this; pick a number between 0 and yourself
{100. rand}.dup (50) // random picking function, do this; repeat 50 times [1.001, 45.827, 187.18].round(0.1) // collection of items; round to 0.1


//functional v. receiver notation = rand(100) v. 100.rand

/*
Things that begin with upper- case letters (Mix, SinOsc, Pan2, Array) are nearly always written as receiver. messages.
Numbers, arrays, and text can be written either way, depending on whichever si clearer in a given context. For example, receiver notation can be used to string to-
gether a series of messages as an alternative to nesting, as shown below. The result of each receivermessage pair becomes the receiver for the next message. Note the subtlebut important distinction between the periodsin 1000. 0. rand. The first is afloat- ing point, indicating that the number is a float. The second is a dot that sends the message rand to 1000.0.
*/

1000.0 //a number
1000.0.rand //choose a number between 0 and 1000
1000.0.rand.round(0.01) // choose a number and round it
1000.0.rand.round(0.01).post //choose, round, then post
{1000.0.rand.round(0.01).postln}.dup(100).plot //choose, round, dup, plot
{1000.0.rand.round(0.01).postln}.dup(100).postln.sort.plot // choose etc., sort, plot

//1.5: Enclosures

//array methods
[0, 11, 10, 1, 9, 8, 2, 3, 7, 4, 6, 5].reverse; //retrograde
12 - [0, 11, 10, 1, 9, 8, 2, 3, 7, 4, 6, 5].reverse; //retrograde inversion
[0, 2, 4, 5, 6, 7, 9, 11].scramble; //diatonic scale
[60 ,62, 64, 65, 67, 69, 71].mirror; //pentatonic
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].rotate(1)
[60, 62, 64, 65, 67, 69, 71].midicps.round(0.1) //convert midi to hz
[1, 0.75, 0.5, 0.25, 0.125].choose //maybe durations?
0.125 * [1,2,3,4,5,6,7,8].choose //multiples of smallest quantize value
[1,2,3,4,5,6,7,8,9,10,11].permute(6)

//functions
exprand(1, 1000.0); //prints random number
{exprand(1, 1000.0)};


dup(rand(1000.0), 5) //picks a number, duplicates it
dup({rand(1000.0)}, 5) //duplicates the function of picking a random number

[rand(1000.0),rand(1000.0),rand(1000.0),rand(1000.0),rand(1000.0)]


//function messages: plot, play, scope, dup

{LFNoise0.ar}.play; //play a series of random numbers
{LFNoise0.ar(10000)}.plot; //plot those numbers
{LFNoise0.ar(10000)}.scope; //play and show on a scope
{100.rand}.dup(10);//pick ten random numbers
{100.rand} ! (10); //same as above
{100.rand}.dup(10).postln.plot; //pick ten numbers, post, then plot them
{100.rand}.dup(100).sort.plot; //pick 100 numbers, sort them, plot them



//1.6: Multichannel expansion

{Blip.ar(25, LFNoise0.kr(5, 12, 14), 0.3)}.play; //single channel
{Blip.ar(25, LFNoise0.kr([5,10], 12, 14), 0.3)}.play; //stereo
{Blip.ar(25, LFNoise0.kr([5,10,2,25], 12, 14), 0.3)}.play; //quad
{Blip.ar(25, LFNoise0.kr([5,4,7,9,5,1,9,2], 12, 14), 0.3)}.play; //8 chan

//1.7: Help!
{PMOsc.ar(440,550,7)}.play; //like an FM radio

//nesting arguments
{PMOsc.ar(440, MouseX.kr(1, 550), MouseY.kr(1, 15))}.play;

//use keyword assignments
{PMOsc.ar(100, 500, 10, 0, 0.5)}.play; //all arguments are listed in order
{PMOsc.ar(carfreq:100, modfreq:500, pmindex:10, mul:0.5)}.play; //keywords
{PMOsc.ar(carfreq:100, mul:0.5, pmindex:10, modfreq:500)}.play; //mixed

//args in any order
{SinOsc.ar(mul:MouseX.kr(0, 1.0))}.scope;

(
{PMOsc.ar(
	carfreq: Line.kr(0.25, 1000, 0.25),
	modfreq: Line.kr(0.2, 200, 0.125),
	pmindex: Line.kr(125, 0.5, 0.3),
	mul: 0.5
)}.play;
)


//Figure 1.4: VCO, VCF, VCA
(
{
	Blip.ar(
		TRand.kr( //frequency, or VCO
			100, 1000,
			Impulse.kr(Line.kr(1,20,60))), //trigger
		TRand.kr( //# harmonics, or VCF
			1,10, //range
			Impulse.kr(Line.kr(1,20,60))), //trigger
		Linen.kr( //mul, or amp VCA
			Impulse.kr(Line.kr(1,20,60)), //trigger
			0, //attack
			0.5, //sustain level
			1/Line.kr(1,20,60)) //trigger
	)
}.play;
)


//1.5: Variables

(
a = 440;
b = 3;
c = "math operations";
[c,a,b,a*b,a+b,a.pow(b), a.mod(b)]
)

(
{
	r = MouseX.kr(1/3,10);
	SinOsc.ar(mul: Linen.kr(Impulse.kr(r), 0, 1, 1/r))
}.play;
)


//Figure 1.5: Synthesis example with variables and statements
(
//run this line first
p = {
	r = Line.kr(1,20,60); //rate
	/*r = LFTri.kr(1/10) * 3 + 7;*/
	t = Impulse.kr(r);
	e = Linen.kr(r);
	f = TRand.kr(1,10,t);
	Blip.ar(f*100,f,e)
}.play;
)

p.free;

//variable names must begin with lowercase letters a-z and be contiguous

//Figure 1.6: Phase modulation with modulator as ratio
(
{
	r = Impulse.kr(10);
	c = TRand.kr(100, 5000, r);
	m = TRand.kr(100, 5000, r);
	PMOsc.ar(c, m, 12)*0.3
}.play;
)

(
{
	var rate = 4, carrier, modRatio;
	carrier = LFNoise0.kr(rate)*500+700;
	modRatio = MouseX.kr(1,2.0);
	PMOsc.ar(carrier, carrier*modRatio, 12)*0.3
}.play;
)

//1. make it stereo
//2. Add a Line.kr to move the index (now 12) from 1 to 12
//3. Identify the arguments for each receiver.message pair
//4. Control the rate, using another Line with a range of 1 to 20
//5. Add keywords to all argument lists
//6. Add a new variable called env and assign it to Linen (an envelope with an attack of 1/rate and a decay of 0 to control the mul of the PMOsc (use keyword assignment)
//7. Figure out what the * 500 + 700 are doing. Just 1 hint: the LFNoise0 is a bipolar UGen, meaning that it generates values between -1 and 1

(
{
	r = Impulse.kr([10,10.5]); //1. make it stereo
	c = TRand.kr(100, 5000, r);
	m = TRand.kr(100, 5000, r);
	PMOsc.ar(c, m, 12)*0.3
}.play;
)

(
{
	var rate = Line.kr(1,20,5), carrier, modRatio, index = Line.kr(1, 12, 2);//4
	carrier = LFNoise0.kr([rate, rate - 2.77])*500+700;//1
	modRatio = MouseX.kr(0.1,20.0);
	PMOsc.ar(carrier, carrier*modRatio, index)*0.3 //2
}.play;
)


//1.9: Synth Definitions
{SinOsc.ar}.play;//generates a temp_number synth
SynthDef("sine", {Out.ar(0, SinOsc.ar)}).play; //names the SynthDef and output explicitly

SynthDef("sine", {Out.ar(1,SinOsc.ar)}).play; //right channel

(
SynthDef(\one_tone_only, {
	var out, freq = 440;
	out = SinOsc.ar(freq);
	Out.ar(0, out);
}).add; //make sure SuperCollider knows about this SynthDef
)

//then use it to create a running Synth
Synth(\one_tone_only);

//Figure 1.7: Synth definition


(
SynthDef(\PMCrotale, {
	|midi=60, tone=3, art=1, amp=0.8, pan=0|
	var env, out, mod, freq;

	freq = midi.midicps;
	env = Env.perc(0, art);
	mod = 5 + (1/IRand(2,6));

	out = PMOsc.ar(freq, mod*freq,
		pmindex: EnvGen.kr(env, timeScale:art, levelScale:tone),
		mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3));

	out = Pan2.ar(out, pan);

	out = out * EnvGen.kr(env, timeScale: 1.3*art,
		levelScale: Rand(0.1, 0.5), doneAction:2);
	Out.ar(0, out);
}).add;
)

Synth(\PMCrotale, [\midi, rrand(48, 72).round(1), \tone, rrand(1, 6)])

//1.10 Buses, Buffers, and Nodes

//buses: for routing audio or control signals
// -128 audio buses
// -4096 control buses

//SoundIn: for live input

//~: environment variables
// -work anywhere in patch
// -work in other patches
// -work in other windows
s.reboot;

~houston = Buffer.read(s, "/Users/robinson.will.sam/Desktop/SAMPLES ROOT/Praat Samples/praat+vocoder.wav");
~chooston = Buffer.read(s, "/Volumes/Samsung 870 QVO/SAMPLES/musicradar-balearic-bliss-samples/Kit 03 125bpm/Arp loops/BBk3Arp125A-02.wav");

{PlayBuf.ar(1, ~houston)}.play;
{PlayBuf.ar(1, ~chooston)}.play;

/*
Once we've loaded a buffer we can retrieve information such as how many frames
ti has, and therefore how long ti si (see figure 1.8). PlayBuf can be looped using its
loopargument 1( = loop, 0= don't loop), but here atrigger is used to reset the play-
back, looping only a section of the file (see also Trains). The trigger for the right
channel isslightly later than the left one (by 0.01), allowing the loops to slowly shift
and "come out" of phase. The position of the loop is also gradually increased with
the Line. kr. The envelope is used to chop off the first and last hundredths of a sec- ond for a cleaner transition.
*/

//Figure 1.8: Playback buffers

[~houston.bufnum, ~houston.numChannels, ~houston.path, ~houston.numFrames];
[~chooston.bufnum, ~chooston.numChannels, ~chooston.path, ~chooston.numFrames];

( //phasing
{
	var rate, trigger, frames;
	frames = ~houston.numFrames;

	rate = [1, 1.01];
	trigger = Impulse.kr(rate);
	PlayBuf.ar(1, ~houston, 1, trigger, frames * Line.kr(0, 1, 60)) *
	EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;

}.play;
)


( //phasing
{
	var rate, trigger, frames;
	frames = ~chooston.numFrames;

	rate = [1, 1.01];
	trigger = Impulse.kr(rate);
	PlayBuf.ar(1, ~chooston, 1, trigger, frames * Line.kr(0, 1, 60)) *
	EnvGen.kr(Env.linen(0.01, 0.96, 0.01), trigger) * rate;

}.play;
)



//speed and direction change

(
{
	var speed, direction;
	speed = LFNoise0.kr(12)*0.2+1;
	direction = LFClipNoise.kr(1/3);
	PlayBuf.ar(1, ~houston, (speed*direction), loop:1);
}.play;
)

(
{
	var speed, direction;
	speed = LFNoise0.kr(12)*0.2+1;
	direction = LFClipNoise.kr(1/3);
	PlayBuf.ar(1, ~chooston, (speed*direction), loop:1);
}.play;
)


//Out.kr and In.kr for control buses
/*So to connect an output to an input, you would use the
same bus number: Out. kr(1950, 2 SomeControl.kr), then SinOsc.ar (In. kr (1950, 2)).*/


//Figure 1.9: Connecting controls with a bus
(
// if these haven't been used, they will hold 0
~kbus1 = Bus.control; //a control bus
~kbus2 = Bus.control; //a control bus

{
	var speed, direction;
	speed = In.kr(~kbus1, 1) * 0.2 + 1;
	direction = In.kr(~kbus2);
	PlayBuf.ar(1, ~chooston, (speed * direction), loop: 1);
}.play;
)

(
{Out.kr(~kbus1, LFNoise0.kr(12))}.play;
{Out.kr(~kbus2, LFClipNoise.kr(1/4))}.play;
)

(
{
	var speed, direction;
	speed = In.kr(~kbus1, 1) * 0.2 +1;
	direction = In.kr(~kbus2);
	Out.ar(1, PlayBuf.ar(1, ~houston, (speed*direction), loop:1));

}.play;
)

~kbus3 = Bus.control; //a control bus
~kbus4 = Bus.control; //a control bus


{Out.kr(~kbus3, SinOsc.kr(3).scope("out3") * 100)}.play;

