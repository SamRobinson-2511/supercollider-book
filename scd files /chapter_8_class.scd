//Example 8.1: Tests for Puppet Class

m = Puppet.new(40);
m.dump;
m.myfreq;
m.blip;
m.myfreq_(100);
m.blip;


//Example 8.2: A Puppet modelled as an event
m = ();
m.myfreq_(50);
m.myfreq;
m.blip_({|ev| {Blip.ar(ev.myfreq, 11)* XLine.kr(1, 0.01, 0.6, doneAction: 2)}.play;});
m.blip;

//Example 8.3: Add more instance variables, change the blip method
(
m.numHarms_(20);
m.decay_(0.3);

m.blip_({ |ev|
	{Blip.ar(ev.myfreq, ev.numHarms)
	* XLine.kr(1, 0.01, ev.decay, doneAction: 2)}.play;
});
)
m.blip;

//8.5: Example 1: Shout Window
//Figure 8.4: A minimal Shout window sketch
(
z = z ? ();
z.win = Window("Shout", Rect(0, 900, 1200, 100)).front;
z.txtView = TextView(z.win, Rect(0, 0, 1200, 100));
z.txtView.string_("Shout This!");
z.txtView.font_(Font("Monaco", 32));

//tune appearances
z.win.alpha_(0.7);
z.win.view.background_(Color.clear);
z.txtView.background_(Color.clear);
z.win.alwaysOnTop_(true);
z.win.close;
)



























