const listenBtn = document.getElementById('listen-btn');
const statusText = document.getElementById('status-text');
const resultCard = document.getElementById('result-card');
const trackTitle = document.getElementById('track-title');
const trackArtist = document.getElementById('track-artist');
const canvas = document.getElementById('waveform');
const ctx = canvas.getContext('2d');

let isListening = false;
let animationId;

// Initialize Canvas
canvas.width = canvas.offsetWidth;
canvas.height = canvas.offsetHeight;

function drawWaveform() {
    if (!isListening) return;
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.beginPath();
    ctx.strokeStyle = '#6c63ff';
    ctx.lineWidth = 3;
    
    const time = Date.now() * 0.005;
    for (let x = 0; x < canvas.width; x++) {
        const y = canvas.height / 2 + Math.sin(x * 0.05 + time) * 20;
        if (x === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    }
    ctx.stroke();
    
    animationId = requestAnimationFrame(drawWaveform);
}

listenBtn.addEventListener('click', async () => {
    if (isListening) return;

    isListening = true;
    statusText.innerText = "LISTENING...";
    resultCard.classList.add('hidden');
    drawWaveform();

    // Simulate identification delay
    setTimeout(() => {
        isListening = false;
        cancelAnimationFrame(animationId);
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        statusText.innerText = "IDENTIFYING...";
        
        setTimeout(() => {
            statusText.innerText = "FOUND IT!";
            showResult("Blinding Lights", "The Weeknd");
        }, 1500);
    }, 4000);
});

function showResult(title, artist) {
    trackTitle.innerText = title;
    trackArtist.innerText = artist;
    resultCard.classList.remove('hidden');
}
