# Blog Writing Guide — MemoryBox

> 기술 블로그 포스트 작성 가이드 + 초안

## Target Blog

- URL: https://ramsbaby.netlify.app
- 독자: OpenClaw 사용자, AI agent 개발자, DevOps 엔지니어
- 톤: 실전 경험담, 솔직함, 기술적 깊이

---

## Blog Post Draft

### Title Options (A/B)

**A:** "How a 20KB File Crashed My AI Agent — and Two Open Source Projects Were Born"
**B:** "From Memory Explosion to Open Source: Building a Production OpenClaw Stack"

### Hook (첫 3줄이 생명)

> My OpenClaw agent ran 24/7 across 7 Discord channels with 48 cron jobs. It worked great — until the day `MEMORY.md` hit 20KB and everything fell apart.

### Structure

```
1. The Crash (Problem — 감정적 연결)
   - 24/7 에이전트 운영 배경
   - MEMORY.md 20KB+ 팽창
   - Context overflow → compaction corruption → gateway crash
   - "3AM에 에이전트 죽은 걸 발견"

2. The Band-Aid (Self-Healing — 첫 번째 해결)
   - 크래시 복구가 급하니까 self-healing 먼저 구축
   - 4-tier recovery: watchdog → healthcheck → claude emergency → discord alert
   - 30초 내 자동 복구
   - "근데 이건 증상 치료지 원인 치료가 아니었다"

3. The Root Cause (Memory Bloat 분석)
   - 왜 MEMORY.md가 커지나?
   - OpenClaw 메모리 아키텍처 설명
   - 매 세션마다 전체 로딩 → 토큰 낭비 → context pressure
   - "진짜 문제는 20KB짜리 파일이 55개 세션에 매번 로딩되는 것"

4. The Fix (MemoryBox — 두 번째 해결)
   - Letta/MemGPT에서 영감받은 3-tier 패턴
   - 20KB → 3.5KB (83% 감소)
   - CLI 도구: `memorybox doctor` 한 방
   - Honest note: 전체 토큰의 5-15%지만 context overflow 방지가 진짜 가치

5. What I Learned (교훈)
   - "예방 + 복구" 양쪽 다 필요
   - Zero dependency 철학: 복잡한 솔루션은 또 다른 장애점
   - 정직한 메트릭: 83%는 MEMORY.md 기준, 과대포장 금지
   - 프로덕션에서 배운 것 vs 이론의 차이

6. Try It (CTA)
   - self-healing: https://github.com/Ramsbaby/openclaw-self-healing
   - memorybox: https://github.com/Ramsbaby/openclaw-memorybox
   - 둘 다 5분 설치, 제로 의존성
```

### Key Metrics to Include

| Metric | Before | After | Source |
|--------|--------|-------|--------|
| MEMORY.md | 20,542 bytes | 3,460 bytes | `wc -c` |
| Context pressure | 98% | 7% | OpenClaw session_status |
| Recovery time | Manual (minutes~hours) | ~30s auto | Self-healing logs |
| Setup time | — | 5 min each | Timed |
| Dependencies | — | 0 | Package manifest |

### Tone Guide

- **첫인칭 경험담**: "I built", "My agent crashed", "I learned"
- **솔직함 필수**: 과대포장 하지 않기. "83% sounds great but it's 5-15% of total tokens"
- **기술적 깊이**: 코드 블록, 아키텍처 다이어그램 포함
- **스토리텔링**: 문제 → 시도 → 실패 → 해결 아크
- **ChatGPT 톤 금지**: "In this blog post, I will..." ❌

### Images / Diagrams

1. **Before/After 비교** — MEMORY.md 크기 바 차트
2. **3-tier 아키텍처** — 디렉토리 구조 다이어그램
3. **Self-healing + MemoryBox 관계도** — Prevention vs Recovery
4. **`memorybox doctor` 스크린샷** — 터미널 출력 (assets/demo.gif 활용)

### SEO Keywords

- openclaw memory management
- ai agent token optimization
- openclaw self-healing
- MEMORY.md bloat
- context window overflow
- openclaw production

### Cross-Promotion Links

- Self-healing GitHub: https://github.com/Ramsbaby/openclaw-self-healing
- MemoryBox GitHub: https://github.com/Ramsbaby/openclaw-memorybox
- ClawHub: https://clawhub.ai/Ramsbaby/openclaw-memorybox
- Dev.to (self-healing blog): [기존 포스트 URL]

---

## Distribution Plan

### Primary (블로그)
- ramsbaby.netlify.app에 풀 포스트 게시

### Secondary (소셜)
- **Moltbook**: ✅ 완료 (Post ID: `1031eec7`)
- **r/selfhosted**: 2/14 금요일 — self-healing 포스트에 MemoryBox 한 줄 언급
- **Dev.to**: self-healing 글에 "Part 2" 링크 추가 or 독립 포스트
- **HN**: 블로그 URL로 제출 (self-healing과 별도)

### 하지 말 것
- Reddit에 MemoryBox 단독 포스트 (너무 가벼움)
- 트위터 스레드 (팔로워 없으면 무의미)
- awesome-openclaw-skills PR (시기상조)

---

## Writing Checklist

- [ ] Hook이 3줄 안에 흥미를 끄는가?
- [ ] 코드 블록이 복붙 가능한가?
- [ ] 정직한 한계가 명시되어 있는가?
- [ ] CTA가 명확한가? (GitHub 링크)
- [ ] 이미지/GIF가 포함되어 있는가?
- [ ] SEO title + description 설정했는가?
- [ ] 그래머/스펠링 체크했는가?
- [ ] self-healing 크로스링크 있는가?
