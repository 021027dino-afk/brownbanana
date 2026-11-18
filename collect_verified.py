"""
현대백화점 무역센터점 크리스마스 디스플레이 이미지 수집 + 실시간 교차검증

사용법 (PowerShell):
  python -m pip install requests beautifulsoup4 pillow torch transformers
  python collect_verified.py

동작:
  0) 기존 폴더의 이미지를 CLIP으로 재검수 -> 부적합 이미지는 _rejected 폴더로 이동
  1) 검색결과의 게시글/기사 본문에 (무역센터|삼성역) + 크리스마스가 있는 글만 방문
  2) 그 글의 이미지를 받으면서 CLIP으로 즉시 검증, 통과한 것만 저장
  3) 목표 장수(100장)가 찰 때까지 반복 (= 부적합 이미지를 맞는 이미지로 교체)
"""
import os, re, io, sys, shutil, urllib.parse
import requests
from bs4 import BeautifulSoup
from PIL import Image
import torch
from transformers import CLIPModel, CLIPProcessor

BASE_DIR = r"D:\지은이꺼"
TARGET = 100
CLIP_THRESHOLD = 0.55      # 높이면 더 엄격, 낮추면 더 관대
MIN_SIZE = 400             # 가로/세로 최소 픽셀

FOLDERS = {
    "1_소셜미디어_이미지_100장": dict(mode="social", keywords=[
        "현대백화점 무역센터점 크리스마스 트리",
        "현대백화점 무역센터점 크리스마스 포토존",
        "현대백화점 무역센터점 크리스마스 후기",
        "삼성역 현대백화점 크리스마스 트리",
        "현대백화점 무역센터점 크리스마스 오르골",
        "현대백화점 무역센터점 해리의 꿈의 상점",
        "현대백화점 무역센터점 움직이는 대극장",
    ]),
    "2_공식_이미지_100장": dict(mode="official", keywords=[
        "현대백화점 무역센터점 크리스마스",
        "현대백화점 크리스마스 연출 무역센터점",
        "현대백화점 무역센터점 대형 트리",
        "현대백화점 무역센터점 크리스마스 외관",
        "현대백화점 크리스마스 테마 무역센터점",
    ]),
}

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Referer": "https://www.naver.com/",
}

# ---------------- CLIP 검증기 ----------------
POSITIVE = [
    "a large Christmas tree inside a department store",
    "Christmas decorations and display in a shopping mall",
    "a Christmas window display with lights and ornaments",
    "a Christmas photo zone with festive decorations",
    "a music box or carousel Christmas installation",
    "the facade of a department store decorated for Christmas",
    "an atrium with giant Christmas decorations and lights",
]
NEGATIVE = [
    "a selfie or portrait of a person",
    "food, dessert or a cafe table",
    "a product advertisement or shopping item photo",
    "a logo, icon or text banner",
    "a screenshot of a website or app",
    "a map or a floor plan",
    "a cartoon or illustration",
    "a plain landscape or street without decorations",
    "a hotel room or restaurant interior",
    "a family or group photo",
    "a newspaper or document with lots of text",
]


class Verifier:
    def __init__(self):
        name = "openai/clip-vit-base-patch32"
        print("CLIP 모델 로딩 중... (처음 한 번은 다운로드로 시간이 걸립니다)")
        self.model = CLIPModel.from_pretrained(name).eval()
        self.proc = CLIPProcessor.from_pretrained(name)
        self.labels = POSITIVE + NEGATIVE
        self.n_pos = len(POSITIVE)

    @torch.no_grad()
    def score(self, img):
        inp = self.proc(text=self.labels, images=img, return_tensors="pt", padding=True)
        probs = self.model(**inp).logits_per_image.softmax(dim=1)[0]
        return float(probs[: self.n_pos].sum())

    def ok(self, img):
        return self.score(img) >= CLIP_THRESHOLD


# ---------------- 중복 제거 (average hash) ----------------
def ahash(img, size=8):
    g = img.convert("L").resize((size, size))
    px = list(g.getdata())
    avg = sum(px) / len(px)
    return int("".join("1" if p > avg else "0" for p in px), 2)


def is_dup(h, seen, dist=5):
    return any(bin(h ^ s).count("1") <= dist for s in seen)


# ---------------- 크롤링 ----------------
def get(url, **kw):
    try:
        r = requests.get(url, headers=HEADERS, timeout=10, **kw)
        return r if r.status_code == 200 else None
    except Exception:
        return None


