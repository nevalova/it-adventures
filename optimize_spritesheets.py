import os
import glob
from PIL import Image

CHAR_DIR = r"C:\Users\terra\.gemini\antigravity\scratch\it_adventures\assets\characters"

def optimize_sheet(path):
    orig_size = os.path.getsize(path)
    im = Image.open(path)
    if im.mode != "RGBA":
        im = im.convert("RGBA")
    
    # Quantize using FASTOCTREE (method=2) with 256 colors
    quantized = im.quantize(colors=256, method=2)
    temp_path = path + ".tmp.png"
    quantized.save(temp_path, format="PNG", optimize=True)
    
    new_size = os.path.getsize(temp_path)
    if new_size < orig_size:
        os.replace(temp_path, path)
        print(f"Optimized {os.path.basename(path)}: {orig_size:,} -> {new_size:,} bytes (-{((orig_size - new_size) / orig_size) * 100:.1f}%)")
    else:
        os.remove(temp_path)
        print(f"Skipped {os.path.basename(path)} (already optimal)")

def main():
    sheets = glob.glob(os.path.join(CHAR_DIR, "*spritesheet*.png"))
    for s in sheets:
        optimize_sheet(s)

if __name__ == "__main__":
    main()
