# DURIT 30s - Omni 1.2 컷별 투입 폴더 정리 스크립트
# 원본은 건드리지 않고 "03_Omni투입_컷별" 폴더에 '복사'만 합니다.
# 사용법: 이 파일과 run_organize.bat을 이미지 폴더(01_컷별프레임, 02_기존소스가 있는 곳)에 넣고 bat 더블클릭
param(
    [string]$Root = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
$Root   = (Resolve-Path -LiteralPath $Root).Path
$OutDir = Join-Path $Root '03_Omni투입_컷별'
$Utf8Bom = New-Object System.Text.UTF8Encoding($true)

function Resolve-Src([string]$rel) {
    $p = Join-Path $Root ($rel -replace '/', '\')
    $isWild = $rel -match '\*'
    if (-not $isWild -and (Test-Path -LiteralPath $p)) { return Get-Item -LiteralPath $p }
    $dir  = Split-Path $p -Parent
    $leaf = Split-Path $p -Leaf
    if ($isWild -and (Test-Path -LiteralPath $dir)) {
        $m = Get-ChildItem -LiteralPath $dir -Filter $leaf -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($m) { return $m }
    }
    # 경로가 다르면 하위 폴더 전체에서 파일명으로 검색 (ZIP이 한 단계 더 들어가 풀린 경우 대비)
    return Get-ChildItem -LiteralPath $Root -Recurse -File -Filter $leaf -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notlike "$OutDir*" } | Select-Object -First 1
}

function I([string]$role, [string]$path) { return @{ Role = $role; Path = $path } }

$F = '01_컷별프레임'
$S1 = '02_기존소스/S1_제품등장'; $S2 = '02_기존소스/S2_전원과밀착'; $S3 = '02_기존소스/S3_블루모드'
$S4 = '02_기존소스/S4_레드모드'; $S5 = '02_기존소스/S5_루틴종료'; $S6 = '02_기존소스/S6_브랜드엔딩'

$cuts = @(
  @{ Id='S1A'; Folder='S1_제품등장\01_S1A_Cut1'; Edit='00.0–02.2초 (2.2s)'; Gen='4s'; Mode='Reference-to-Video (9:16)'
     Items=@( (I 'IN1_제품기준' "$S1/01_듀릿_정면_원본.jpg"), (I 'IN2_부유배경참고' "$S1/03_부유하는_듀릿.jpg"),
              (I 'REF_구도참고_첫프레임사용X' "$F/S1A.jpg"), (I 'POST_합성' "$S6/01_duflow_공식로고.svg") )
     Note='S1A.jpg는 글자가 박혀 있어 첫 프레임 직접 사용 비추천(구도 참고용). 후편집: duflow 로고, DURIT 텍스트.'
     Prompt=@'
Vertical 9:16 cinematic commercial product shot. Duration: 4 seconds. Deep dark charcoal sci-fi studio filled with low, atmospheric drifting mist. At the start, the DUFLOW DURIT device from the reference images is partially obscured in silhouette; as the mist smoothly parts, the upright floating device is revealed at a slight tilt, occupying the central two-thirds of the frame. Keep the faceted lime-green grip, graphite upper body, three horizontal indicator apertures, and single circular gold electrode disc 100% identical to the product reference. A single crisp, thin diagonal neon-green laser scan line sweeps steadily from bottom-left to top-right across the graphite housing and catches a sharp metallic glint on the gold head edge. Camera: slow, smooth push-in zoom toward the floating device, no cuts. Keep upper and lower areas dark, clean, and empty. No text, no logos, no lettering, no watermark.
'@ },
  @{ Id='S1B'; Folder='S1_제품등장\02_S1B_Cut2-1'; Edit='02.2–03.2초 (1.0s)'; Gen='3s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S1B.jpg"), (I 'IN2_디테일참조' "$S1/04_골드헤드_디테일.jpg") )
     Note='S1B(정면 골드헤드)와 S1C(후면 각인)는 반대면 → 각각 생성 후 빠른 컷/휩 패닝으로 연결.'
     Prompt=@'
Vertical 9:16 extreme industrial macro product video. Duration: 3 seconds. Starting from the head-on view of the DURIT gold electrode in the reference image, maintain the exact three concentric surfaces: polished outer gold ring, textured matte graphite inner annulus, and central gold disc. A narrow, sleek beam of warm-silver light glides smoothly across the gold head from bottom-left to top-right, producing a crisp metallic specular glint along the rim and center disc. Camera: very slow, steady upward tilt and subtle micro push-in across the electrode face, shallow depth of field with dark charcoal studio background. No morphing, no cuts, no text or watermark.
'@ },
  @{ Id='S1C'; Folder='S1_제품등장\03_S1C_Cut2-2'; Edit='03.2–04.0초 (0.8s)'; Gen='3s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S1C.jpg"), (I 'IN2_각인원본' "$S1/05_후면_로고각인.jpg") )
     Note='각인이 흔들리면 05_후면_로고각인.jpg로 트래킹 보정.'
     Prompt=@'
Vertical 9:16 extreme macro product video. Duration: 3 seconds. Close-up of the upper rear graphite facet of the DURIT from the reference image, keeping the exact engraved lowercase "duflow" lettering sharp, rigid, and completely undistorted on the right-hand third. A cool raking silver studio light sweeps slowly across the fine matte metallic grain and beveled edge, illuminating the physical inscription cleanly. Camera: subtle slow upward tilt and gentle focus lock onto the "duflow" engraving. Dark background, crisp industrial commercial lighting, no extra text or watermark.
'@ },
  @{ Id='S2A'; Folder='S2_전원과밀착\04_S2A_Cut3'; Edit='04.0–06.0초 (2.0s)'; Gen='4s'; Mode='First & Last Frame (9:16)'
     Items=@( (I 'IN1_첫프레임' "$S2/01_전원_누르기전.jpg"), (I 'IN2_끝프레임' "$F/S2A.jpg"),
              (I 'ALT_R2V대체용' "$S2/02_엄지_버튼조작.jpg") )
     Note='손 각도 차이가 크면 S2A.jpg + 02_엄지_버튼조작.jpg 조합의 Reference-to-Video로 대체.'
     Prompt=@'
Vertical 9:16 commercial close-up video. Duration: 4 seconds. Against a dark charcoal studio background, an adult hand naturally holds the exact DURIT device at a slight diagonal. The pad of the thumb smoothly moves down and firmly presses and holds the upper round power button located just below the horizontal row of three tiny indicator apertures. Upon holding the button, the leftmost tiny indicator dot illuminates cleanly in crisp electric blue light, casting a subtle pinpoint glow without washing over the handle. Keep the faceted lime-green grip, graphite upper body, gold electrode head, and three-aperture layout completely identical to the references. Camera: locked static close-up focused on the thumb-to-button contact and glowing blue LED. No cuts, no captions, no watermark.
'@ },
  @{ Id='S2B'; Folder='S2_전원과밀착\05_S2B_Cut4-1'; Edit='06.0–06.8초 (0.8s)'; Gen='3s'; Mode='Image-to-Video (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S2B.jpg") )
     Note=''
     Prompt=@'
Vertical 9:16 extreme beauty macro video. Duration: 3 seconds. Starting from the exact jawline angle and lighting in the reference image, a single fingertip with a short natural nail glides smoothly upward along the underside of an adult Korean woman's jaw toward the ear, spreading a thin, glistening trail of transparent gel essence. Realistic warm skin texture with fine visible pores; a sleek specular highlight catches the wet gel surface as the finger passes. Camera: gentle micro-tracking motion following the fingertip along the jaw contour, dark studio background, shallow depth of field. No device yet, no text, no watermark.
'@ },
  @{ Id='S2C'; Folder='S2_전원과밀착\06_S2C_Cut4-2'; Edit='06.8–09.0초 (2.2s)'; Gen='4s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S2C.jpg"), (I 'IN2_접촉각도참조' "$S2/05_헤드_볼밀착.jpg") )
     Note=''
     Prompt=@'
Vertical 9:16 side-on extreme beauty macro video. Duration: 4 seconds. Starting from the exact jawline contact in the first reference, the DURIT device stays pressed completely flush against the transparent gel-coated underside of the Korean woman's jaw with zero gap between the gold rim and skin. The device glides smoothly and steadily upward along the natural jawline curve, leaving a subtle wet gel sheen trailing behind the thin gold edge. Keep the faceted graphite neck, gold electrode rim, and sliver of lime-green grip true to the references. Camera: smooth side tracking shot following the device head closely along the jawline, dark background. No cuts, no text, no watermark.
'@ },
  @{ Id='S3A'; Folder='S3_블루모드\07_S3A_Cut5'; Edit='09.0–12.5초 (3.5s)'; Gen='4s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임_파동색' "$F/S3A.jpg"), (I 'IN2_기기자세참조' "$S3/01_목선_헤드접촉.jpg"),
              (I 'POST_파동보강' "$S3/06_블루그린_접촉파동.png") )
     Note='파동이 약하면 06_블루그린_접촉파동.png 후편집 합성.'
     Prompt=@'
Vertical 9:16 beauty tech commercial close-up. Duration: 4 seconds. Tight side profile framing only the neck, lower jaw, and the DURIT device—keep the model's eyes out of frame. Match the exact hand grip, faceted graphite rear body, subtle engraved "duflow" mark, and lime-green lower handle from the references. As the device head glides steadily upward from the side of the neck toward the jawline, delicate glowing electric-blue and neon-green microcurrent wave arcs pulse rhythmically outward from the skin contact point and ripple across the skin surface, fading softly at their outer edges. Camera: smooth tracking shot locked to the moving device head and pulsing skin waves, clean studio lighting. No text, no HUD, no watermark.
'@ },
  @{ Id='S3B'; Folder='S3_블루모드\08_S3B_Cut6'; Edit='12.5–15.0초 (2.5s)'; Gen='4s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S3B.jpg"), (I 'IN2_질감색감참조' "$S3/05_에센스흡수_SF연출.jpg") )
     Note='후편집 자막: 화장품 흡수 300% + 공식 시험조건(제품 조합·측정 시점). 영상 생성 시 넣지 말 것.'
     Prompt=@'
Vertical 9:16 conceptual sci-fi beauty macro animation. Duration: 4 seconds. Starting from the translucent skin-surface horizon in the reference image, a luminous clear dome of gel essence rests on the pearly translucent skin layer against deep navy-black negative space. Fine electric-blue and cyan-green glowing microcurrent particles pulse downward from beneath the droplet, penetrating smoothly into the translucent upper skin layers with subtle optical refraction ripples. As the shimmering cyan energy streams downward, the gel droplet gently flattens and absorbs into the skin, leaving the surface looking smoother and tighter. Camera: slow, hypnotic push-in zoom toward the skin surface and descending cyan particles. No labels, no numbers, no watermark.
'@ },
  @{ Id='S4A'; Folder='S4_레드모드\09_S4A_Cut7'; Edit='15.0–16.4초 (1.4s)'; Gen='3s'; Mode='First & Last Frame (9:16)'
     Items=@( (I 'IN1_첫프레임' "$S4/01_한손_버튼클릭.jpg"), (I 'IN2_끝프레임' "$F/S4A.jpg"),
              (I 'ALT_제품단독I2V용' "$S4/02_레드_LED.jpg") )
     Note='손 없는 제품 단독 LED 전환을 원하면 S4A.jpg + 02_레드_LED.jpg 조합의 Image-to-Video로 진행.'
     Prompt=@'
Vertical 9:16 extreme product close-up. Duration: 3 seconds. Tight frontal shot of the DURIT control face against dark charcoal. At the start, the horizontal row of three indicator apertures immediately above the round power button glows crisp blue. After a brief tactile click of the power button, all three tiny indicator dots swiftly switch from blue to vivid crimson-red LED light in unison, emitting a subtle pinpoint red aura tightly around the apertures only. Keep the vivid lime-green faceted body, matte graphite housing, and gold electrode rim completely true to color without red ambient light washing over the plastic grip. Camera: locked static extreme close-up, sharp focus on the LED row. No text, no watermark.
'@ },
  @{ Id='S4B'; Folder='S4_레드모드\10_S4B_Cut8'; Edit='16.4–21.0초 (4.6s)'; Gen='5s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S4B.jpg"), (I 'IN2_후면각인참조' "$S4/04_볼밀착_로고_클로즈업.jpg"),
              (I 'ALT_참조대체' "$S2/05_헤드_볼밀착.jpg"), (I 'POST_보강' "$S4/05_*") )
     Note='후편집 자막: 이중턱 리프팅 +16.79% + 공식 시험조건. S4/05 소스로 보강.'
     Prompt=@'
Vertical 9:16 commercial beauty tech close-up. Duration: 5 seconds. Three-quarter close-up framed below the eyes of the Korean woman, keeping the DURIT head pressed flush against the lower cheek and jawline. Keep the hand position, lime-green handle, and rear-facing graphite panel with the legible lowercase "duflow" mark facing toward the camera throughout the motion. The hand glides the DURIT slowly and firmly diagonally upward from the lower jaw toward the upper cheekbone, creating a subtle, natural skin-lifting motion. Trailing just behind the gliding head, slender glowing crimson-red microcurrent vector lines animate smoothly upward along the cheek contour, tracing the lifting path across exposed skin. Camera: steady close tracking shot following the upward glide of the device. Keep device colors accurate, no text, no watermark.
'@ },
  @{ Id='S5A'; Folder='S5_루틴종료\11_S5A_Cut9'; Edit='21.0–22.3초 (1.3s)'; Gen='3s'; Mode='Reference-to-Video (9:16)'
     Items=@( (I 'IN1_제품원본' "$S1/06_듀릿정면_배경투명.png"), (I 'IN2_배경' "$S1/08_차콜_스튜디오배경.jpg"),
              (I 'REF_구도참고' "$F/S5A.jpg"), (I 'POST_합성' "$S5/05_10분_AUTO_OFF_HUD.png") )
     Note='구도는 S5A.jpg처럼 좌측 치우침. 10:00 AUTO OFF 글자는 후편집에서 HUD png 합성.'
     Prompt=@'
Vertical 9:16 minimal dark studio product video. Duration: 3 seconds. One isolated front-facing DUFLOW DURIT device floats upright at a gentle tilt, positioned slightly left of center against an evenly shaded dark charcoal studio background. Match the exact lime-green grip, graphite upper housing, and gold electrode disc from the reference. At the start, the three tiny red LED indicators above the power button are softly illuminated; midway through the clip, all three LEDs smoothly power down and fade completely to dark, leaving the device dormant with a soft neutral sheen on the gold head. Keep the open space on the right half of the frame completely dark, uniform, and blank for post-production graphics. Camera: locked steady close-up with ultra-subtle floating stillness. No holographic text, no numbers, no UI, no watermark.
'@ },
  @{ Id='S5B'; Folder='S5_루틴종료\12_S5B_Cut10-1'; Edit='22.3–24.3초 (2.0s)'; Gen='4s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S5B.jpg"), (I 'IN2_모델얼굴착장고정' "$S5/02_선글라스_모델옆선.jpg") )
     Note='후편집 자막: 1회 사용 직후 광채 +43.24% + 공식 시험조건. 끝부분 포커스 아웃 → S5C와 0.2초 디졸브.'
     Prompt=@'
Vertical 9:16 sleek fashion-beauty commercial portrait. Duration: 4 seconds. Preserve the exact Korean woman from the reference image: same face, dark pinned-back hair with wispy strands, sleek black leather-style charcoal jacket, and narrow black sunglasses against a deep charcoal studio background with a subtle neon-green rim light on her hair and shoulder. Holding her three-quarter profile, two fingertips gently lower the narrow sunglasses slightly down the bridge of her nose, revealing her poised, confident eyes glancing subtly toward the upper-left. Soft satin studio light catches her sculpted jawline and naturally luminous, healthy cheek texture. Camera: ultra-slow cinematic push-in toward her jawline and eyes, ending with a gentle focus shift. Product stays out of frame. No text, no watermark.
'@ },
  @{ Id='S5C'; Folder='S5_루틴종료\13_S5C_Cut10-2'; Edit='24.3–25.0초 (0.7s)'; Gen='3s'; Mode='Image-to-Video + Reference (9:16)'
     Items=@( (I 'IN1_첫프레임' "$F/S5C.jpg"), (I 'IN2_손비율참조' "$S5/01_손에든_듀릿.jpg") )
     Note='S5B→S5C 랙포커스 블러 전환(0.2초 크로스 디졸브).'
     Prompt=@'
Vertical 9:16 commercial close-up video. Duration: 3 seconds. Starting from a soft out-of-focus blur, the camera swiftly racks focus into crisp sharpness onto the powered-off DUFLOW DURIT resting lightly in a relaxed adult hand entering from the lower-left against a dark charcoal background. Keep the exact finger placement from the reference with the thumb resting casually away from the power button and all three LED indicator apertures completely dark. Subtle natural hand poise, clean studio reflections along the faceted lime-green handle and gold electrode disc. Model remains out of frame. No text, no watermark.
'@ },
  @{ Id='S6A'; Folder='S6_브랜드엔딩\14_S6A_Cut11'; Edit='25.0–27.5초 (2.5s)'; Gen='4s'; Mode='First & Last Frame (조합 A) / Image-to-Video + Reference (조합 B) (9:16)'
     Items=@( (I 'A_IN1_첫프레임' "$F/S5C.jpg"), (I 'A_IN2_끝프레임' "$F/S6A.jpg"),
              (I 'B_IN2_제품참조' "$S1/06_듀릿정면_배경투명.png") )
     Note='조합 A(손 놓고 부유): S5C.jpg → S6A.jpg FLF. 조합 B(안정성 우선): S6A.jpg + 06_듀릿정면_배경투명.png I2V, 프롬프트 첫 문장(손 놓는 동작) 생략.'
     Prompt=@'
Vertical 9:16 hero sci-fi product commercial shot. Duration: 4 seconds. The relaxed hand smoothly releases the DURIT and withdraws out of frame, leaving the exact upright DURIT device suspended weightlessly in mid-air at the center of a dark charcoal studio. Match the exact proportions, lime-green faceted handle, dark graphite upper body, three dark indicator dots, and circular gold head from the reference. Immediately, a sleek, continuous glowing neon-green light ribbon spirals dynamically upward around the floating device in true 3D depth—passing cleanly behind the solid body and reappearing smoothly across the front without obscuring the gold electrode face, casting subtle green rim reflections along the beveled edges. Camera: smooth, sweeping cinematic half-orbit and gentle pull-back centered on the floating device. No text, no logo overlays, no watermark.
'@ },
  @{ Id='S6B'; Folder='S6_브랜드엔딩\15_S6B_Cut12'; Edit='27.5–30.0초 (2.5s)'; Gen='4s'; Mode='Reference-to-Video (9:16)'
     Items=@( (I 'IN1_제품기준' "$S1/06_듀릿정면_배경투명.png"), (I 'IN2_엔딩톤참조' "$S6/02_제품_엔딩풀샷.jpg"),
              (I 'REF_참고용_텍스트박힘' "$F/S6B.jpg"), (I 'ALT_첫프레임대안' "$F/S6A.jpg"),
              (I 'POST_합성_로고타이틀' "$S6/07_로고와_엔딩타이틀.svg"), (I 'POST_합성_파이널리스트' "$S6/03_2025_파이널리스트_원본.jpg") )
     Note='후편집: 하단 여백에 07_로고와_엔딩타이틀.svg(duflow + Your Skin Coach, DURIT)와 03_2025_파이널리스트 페이드인.'
     Prompt=@'
Vertical 9:16 final luxury studio hero packshot video. Duration: 4 seconds. The single upright DUFLOW DURIT basic device from the reference settles smoothly into a perfectly centered vertical position in the upper two-thirds of the frame against a quiet, deep charcoal studio background. Any lingering faint neon-green light particles from the previous shot dissipate swiftly into thin air within the first second, leaving clean soft studio rim light along the graphite bevels, a crisp natural glint across the gold electrode, and a vivid lime-green grip. Camera: gentle slow pull-back into a locked, rock-steady final full shot. Leave the entire lower third of the frame flat, dark, clean, and completely empty for post-production brand typography. No text, no logos, no award badges, no watermark.
'@ }
)

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$missing = New-Object System.Collections.Generic.List[string]
$rows    = New-Object System.Collections.Generic.List[object]
$copied  = 0

foreach ($c in $cuts) {
    $dest = Join-Path $OutDir $c.Folder
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $lines = New-Object System.Collections.Generic.List[string]
    $n = 0
    foreach ($it in $c.Items) {
        $n++
        $src = Resolve-Src $it.Path
        if ($null -eq $src) {
            $missing.Add("[$($c.Id)] $($it.Role) : $($it.Path)")
            $lines.Add("  - $($it.Role) : $($it.Path)   <<< 찾지 못함")
            continue
        }
        $name = '{0:D2}_{1}__{2}' -f $n, $it.Role, $src.Name
        Copy-Item -LiteralPath $src.FullName -Destination (Join-Path $dest $name) -Force
        $copied++
        $lines.Add("  - $($it.Role) : $name   (원본: $($src.FullName.Substring($Root.Length).TrimStart('\')))")
    }
    $txt = @"
[$($c.Id)]  $($c.Folder)
편집 길이 : $($c.Edit)   /   생성 권장 : $($c.Gen)
Omni 1.2 모드 : $($c.Mode)

■ 투입 이미지 (IN = 영상 생성 투입 / REF = 참고만 / ALT = 대안 조합 / POST = 후편집 합성)
$($lines -join "`r`n")

■ 메모
  $($c.Note)

■ 영상 프롬프트
$($c.Prompt.Trim())
"@
    [IO.File]::WriteAllText((Join-Path $dest '00_프롬프트.txt'), $txt, $Utf8Bom)
    $rows.Add([pscustomobject]@{
        '프레임ID' = $c.Id; '폴더' = $c.Folder; '편집길이' = $c.Edit; '생성권장' = $c.Gen; '모드' = $c.Mode
        '투입이미지' = (($c.Items | ForEach-Object { "$($_.Role)=$($_.Path)" }) -join ' | '); '메모' = $c.Note })
}

# 공통 팁
$tips = @'
Omni 1.2 작업 효율화 팁
1) 초안 → 보정 → 업스케일: 360p/720p로 모션·제품 형태 확인 후 잘 나온 클립만 1080p 업스케일.
2) 제품 디테일 뭉개짐(S1C 각인, S2A/S4A 3구 LED, S4B 후면 로고) 시 다턴 수정:
   "Restore the exact three-dot LED layout and button geometry from the reference image without changing the camera move"
3) 임상 수치 자막(흡수 300%, 이중턱 리프팅 +16.79%, 광채 +43.24%)은 영상 생성 시 넣지 말고
   최종 편집에서 공식 시험 조건(제품 조합·측정 시점)과 함께 얹을 것.
4) S1B ↔ S1C는 반대면 → 각각 생성 후 빠른 컷/휩 패닝 연결.
5) S5B 끝 포커스 아웃 + S5C 랙 포커스 인을 0.2초 크로스 디졸브.
'@
[IO.File]::WriteAllText((Join-Path $OutDir '00_작업팁.txt'), $tips, $Utf8Bom)
$csv = ($rows | ConvertTo-Csv -NoTypeInformation) -join "`r`n"
[IO.File]::WriteAllText((Join-Path $OutDir '00_매칭표.csv'), $csv, $Utf8Bom)

$missFile = Join-Path $OutDir '00_누락파일.txt'
if ($missing.Count -gt 0) {
    [IO.File]::WriteAllText($missFile, ($missing -join "`r`n"), $Utf8Bom)
} elseif (Test-Path -LiteralPath $missFile) { Remove-Item -LiteralPath $missFile }

Write-Host ''
Write-Host "완료: 15컷 폴더 생성, 파일 $copied 개 복사 → $OutDir" -ForegroundColor Green
if ($missing.Count -gt 0) {
    Write-Host "찾지 못한 파일 $($missing.Count)개 (00_누락파일.txt 참고):" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
}