def search_links(keyword, mode):
    q = urllib.parse.quote(keyword)
    pages = ([f"https://search.naver.com/search.naver?where=view&query={q}&start={s}" for s in (1, 31, 61)]
             if mode == "social" else
             [f"https://search.naver.com/search.naver?where=news&query={q}&start={s}" for s in (1, 11, 21, 31)])
    links = []
    for p in pages:
        r = get(p)
        if not r:
            continue
        html = r.text
        if mode == "social":
            for m in re.finditer(r"https?://(?:m\.)?blog\.naver\.com/([\w\-]+)/(\d{6,})", html):
                links.append(f"https://blog.naver.com/PostView.naver?blogId={m.group(1)}&logNo={m.group(2)}")
        else:
            soup = BeautifulSoup(html, "html.parser")
            for a in soup.select("a.news_tit, a[href]"):
                h = a.get("href", "")
                if h.startswith("http") and "search.naver.com" not in h and "naver.com/p/" not in h \
                        and (a.get("class") and "news_tit" in a.get("class") or "n.news.naver.com" in h):
                    links.append(h)
    return list(dict.fromkeys(links))


def page_is_relevant(text):
    """출처 검증: 무역센터/삼성역 + 현대 + 크리스마스가 모두 언급된 글만 통과"""
    return (("무역센터" in text or "삼성역" in text or "무역점" in text)
            and ("현대" in text) and ("크리스마스" in text or "Christmas" in text))


def page_images(url):
    r = get(url)
    if not r:
        return []
    soup = BeautifulSoup(r.text, "html.parser")
    text = soup.get_text(" ", strip=True)
    if not page_is_relevant(text):
        return []
    urls = []
    og = soup.find("meta", property="og:image")
    if og and og.get("content"):
        urls.append(og["content"])
    for im in soup.find_all("img"):
        src = im.get("data-lazy-src") or im.get("data-src") or im.get("src") or ""
        if not src.startswith("http"):
            continue
        low = src.lower()
        if any(x in low for x in ("profile", "icon", "logo", "banner", "button", "emoticon", "sticker", "ad_", "blank")):
            continue
        if "postfiles.pstatic.net" in low or "blogfiles" in low:
            src = src.split("?")[0] + "?type=w966"     # 원본에 가까운 크기
        urls.append(src)
    return list(dict.fromkeys(urls))


def load_image(url):
    r = get(url)
    if not r:
        return None
    try:
        img = Image.open(io.BytesIO(r.content))
        img.load()
        if img.size[0] < MIN_SIZE or img.size[1] < MIN_SIZE:
            return None
        return img.convert("RGB")
    except Exception:
        return None


# ---------------- 메인 로직 ----------------
def audit_existing(folder, ver, seen):
    """기존에 받은 이미지 재검수: 부적합/중복은 _rejected 로 이동"""
    rej = os.path.join(folder, "_rejected")
    os.makedirs(rej, exist_ok=True)
    kept, moved = 0, 0
    for fn in sorted(os.listdir(folder)):
        path = os.path.join(folder, fn)
        if not os.path.isfile(path) or not fn.lower().endswith((".jpg", ".jpeg", ".png")):
            continue
        try:
            img = Image.open(path).convert("RGB")
            h = ahash(img)
            good = ver.ok(img) and not is_dup(h, seen)
        except Exception:
            good, h = False, None
        if good:
            seen.append(h)
            kept += 1
        else:
            shutil.move(path, os.path.join(rej, fn))
            moved += 1
    print(f"   기존 이미지 검수: 유지 {kept}장 / 제외 {moved}장 (→ _rejected)")
    return kept


def next_index(folder):
    nums = [int(m.group(1)) for f in os.listdir(folder)
            if (m := re.match(r"img_(\d+)\.jpg$", f))]
    return max(nums, default=0) + 1


def run_folder(name, cfg, ver):
    folder = os.path.join(BASE_DIR, name)
    os.makedirs(folder, exist_ok=True)
    print(f"\n=== [{name}] ===")
    seen = []
    count = audit_existing(folder, ver, seen)
    idx = next_index(folder)
    visited = set()
    rejected_clip = 0

    for kw in cfg["keywords"]:
        if count >= TARGET:
            break
        print(f"🔍 '{kw}' 검색 중...")
        for link in search_links(kw, cfg["mode"]):
            if count >= TARGET:
                break
            if link in visited:
                continue
            visited.add(link)
            for img_url in page_images(link):
                if count >= TARGET:
                    break
                img = load_image(img_url)
                if img is None:
                    continue
                h = ahash(img)
                if is_dup(h, seen):
                    continue
                if not ver.ok(img):
                    rejected_clip += 1
                    continue
                img.save(os.path.join(folder, f"img_{idx:03d}.jpg"), "JPEG", quality=92)
                seen.append(h)
                idx += 1
                count += 1
                print(f"   ✔ {count}/{TARGET}  (CLIP 불통과 누적 {rejected_clip}장)")
    print(f"✅ [{name}] {count}장 확보" + ("" if count >= TARGET else f" (목표 {TARGET}장 미달 - 키워드를 늘려 다시 실행하세요)"))


if __name__ == "__main__":
    ver = Verifier()
    for name, cfg in FOLDERS.items():
        run_folder(name, cfg, ver)
    print(f"\n🎉 완료! '{BASE_DIR}' 확인 / 제외된 이미지는 각 폴더의 _rejected 에 있습니다.")
