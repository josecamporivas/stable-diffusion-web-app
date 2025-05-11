from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from diffusers import DiffusionPipeline
import base64
from io import BytesIO
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional

app = FastAPI()

origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Cache de pipelines cargados
loaded_pipelines = {}

class PromptRequest(BaseModel):
    prompt: str
    model_id: Optional[str] = "CompVis/stable-diffusion-v1-4"
    size: Optional[int] = 512

def get_pipeline(model_id: str):
    if model_id not in loaded_pipelines:
        try:
            pipe = DiffusionPipeline.from_pretrained(
                model_id,
                torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
                variant="fp16" if torch.cuda.is_available() else None
            ).to("cuda" if torch.cuda.is_available() else "cpu")
            pipe.enable_attention_slicing()
            loaded_pipelines[model_id] = pipe
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Failed to load model '{model_id}': {e}")
    return loaded_pipelines[model_id]

@app.post("/generate")
def generate_image(req: PromptRequest):
    try:
        pipe = get_pipeline(req.model_id)

        image = pipe(
            prompt=req.prompt,
            height=req.size,
            width=req.size
        ).images[0]

        print(f"Generated image size: {image.size} using model: {req.model_id}")

        buffer = BytesIO()
        image.save(buffer, format="PNG")
        base64_img = base64.b64encode(buffer.getvalue()).decode("utf-8")

        return {"image_base64": base64_img}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
