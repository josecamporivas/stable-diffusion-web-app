from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from diffusers import StableDiffusionPipeline
import base64
from io import BytesIO

app = FastAPI()

# Modelo desde Hugging Face (no necesita descarga manual)
pipe = StableDiffusionPipeline.from_pretrained(
    "stabilityai/stable-diffusion-2-1",
    torch_dtype=torch.float16
).to("cuda" if torch.cuda.is_available() else "cpu")

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
def generate_image(req: PromptRequest):
    try:
        image = pipe(req.prompt).images[0]

        buffer = BytesIO()
        image.save(buffer, format="PNG")
        base64_img = base64.b64encode(buffer.getvalue()).decode("utf-8")

        return {"image_base64": base64_img}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
