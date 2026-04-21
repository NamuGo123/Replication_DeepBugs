import urllib.request
import os

input_file = "../dataset/data/js/additional_files.txt"
output_dir = "../dataset/data/js/programs_additional"

os.makedirs(output_dir, exist_ok=True)

print("Reading js file URLs")
print("=" * 60)

with open(input_file) as f:
    lines = f.readlines()

for line in lines:
    line = line.strip()
    if not line or line.startswith("id") or line.startswith("#"):
        continue

    parts = line.split(",")

    url = parts[1].strip()
    project = parts[2].strip()

    if not url.endswith(".js"):
        print(f" Skipping non-JS file: {url}")
        continue

    filename = url.split("/")[-1]
    save_name = f"{project}_{filename}"
    save_path = os.path.join(output_dir, save_name)

    try:
        urllib.request.urlretrieve(url, save_path)
        with open(save_path) as f:
            loc = sum(1 for _ in f)
        print(f"Succeslufly saved {project:15} | {save_name:40} | {loc} LOC")
    except Exception as e:
        print(f"Failed to save {project:15} | {filename:40} | Error: {e}")

print("=" * 60)
print(f"Files saved to: {output_dir}")
print("Done!")