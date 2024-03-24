const noteMap = new Map();
noteMap.set("A", 27.5);
noteMap.set("A#", 29.14);
noteMap.set("Bb", 29.14);
noteMap.set("B", 30.87);
noteMap.set("C", 16.35);
noteMap.set("C#", 17.32);
noteMap.set("Db", 17.32);
noteMap.set("D", 18.35);
noteMap.set("D#", 19.45);
noteMap.set("Eb", 19.45);
noteMap.set("E", 20.6);
noteMap.set("F", 21.83);
noteMap.set("F#", 23.12);
noteMap.set("Gb", 23.12);
noteMap.set("G", 24.5);
noteMap.set("G#", 25.96);
noteMap.set("Ab", 25.96);

function frequencyFor(note, octave) {
	  let nVal = noteMap.get(note) || 27.5;
	  let fVal = octave < 0 ? nVal : (nVal * (2 ** octave));
	  return fVal;
}

function manageAudio(app) {
	  var ctx;
	  app.ports.initializeAudioContext.subscribe(() => {
			ctx = new window.AudioContext();
		});
	  app.ports.playGoalScoreSFX.subscribe(() => {
			playGoalScoreSFX(ctx);
		});
	  app.ports.playPaddleBounceSFX.subscribe(() => {
			playPaddleBounceSFX(ctx);
		});
	  app.ports.playWallBounceSFX.subscribe(() => {
			playWallBounceSFX(ctx);
		});
		app.ports.playGameOverSFX.subscribe(() => {
			playGameOverSFX(ctx);
		});
}

function playPaddleBounceSFX(ctx) {
	const oscillator = new OscillatorNode(ctx, {
		type: "square",
		frequency: frequencyFor("G", 4)
	});
	const gain = new GainNode(ctx, { gain: 0.5 });
	oscillator.connect(gain);
	gain.connect(ctx.destination);
	oscillator.start(ctx.currentTime);
	oscillator.stop(ctx.currentTime + 0.1);
}

function playWallBounceSFX(ctx) {
	const oscillator = new OscillatorNode(ctx, {
		type: "square",
		frequency: frequencyFor("G#", 4)
	});
	const gain = new GainNode(ctx, { gain: 0.5 });
	oscillator.connect(gain);
	gain.connect(ctx.destination);
	oscillator.start(ctx.currentTime);
	oscillator.stop(ctx.currentTime + 0.1);
}

function playGoalScoreSFX(ctx) {
	const oscillator = new OscillatorNode(ctx, {
		type: "sine",
		frequency: frequencyFor("C", 5)
	});
	const gain = new GainNode(ctx, { gain: 0.5 });
	oscillator.connect(gain);
	gain.connect(ctx.destination);
	oscillator.start(ctx.currentTime);
	oscillator.stop(ctx.currentTime + 0.2);
}

function playGameOverSFX(ctx) {
	const oscillator1 = new OscillatorNode(ctx, {
		type: "sine",
		frequency: frequencyFor("G", 5)
	});
	const oscillator2 = new OscillatorNode(ctx, {
		type: "sine",
		frequency: frequencyFor("G#", 4)
	});
	const oscillator3 = new OscillatorNode(ctx, {
		type: "sine",
		frequency: frequencyFor("C", 4)
	});
	const gain = new GainNode(ctx, { gain: 0.5 });
	oscillator1.connect(gain);
	oscillator2.connect(gain);
	oscillator3.connect(gain);
	gain.connect(ctx.destination);
	oscillator1.start(ctx.currentTime);
	oscillator1.stop(ctx.currentTime + 0.05);
	oscillator2.start(ctx.currentTime + 0.05);
	oscillator2.stop(ctx.currentTime + 0.30);
	oscillator3.start(ctx.currentTime + 0.10);
	oscillator3.stop(ctx.currentTime + 0.30);
}
