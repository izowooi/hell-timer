from PIL import Image
import os
from pathlib import Path

def resize_screenshot(
    input_path: str,
    output_path: str = None,
    target_size: tuple[int, int] = (1284, 2778),
    quality: int = 95
) -> str:
    """
    스크린샷을 App Store 제출 규격으로 리사이즈
    
    Args:
        input_path: 원본 이미지 경로
        output_path: 출력 경로 (None이면 자동 생성)
        target_size: 목표 크기 (width, height)
        quality: JPEG 품질 (PNG는 무시됨)
    
    Returns:
        출력 파일 경로
    """
    
    # 이미지 로드
    img = Image.open(input_path)
    original_size = img.size
    
    print(f"원본 크기: {original_size[0]} × {original_size[1]} px")
    print(f"목표 크기: {target_size[0]} × {target_size[1]} px")
    
    # 리사이즈 (고품질)
    img_resized = img.resize(target_size, Image.Resampling.LANCZOS)
    
    # 출력 경로 자동 생성
    if output_path is None:
        path = Path(input_path)
        output_path = path.parent / f"{path.stem}_resized{path.suffix}"
    
    # 저장
    if img_resized.mode == 'RGBA':
        img_resized.save(output_path, 'PNG')
        print(f"✓ PNG로 저장: {output_path}")
    else:
        img_resized.save(output_path, 'JPEG', quality=quality)
        print(f"✓ JPEG로 저장 (품질: {quality}): {output_path}")
    
    return str(output_path)


def batch_resize_screenshots(
    input_folder: str,
    output_folder: str = None,
    target_size: tuple[int, int] = (1284, 2778)
):
    """
    폴더 내 모든 스크린샷 일괄 리사이즈
    
    Args:
        input_folder: 원본 이미지 폴더
        output_folder: 출력 폴더 (None이면 입력 폴더에 저장)
        target_size: 목표 크기
    """
    
    input_path = Path(input_folder)
    
    # 출력 폴더 설정
    if output_folder is None:
        output_path = input_path / "resized"
    else:
        output_path = Path(output_folder)
    
    # 출력 폴더 생성
    output_path.mkdir(exist_ok=True)
    
    # 이미지 파일 필터링
    image_extensions = {'.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG'}
    image_files = [
        f for f in input_path.iterdir() 
        if f.suffix in image_extensions
    ]
    
    print(f"\n총 {len(image_files)}개 이미지 처리 시작...\n")
    
    # 일괄 처리
    for i, image_file in enumerate(image_files, 1):
        print(f"[{i}/{len(image_files)}] {image_file.name}")
        
        try:
            output_file = output_path / image_file.name
            resize_screenshot(
                str(image_file),
                str(output_file),
                target_size
            )
            print()
            
        except Exception as e:
            print(f"✗ 에러: {e}\n")
    
    print(f"완료! 저장 위치: {output_path}")


if __name__ == "__main__":
    # === 단일 파일 처리 ===
    resize_screenshot(
        input_path="screenshot1.png",
        target_size=(1284, 2778)
    )
    
    # === 폴더 일괄 처리 (추천) ===
    # batch_resize_screenshots(
    #     input_folder="./screenshots",
    #     target_size=(1284, 2778)
    # )