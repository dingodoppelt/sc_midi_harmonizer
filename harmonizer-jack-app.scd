(
CmdPeriod.run;
// "SC_JACK_DEFAULT_INPUTS".unsetenv;
"SC_JACK_DEFAULT_OUTPUTS".unsetenv;
s.options.numInputBusChannels = 1;
s.options.memSize = 65536;
s.options.memoryLocking = true;
a = Bus.audio(s, 1);
b = Bus.control(s, 1);
c = Bus.control(s, 1);
~noten = Array.newClear(128);
~pressed = Array.fill(128, false);
~sustained = Array.fill(128, false);
~pedal = false;
~glideTime = 0.0;

SynthDef.new("pitchTracker", { |pitchBus, audioBus|
	Out.kr(pitchBus, Pitch.kr(In.ar(audioBus))[0]);
}).add;

SynthDef.new("volumeBus", { |volumeBus, volume = 1|
	Out.kr(volumeBus, volume);
}).add;

SynthDef.new("inBus", { |bus = 0, buffer, freeze = 0, pitchBus|
	var input, output;
	input = SoundIn.ar(0);

	RecordBuf.ar(input, buffer, loop: 1, run: 1 - freeze);

	// output = Select.ar(freeze, [input, PlayBuf.ar(1, buffer, loop: 1)]);
	output = Select.ar(freeze, [input, BufRd.ar(1, buffer, Phasor.ar(end: 48000 / In.kr(pitchBus, 1) * 5))]);

	Out.ar(bus, output);
}).add;

SynthDef.new("Stimme", { |midiNote, volumeBus, audioBus, pitchBus, glideTime, attackTime |
	var in, out, freq, env;
	in = In.ar(audioBus);
	freq = In.kr(pitchBus, 1);
	env = EnvGate.new(0, nil, attackTime, Done.freeSelf);
	out = PitchShiftPA.ar(in, freq, (XLine.ar(freq, midiNote.midicps, glideTime) / freq).clip(0.01, 10), 1, 75, 1, 2, 1) * env * In.kr(volumeBus);
	Out.ar(0, out);
	Out.ar(1, AllpassC.ar(out, 0.04, 0.03, 0.002));
}).add;

MIDIdef.noteOn("SelectedNoteOn", { |vel, noteNum|
	if (~noten[noteNum].notNil) { ~noten[noteNum].set(\gate, 0) };
	~noten[noteNum] = Synth.after(y, "Stimme", ["midiNote", noteNum, "volumeBus", c, "audioBus", a, "pitchBus", b, "glideTime", ~glideTime, "attackTime", vel.linlin(0, 127, 0.6, 0.01)]);
	~pressed[noteNum] = true;
});

MIDIdef.noteOff("SelectedNoteOff", { |vel, noteNum|
	if (~pedal) {
		~sustained[noteNum] = true;
	} {
		~noten[noteNum].set(\gate, 0);
		~sustained[noteNum] = false;
		~noten[noteNum] = nil;
	};
	~pressed[noteNum] = false;
});

MIDIdef.cc(\midiTrigger, { |val|
	x.set(\freeze, val.clip(0,1));
}, 0);

MIDIdef.cc(\volumeControl, { |val, num|
	z.set(\volume, val.linlin(0, 127, 0, 1));
}, 73);

MIDIdef.cc(\glideControl, { |val, num|
	~glideTime = val.linlin(0, 127, 0, 1);
}, 75);

MIDIdef.cc(\pedalControl, { |val, num|
	if (val > 64) {
		~pedal = true;
	} {
		~pedal = false;
		~noten.do({
			arg item, i;
			if (~pressed[i] == false) {
				~noten[i].set(\gate, 0);
				~sustained[i] = false;
				~noten[i] = nil;
			}
		});
	};
}, 64);

s.waitForBoot({
	~freezeBuffer = Buffer.alloc(s, 48000 * 0.4);
	s.sync;
	MIDIClient.init(1,0);

	x = Synth.new(\inBus, ["bus", a, "buffer", ~freezeBuffer, "pitchBus", b]);
	y = Synth.after(x, \pitchTracker, ["pitchBus", b, "audioBus", a]);
	z = Synth.new(\volumeBus, ["volumeBus", c]);
});
)