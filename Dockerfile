# 使用官方 vLLM OpenAI-compatible 鏡像（Ampere/Ada/Hopper GPU 專用）
FROM vllm/vllm-openai:v0.11.0

# 安裝 libgl (OpenCV 需要) + Noto 字型 (支援中文)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fonts-noto-core \
        fonts-noto-cjk \
        fontconfig \
        libgl1 && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安裝 mineru[core]（使用 --no-cache-dir 避免 pip cache 佔空間）
RUN python3 -m pip install --no-cache-dir -U 'mineru[core]>=2.7.0' --break-system-packages && \
    python3 -m pip cache purge

# 移除模型下載步驟！改成運行時處理
# 現在 image 不再包含 30-50GB 模型，建置超快、空間夠用

# 入口點：設定 MINERU_MODEL_SOURCE=local（預設本地），並執行傳入命令
# 運行時會檢查模型是否存在，不存在才自動下載
ENTRYPOINT ["/bin/bash", "-c", "export MINERU_MODEL_SOURCE=local && exec \"$@\"", "--"]