s.boot;


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
		TRand.kr( //frequency of VCO
			100, 1000,
			Impulse.kr(Line.kr(1,20,60))), //trigger
		TRand.kr( //# harmonics of VCF
			1,10, //range
			Impulse.kr(Line.kr(1,20,60))),
		Linen.kr(
			Impulse.kr(Line.kr(1,20,60)),
			0,
			0.5,
			1/Line.kr(1,20,60))
	)
}.play;
)

































