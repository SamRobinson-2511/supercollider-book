15.squared;
squared(15)

performList

Array.series(5, 10,5);

Array.rand(*[5,-10, 10])

Array.rand(*Array.rand(3, 3, 10))

[1, 5, 12][1];
[1,5,12].at(2);
()[\a] = pi;
().put(\a, pi);

s.boot;
(
{
	Resonz.ar(GrayNoise.ar(
		XLine.kr(100, 1000, 10, doneAction: Done.freeSelf),
		XLine.kr(0.5, 0.01, [4,7], doneAction: 0)
	))
}.play;
)

(
{ WhiteNoise.ar(EnvGen.kr(Env.perc, timeScale: 3, doneAction:2))}.play;
)

(
{ WhiteNoise.ar(EnvGen.kr(Env.perc, timeScale: 0.3, doneAction: 2))}.play;
)

[\a, \b] ++ [1,2,3] //join two sequencable collections

//Figure 5.5: Statements

(
a = 5;
5 do: { a = a+10; a.postln };
Post << "The value of variable 'a' is now " << a << "\n"
)

(
var window;
window.postln;
)


(
//A window with a button that posts: "Hello there"
var window, button;
window = Window("OLA", Rect(200, 200, 120, 120));
button = Button(window, Rect(10, 10, 100, 100));
button.states = [["ALLO"]];
button.action = { "hello there".postln};
window.front;
)

(
var bounds = Rect(10, 20, 30, 50), x = 100, y = 200;
bounds.width.postln;
bounds.moveTo(x, y);
)

(
var point = Point(0, pi);
point.x.postln; point.y.postln; point.y == pi;
)


//Figure 5.9: Variables can point ot different objects during a process
(
Server.default.waitForBoot({
	SynthDef(\ping, {
		|freq=440|
		Out.ar(0,
			SinOsc.ar([freq, freq* (4/3)], 0, EnvGen.kr(Env.perc(0.05, 0.3, 0.1, -4), doneAction: 2)
			)
		)
	}).add;
});
)

(
var countdown = 100;
var note = 50;
var increment_func, decrement_func;
var action;
increment_func = {
	note = note + [2, 5, 7, 12].choose;
	if (note > 100){action = decrement_func}
};
decrement_func = {
	note = note - [1, 2, 5, 7, 12].choose;
	if (note > 50) { action = increment_func};
};
action = increment_func;
{
	countdown do: {
		Synth(\ping, [\freq, note.midicps]);
		action.value;
		0.1.wait;
	}
}.fork
)


//Figure 5.11: currentEnvironment

currentEnvironment;
~alpha = pi;
currentEnvironment;
~freq = 800;
Server.local.boot;
{ LFNoise0.ar(~freq, 0.1)}.play;
~alpha = nil;
currentEnvironment;
~freq = nil;
currentEnvironment;


(
n = {|freq=400| LFDNoise1.ar(freq, 0.1)}.play;
)

n.set(\freq, 1000);
n.free;


this.dump;

[this, this.class, thisMethod].postln;

topEnvironment;
currentEnvironment;
uniqueMethods;


//Figure 5.12: topEnvironment
(
~a = "TOP";
(a: "INNER") use: {
	currentEnvironment.postln;
	topEnvironment.postln;
	~a.postln;
};

)


(
#p, q = [100, 400].collect {
	|i|
	Window(i.asString, Rect(i, i, 200, 200)).front;
}
)
(
p.addUniqueMethod(\greet, {
	|w|
	w.name = "Hello"
})
)
p.greet;
q.greet;


//Functions
{1+1}.value;
x = {1+1}
x.()







//Figure 5.15:

