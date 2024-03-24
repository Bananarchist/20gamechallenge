(function setup() {
	const mountElm = () => {
		const node = document.getElementById("app");
		const flags = {};
		const app = Elm.Main.init({ node, flags });
		manageAudio(app);
	};

	loadAppBtn = document.getElementById("loadappbtn");
	loadAppBtn.style.display = "block";
	loadAppBtn.addEventListener("click", function (e) {
		mountElm();
	});
	loadAppBtn.focus();
})();
