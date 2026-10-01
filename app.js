// JavaScript Application for iPod Classic Web App

const demoSongs = [
  { title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" },
  { title: "Hotel California", artist: "Eagles", album: "Hotel California", url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3" },
  { title: "Billie Jean", artist: "Michael Jackson", album: "Thriller", url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3" },
  { title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3" }
];

let state = {
  currentMenu: "main", // main, songs, artists, albums, nowPlaying
  selectedIndex: 0,
  currentSongIndex: 0,
  isPlaying: false
};

const menuData = {
  main: { title: "iPod", items: ["Música", "Artistas", "Álbumes", "Canciones", "Reproduciendo"] },
  songs: { title: "Canciones", items: demoSongs.map(s => s.title) },
  artists: { title: "Artistas", items: [...new Set(demoSongs.map(s => s.artist))] },
  albums: { title: "Álbumes", items: [...new Set(demoSongs.map(s => s.album))] }
};

const menuListEl = document.getElementById("menuList");
const headerTitleEl = document.getElementById("headerTitle");
const menuBodyEl = document.getElementById("menuBody");
const nowPlayingBodyEl = document.getElementById("nowPlayingBody");
const audioPlayer = document.getElementById("audioPlayer");
const clickSound = document.getElementById("clickSound");

// Audio Click tick synthesizer using Web Audio API for fast response
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
function playClickTick() {
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  const osc = audioCtx.createOscillator();
  const gain = audioCtx.createGain();
  osc.type = 'triangle';
  osc.frequency.setValueAtTime(1200, audioCtx.currentTime);
  osc.frequency.exponentialRampToValueAtTime(100, audioCtx.currentTime + 0.015);
  gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
  gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.015);
  osc.connect(gain);
  gain.connect(audioCtx.destination);
  osc.start();
  osc.stop(audioCtx.currentTime + 0.015);
}

function renderMenu() {
  const currentData = menuData[state.currentMenu];
  if (!currentData) return;

  headerTitleEl.innerText = currentData.title;
  menuListEl.innerHTML = "";

  currentData.items.forEach((itemText, idx) => {
    const li = document.createElement("li");
    li.className = `menu-item ${idx === state.selectedIndex ? "selected" : ""}`;
    li.innerHTML = `<span>${itemText}</span><span class="chevron">›</span>`;
    menuListEl.appendChild(li);
  });
}

function moveSelection(direction) {
  const itemsCount = menuData[state.currentMenu]?.items.length || 0;
  if (itemsCount === 0) return;

  playClickTick();

  if (direction === "down") {
    state.selectedIndex = (state.selectedIndex + 1) % itemsCount;
  } else if (direction === "up") {
    state.selectedIndex = (state.selectedIndex - 1 + itemsCount) % itemsCount;
  }
  renderMenu();
}

function handleSelect() {
  playClickTick();

  if (state.currentMenu === "main") {
    if (state.selectedIndex === 0 || state.selectedIndex === 3) { // Música or Canciones
      state.currentMenu = "songs";
      state.selectedIndex = 0;
      renderMenu();
    } else if (state.selectedIndex === 1) { // Artistas
      state.currentMenu = "artists";
      state.selectedIndex = 0;
      renderMenu();
    } else if (state.selectedIndex === 2) { // Álbumes
      state.currentMenu = "albums";
      state.selectedIndex = 0;
      renderMenu();
    } else if (state.selectedIndex === 4) { // Reproduciendo
      showNowPlaying();
    }
  } else if (state.currentMenu === "songs") {
    playSong(state.selectedIndex);
  }
}

function handleMenuBack() {
  playClickTick();
  if (nowPlayingBodyEl.classList.contains("hidden") === false) {
    nowPlayingBodyEl.classList.add("hidden");
    menuBodyEl.classList.remove("hidden");
    return;
  }

  if (state.currentMenu !== "main") {
    state.currentMenu = "main";
    state.selectedIndex = 0;
    renderMenu();
  }
}

function playSong(index) {
  state.currentSongIndex = index;
  const song = demoSongs[index];
  
  audioPlayer.src = song.url;
  audioPlayer.play();
  state.isPlaying = true;
  document.getElementById("playStateIcon").innerText = "▶";

  document.getElementById("songTitle").innerText = song.title;
  document.getElementById("songArtist").innerText = song.artist;
  document.getElementById("songAlbum").innerText = song.album;

  showNowPlaying();
}

function showNowPlaying() {
  menuBodyEl.classList.add("hidden");
  nowPlayingBodyEl.classList.remove("hidden");
  headerTitleEl.innerText = "Reproduciendo";
}

function togglePlayPause() {
  playClickTick();
  if (!audioPlayer.src && demoSongs.length > 0) {
    playSong(0);
    return;
  }

  if (audioPlayer.paused) {
    audioPlayer.play();
    state.isPlaying = true;
    document.getElementById("playStateIcon").innerText = "▶";
  } else {
    audioPlayer.pause();
    state.isPlaying = false;
    document.getElementById("playStateIcon").innerText = "❚❚";
  }
}

audioPlayer.addEventListener("timeupdate", () => {
  if (audioPlayer.duration) {
    const progress = (audioPlayer.currentTime / audioPlayer.duration) * 100;
    document.getElementById("progressFill").style.width = `${progress}%`;

    const curMin = Math.floor(audioPlayer.currentTime / 60);
    const curSec = Math.floor(audioPlayer.currentTime % 60).toString().padStart(2, "0");
    document.getElementById("currentTime").innerText = `${curMin}:${curSec}`;

    const remTime = audioPlayer.duration - audioPlayer.currentTime;
    const remMin = Math.floor(remTime / 60);
    const remSec = Math.floor(remTime % 60).toString().padStart(2, "0");
    document.getElementById("remainingTime").innerText = `-${remMin}:${remSec}`;
  }
});

// Click Wheel Rotational Gesture Tracking
const wheel = document.getElementById("clickWheel");
let lastAngle = 0;
let isDragging = false;

function getAngle(x, y) {
  const rect = wheel.getBoundingClientRect();
  const centerX = rect.left + rect.width / 2;
  const centerY = rect.top + rect.height / 2;
  return Math.atan2(y - centerY, x - centerX);
}

wheel.addEventListener("pointerdown", (e) => {
  if (e.target.id === "btnSelect") return; // Ignore center button click for rotation
  isDragging = true;
  lastAngle = getAngle(e.clientX, e.clientY);
});

window.addEventListener("pointermove", (e) => {
  if (!isDragging) return;
  const currentAngle = getAngle(e.clientX, e.clientY);
  let delta = currentAngle - lastAngle;

  if (delta > Math.PI) delta -= Math.PI * 2;
  if (delta < -Math.PI) delta += Math.PI * 2;

  const threshold = 0.25; // Sensibilidad de la rueda
  if (Math.abs(delta) >= threshold) {
    if (delta > 0) {
      moveSelection("down");
    } else {
      moveSelection("up");
    }
    lastAngle = currentAngle;
  }
});

window.addEventListener("pointerup", () => { isDragging = false; });

// Wheel Button Listeners
document.getElementById("btnSelect").addEventListener("click", handleSelect);
document.getElementById("btnMenu").addEventListener("click", handleMenuBack);
document.getElementById("btnPlay").addEventListener("click", togglePlayPause);
document.getElementById("btnNext").addEventListener("click", () => {
  playClickTick();
  playSong((state.currentSongIndex + 1) % demoSongs.length);
});
document.getElementById("btnPrev").addEventListener("click", () => {
  playClickTick();
  playSong((state.currentSongIndex - 1 + demoSongs.length) % demoSongs.length);
});

// Initial Setup
renderMenu();