(
var synth;
var freq = 220;
var change_freq;
var window;
var button1, button2, button3;

synth = { |freq=220| LFTri.ar([freq, freq*2.01], 0, 0.1)}.play;
change_freq = {
	freq = freq * [0.9, 0.9.reciprocal].choose;
	synth.set(\freq, freq);
};

window = Window("Buttons Archaic", Rect(400, 400, 340, 120));

button1 = Button(window, Rect(10, 10, 100, 100));
button1.states = [["I"]];
button1.action = change_freq;


button2 = Button(window, Rect(10, 10, 100, 100));
button2.states = [["III"]];
button2.action = {
	{ 3 do: {
		change_freq.value: 0.4.wait
	}}.fork;
};

button3 = Button(window, Rect(10, 10, 100, 100));
button3.states = [["VIII"]];
button3.action = {
	{ 8 do: {
		change_freq.value: 0.1.wait
	}
}}.fork;
)


(
var sum2;
sum2 = {
	|a, b|
	a + b;
};
sum2.value(2, 3);
)



//Function


(
{
	|a, b, c|
	var d;
	d = a * b;
	c + d;
}
)

(
var sum2;
sum2 = {
	|a, b|
	a + b;
};
sum2.(2, 3);
)


//Figure 5.18: Simple function with arguments
(
var sq_mean;
sq_mean = {
	|a, b|
	(a + b / 2).squared;
};
sq_mean.value(3, 1);
)

(
var sq_mean_all;
sq_mean_all = {
	|...numbers|
	(numbers.sum / numbers.size).squared;
};
sq_mean_all.(1, 3, 5, -7);
)


(
var w_func;
w_func = {arg message="warning", bounds = Rect(200, 500, 500, 100);
	var window;
	window = Window("message window", bounds).front;
	TextView(window, window.view.bounds.insetBy(10, 10))
	.string = message;

};
w_func.(String.new.addAll(Array.new.addAll( "Major News").pyramid(7)))
)




//Figure 5.21: Performing messages chosen by index
(
var window, button;
window = Window("Server Button", Rect(400, 400, 200, 200));
button = Button(window, Rect(5, 5, 190, 190));
button.states = [["boot"], ["quit"]];
button.action = {|me| Server.default perform: [\quit, \boot][me.value]};
window.front;
)

//Figure 5.22: Evaluating functions chosen by index
(
var window, button;
window = Window("Server Button", Rect(400, 400, 200, 200));
button = Button(window, Rect(5, 5, 190, 190));
button.states = [["boot"], ["quit"]];
button.action = {
	|me|
	[{"QUITTING THE DEFAULT SERVER".postln;
		Server.default.quit;
	},{"BOOTING THE DEFAULT SERVER".postln;
		Server.default.boot;
	}][me.value].value;
};
window.front;
)

//Figure 5.23: Asynchronous communication with the server
Server.default.boot;

(
var buffer;
buffer = Buffer.read(path: "sounds/allwlk01.wav",
	action: {
		|buffer|
		format("loaded % at: %", Main.elapsedTime).postln;
	});
format("Reached this after 'Buffer.read' at: %", Main.elapsedTime).postln;
buffer;
)
)


//Figure 5.24: Illustrates 'loop' nad hte use of Event - (key.value).play;

(
var window, routine;
window = Window("close me to stop").front;
window.onClose = { routine.stop };
routine = {
	loop {
		(degree: -10 + 30.xrand, dur: 0.05, amp: 0.1.rand).play;
		0.05.rand.wait;
	}
}.fork;
)

(
var sum = 0;
while {sum = sum + exprand(0.1, 3); sum < 10}
{sum.postln};
)

//Figure 5.25: Parial application
_.isPrime ! 10
_.squared ! 10
_@_.(30, 40);
Array.rand(12, 0, 1000).clump(4) collect: Rect(*_)
(1..8).collect([\a, \b, _]);
(a: _, b: _\, c: _, d: _, e: _).(*Array.rand(5, 0, 100));




//Figure 5.26: Iterative factorial
(
var iterative_factorial;
iterative_factorial = {
	|n|
	var factorial = 1;
	n do: {
		|i|
		factorial = factorial * (i + 1)
	};
	factorial;
};
iterative_factorial.(7).postln;
)


//Figure 5.27: recursive factorial
(
f = {|x| if (x > 1) { x * thisFunction.value(x-1)}{}{x}};
f.value(10);
)









































































































