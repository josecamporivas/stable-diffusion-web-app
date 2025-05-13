document.addEventListener('DOMContentLoaded', () => {
  // DOM Elements
  const promptInput = document.getElementById("promptInput");
  const generateButton = document.getElementById("generate-button");
  const modelSelect = document.getElementById("modelSelect");
  const sizeSelect = document.getElementById("sizeSelect");
  const loadingContainer = document.querySelector(".loading-container");
  const outputImage = document.getElementById("outputImage");
  const imagePlaceholder = document.querySelector(".image-placeholder");
  const promptChips = document.querySelectorAll(".prompt-chip");
  
  // Initialize UI
  outputImage.style.display = "none";
  
  // Generate image function
  async function generateImage() {
    // Validate prompt
    const prompt = promptInput.value.trim();
    if (!prompt) {
      animatePromptInput();
      return;
    }
    
    // Get selected options
    const model_id = modelSelect.value;
    const size = parseInt(sizeSelect.value);
    
    // Show loading state
    loadingContainer.style.display = "flex";
    imagePlaceholder.style.display = "none";
    outputImage.style.display = "none";
    
    try {
      const response = await fetch("http://localhost:8000/generate", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ prompt, model_id, size })
      });
    
      if (!response.ok) {
        throw new Error(`Server responded with ${response.status}`);
      }
      
      const data = await response.json();
      
      if (data.image_base64) {
        outputImage.src = `data:image/png;base64,${data.image_base64}`;
        outputImage.style.display = "block";
        imagePlaceholder.style.display = "none";
      } else {
        throw new Error("No image data received");
      }
    } catch (error) {
      console.error("Error generating image:", error);
      showNotification("Could not generate image. Please try again.");
      imagePlaceholder.style.display = "flex";
    } finally {
      loadingContainer.style.display = "none";
    }
  }
  
  // Event listeners
  generateButton.addEventListener('click', generateImage);
  
  promptInput.addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
      generateImage();
    }
  });
  
  // Prompt suggestion chips
  promptChips.forEach(chip => {
    chip.addEventListener("click", () => {
      promptInput.value = chip.textContent;
      promptInput.focus();
    });
  });
  
  // Helper functions
  function animatePromptInput() {
    promptInput.classList.add("shake");
    promptInput.focus();
    setTimeout(() => {
      promptInput.classList.remove("shake");
    }, 600);
  }
  
  function showNotification(message) {
    // Create notification element
    const notification = document.createElement("div");
    notification.className = "notification";
    notification.textContent = message;
    
    // Append to body
    document.body.appendChild(notification);
    
    // Show with animation
    setTimeout(() => {
      notification.classList.add("show");
    }, 10);
    
    // Remove after delay
    setTimeout(() => {
      notification.classList.remove("show");
      setTimeout(() => {
        document.body.removeChild(notification);
      }, 300);
    }, 3000);
  }
  
  // Add notification styles dynamically
  const style = document.createElement("style");
  style.textContent = `
    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
      20%, 40%, 60%, 80% { transform: translateX(5px); }
    }
    
    .shake {
      animation: shake 0.6s cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
      border-color: #EF4444 !important;
    }
    
    .notification {
      position: fixed;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%) translateY(100px);
      background-color: #EF4444;
      color: white;
      padding: 12px 24px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      transition: transform 0.3s ease-out;
      z-index: 1000;
    }
    
    .notification.show {
      transform: translateX(-50%) translateY(0);
    }
  `;
  document.head.appendChild(style);
});
