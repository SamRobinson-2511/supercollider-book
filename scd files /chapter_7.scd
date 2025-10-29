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














