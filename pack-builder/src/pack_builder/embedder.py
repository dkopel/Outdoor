"""Generate sentence embeddings for chunks.

Uses sentence-transformers/all-MiniLM-L6-v2 (384-dim, ~80 MB).
The model is downloaded once into the HuggingFace cache on first use.
"""

from __future__ import annotations

from functools import lru_cache

import numpy as np

DEFAULT_MODEL = "sentence-transformers/all-MiniLM-L6-v2"
EMBEDDING_DIM = 384


@lru_cache(maxsize=1)
def _load_model(name: str):
    from sentence_transformers import SentenceTransformer

    return SentenceTransformer(name)


def embed_texts(texts: list[str], model_name: str = DEFAULT_MODEL) -> np.ndarray:
    """Embed a list of strings and return a (n, dim) float32 numpy array, L2-normalized."""
    if not texts:
        return np.zeros((0, EMBEDDING_DIM), dtype=np.float32)
    model = _load_model(model_name)
    vecs = model.encode(
        texts,
        batch_size=32,
        show_progress_bar=False,
        convert_to_numpy=True,
        normalize_embeddings=True,
    )
    return vecs.astype(np.float32, copy=False)


def embed_one(text: str, model_name: str = DEFAULT_MODEL) -> np.ndarray:
    return embed_texts([text], model_name)[0]
