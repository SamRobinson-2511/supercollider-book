Puppet {
	var <>myfreq;
	*new {
		|myfreq=50|
		^super.new.myfreq_(myfreq)
	}
	blip{ { Blip.ar(myfreq, 11) * XLine.kr(1, 0.01, 0.6, doneAction: Done.freeSelf )}.play;
	}
}

m = Puppet.new(50);
m.myfreq;
m.blip;
m.myfreq_(100);
m.blip;

m = ();
m.myfreq_(50);
m.myfreq;
m.blip_({|ev| {Blip.ar(ev.myfreq, 11) * XLine.kr(1, 0.01, 0.6, doneAction: Done.freeSelf)}.play; });
m.blip;

(
m.numHarms_(20);
m.decay_(0.3);
m.blip_({
	|ev|
	{
		Blip.ar(ev.myfreq, ev.numHarms) * XLine.kr(1, 0.01, ev.decay, doneAction: Done.freeSelf)
	}.play;
});
)
m.blip;