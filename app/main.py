from fastapi import FastAPI

app = FastAPI(title="NairaTransfer Pro", version="1.0.0")

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "nairatransfer-pro",
        "environment": "prod"
    }
