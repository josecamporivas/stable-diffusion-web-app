async function generateImage() {
    console.log("generando")
    const prompt = document.getElementById("promptInput").value;
    const model_id = document.getElementById("modelSelect").value;
    const size = parseInt(document.getElementById("sizeSelect").value);
    document.getElementById("loading").style.display = "block";

    const response = await fetch("http://localhost:8000/generate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ prompt, model_id, size })
    });
  
    const data = await response.json();
    document.getElementById("loading").style.display = "none";
  
    if (data.image_base64) {
      document.getElementById("outputImage").src = `data:image/png;base64,${data.image_base64}`;
    } else {
      alert("Failed to generate image.");
    }
  }
  

document.getElementById('generate-button').addEventListener('click', () => generateImage());
document.getElementById('promptInput').addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
        generateImage();
    }
});

document.querySelectorAll(".prompt-option").forEach(item => {
    item.addEventListener("click", () => {
      document.getElementById("promptInput").value = item.textContent;
      generateImage();
    });
  });