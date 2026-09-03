(function() {
  document.addEventListener("DOMContentLoaded", (event) => {
    document.body.addEventListener("click", (event) => {
      let audio = document.getElementById("audio");

      if (audio.paused) {
        audio.play();
      } else {
        audio.pause();
      }
    });
  });
})();
