import argparse
import sys
from pathlib import Path

from PIL import Image


TARGET_SIZE = (1284, 2778)
OUTPUT_DIR = "out"


def resize_image(input_path: Path, output_path: Path) -> None:
    """이미지를 목표 크기로 리사이즈하여 저장"""
    img = Image.open(input_path)
    original_size = img.size

    print(f"  {original_size[0]}x{original_size[1]} -> {TARGET_SIZE[0]}x{TARGET_SIZE[1]}")

    img_resized = img.resize(TARGET_SIZE, Image.Resampling.LANCZOS)

    if img_resized.mode == "RGBA":
        img_resized.save(output_path, "PNG")
    else:
        img_resized.save(output_path, "JPEG", quality=95)


def main():
    parser = argparse.ArgumentParser(description="이미지 리사이즈 도구")
    parser.add_argument("input_folder", help="입력 폴더 경로")
    args = parser.parse_args()

    input_path = Path(args.input_folder)
    output_path = Path(OUTPUT_DIR)

    if not input_path.exists():
        print(f"오류: 입력 폴더가 존재하지 않습니다: {input_path}")
        sys.exit(1)

    if not input_path.is_dir():
        print(f"오류: 입력 경로가 폴더가 아닙니다: {input_path}")
        sys.exit(1)

    output_path.mkdir(exist_ok=True)

    image_extensions = {".png", ".jpg", ".jpeg", ".PNG", ".JPG", ".JPEG"}
    image_files = [f for f in input_path.iterdir() if f.suffix in image_extensions]

    if not image_files:
        print(f"입력 폴더에 이미지가 없습니다: {input_path}")
        sys.exit(0)

    print(f"총 {len(image_files)}개 이미지 처리")
    print(f"출력 폴더: {output_path.absolute()}\n")

    for i, image_file in enumerate(image_files, 1):
        print(f"[{i}/{len(image_files)}] {image_file.name}")
        try:
            output_file = output_path / image_file.name
            resize_image(image_file, output_file)
        except Exception as e:
            print(f"  오류: {e}")

    print(f"\n완료!")


if __name__ == "__main__":
    main()
