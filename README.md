# Realtime audio harmonizer with MIDI input for SuperCollider
Pitch shifts the incoming monophonic audio signal to the MIDI notes you input in realtime.  

## Features
- Harmonize your monophonic input with MIDI, i.e. sing into a microphone and play your own voice with your MIDI keyboard in realtime
- Velocity sensitive attack time: The higher the MIDI velocity, the shorter the attack time of the pitch shifted audio
- Variable glide time between the starting note and the individual pitch shifted voices
- Sustain pedal support - cc 64 (MIDI only, a freeze feature is planned but not working atm. PRs welcome ;)
- Volume and glide time of pitch shifted voices is MIDI controllable

## Dependencies
[PitchShiftPA](https://github.com/dyfer/PitchShiftPA) is used for low latency/high fidelity pitch shifting and needs to be installed  
via `SuperCollider IDE -> Language -> Quarks`.  
Please refer to the [official supercollider documentation](https://doc.sccode.org/Guides/UsingQuarks.html) for installation instructions.

## Running
Only tested on Linux with Pipewire (JACK) but should work where supercollider works.
To run this either load `harmonizer-jack-app.scd` into the supercollider IDE or run it from the command line with:  
```
sclang harmonizer-jack-app.scd
```
Connect your monophonic audio signal and MIDI keyboard to supercollider.  
MIDI controllers 73 and 75 are used for volume and glide time control per default.  
You can change these to your liking in the corresponding `MIDIDef.cc` calls.
