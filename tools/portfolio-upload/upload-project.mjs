#!/usr/bin/env node
// coupley 등 개인 프로젝트를 portfolio(Flutter Web) Firestore/Storage에 등록하는 CLI.
//
// 사용법:
//   node upload-project.mjs <project.json> [--dry-run]
//
// project.json 형식은 tools/portfolio-upload/example-project.json 참고.
// project_model.dart의 ProjectModel.toMap() / firestore 경로와 반드시 일치시킬 것.

import { readFileSync, existsSync } from "node:fs";
import { resolve, dirname, extname, basename } from "node:path";
import { fileURLToPath } from "node:url";
import { imageSize } from "image-size";
import admin from "firebase-admin";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ID = "melkk-dev";
const STORAGE_BUCKET = "melkk-dev.firebasestorage.app";
const SERVICE_ACCOUNT_PATH = resolve(__dirname, "../../.secrets/service-account.json");

const CONTENT_TYPES = {
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".png": "image/png",
  ".gif": "image/gif",
  ".webp": "image/webp",
};

function fail(msg) {
  console.error(`\n[오류] ${msg}\n`);
  process.exit(1);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dry-run");
  const jsonPath = args.find((a) => !a.startsWith("--"));
  if (!jsonPath) fail("사용법: node upload-project.mjs <project.json> [--dry-run]");
  return { jsonPath: resolve(jsonPath), dryRun };
}

function loadServiceAccount() {
  if (!existsSync(SERVICE_ACCOUNT_PATH)) {
    fail(
      `서비스 계정 키가 없습니다: ${SERVICE_ACCOUNT_PATH}\n` +
        `Firebase 콘솔 > 프로젝트 설정 > 서비스 계정 > 새 비공개 키 생성 후 이 경로에 저장하세요.`
    );
  }
  return JSON.parse(readFileSync(SERVICE_ACCOUNT_PATH, "utf-8"));
}

function loadSpec(jsonPath) {
  if (!existsSync(jsonPath)) fail(`JSON 파일을 찾을 수 없습니다: ${jsonPath}`);
  const spec = JSON.parse(readFileSync(jsonPath, "utf-8"));
  for (const key of ["title", "summary", "images"]) {
    if (!spec[key]) fail(`project.json에 "${key}" 필드가 필요합니다.`);
  }
  if (!Array.isArray(spec.images) || spec.images.length === 0) {
    fail(`"images"는 로컬 이미지 파일 경로 배열이어야 합니다 (최소 1개).`);
  }
  return spec;
}

function detectLandscape(firstImagePath) {
  try {
    const buf = readFileSync(firstImagePath);
    const { width, height } = imageSize(buf);
    return width > height;
  } catch (e) {
    console.warn(`[경고] 이미지 방향 자동감지 실패, 세로형으로 처리: ${e.message}`);
    return false;
  }
}

function contentTypeFor(filename) {
  const ext = extname(filename).toLowerCase();
  return CONTENT_TYPES[ext] ?? "image/jpeg";
}

async function main() {
  const { jsonPath, dryRun } = parseArgs();
  const spec = loadSpec(jsonPath);

  for (const imgPath of spec.images) {
    if (!existsSync(resolve(imgPath))) fail(`이미지 파일을 찾을 수 없습니다: ${imgPath}`);
  }

  const serviceAccount = loadServiceAccount();
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: PROJECT_ID,
    storageBucket: STORAGE_BUCKET,
  });
  const db = admin.firestore();
  const bucket = admin.storage().bucket();
  const itemsCol = db.collection("portfolio").doc("projects").collection("items");

  // order / id 결정
  let order = spec.order;
  if (order === null || order === undefined) {
    const snap = await itemsCol.get();
    order = snap.size;
  }
  const id = spec.id ?? `project_${Date.now()}`;

  // 이미지 방향 자동감지 (isLandscape 미지정 시)
  const isLandscape =
    typeof spec.isLandscape === "boolean" ? spec.isLandscape : detectLandscape(resolve(spec.images[0]));

  // 파일명 자동 생성: project_{order}_{i}.{ext} (project_model.dart와 동일 규칙)
  const imageFilenames = spec.images.map((imgPath, i) => {
    const ext = extname(imgPath) || ".jpg";
    return `project_${order}_${i + 1}${ext}`;
  });

  console.log(`\n=== 업로드 계획 ===`);
  console.log(`제목        : ${spec.title}`);
  console.log(`요약        : ${spec.summary.slice(0, 60)}${spec.summary.length > 60 ? "…" : ""}`);
  console.log(`Firestore ID: ${id}  (order=${order})`);
  console.log(`방향        : ${isLandscape ? "가로형 (Desktop/Tablet)" : "세로형 (Phone)"}`);
  console.log(`이미지      : ${spec.images.length}장`);
  spec.images.forEach((src, i) => console.log(`  - ${basename(src)} → ${imageFilenames[i]}`));
  console.log(`행(rows)    : ${(spec.rows ?? []).length}개`);
  console.log(`통계(stats) : ${(spec.stats ?? []).length}개`);

  if (dryRun) {
    console.log(`\n--dry-run 이므로 실제 업로드는 하지 않았습니다.\n`);
    return;
  }

  // 1) 이미지 업로드
  for (let i = 0; i < spec.images.length; i++) {
    const src = resolve(spec.images[i]);
    const destName = imageFilenames[i];
    process.stdout.write(`업로드 중 (${i + 1}/${spec.images.length}): ${destName} ... `);
    await bucket.upload(src, {
      destination: `images/${destName}`,
      metadata: { contentType: contentTypeFor(destName) },
    });
    console.log("완료");
  }

  // 2) Firestore 문서 저장 (ProjectModel.toMap()과 동일한 스키마)
  const doc = {
    eyebrow: spec.eyebrow ?? "",
    title: spec.title,
    summary: spec.summary,
    imageFilenames,
    rows: (spec.rows ?? []).map((r) => ({
      label: r.label,
      value: r.value,
      ...(r.url ? { url: r.url } : {}),
    })),
    stats: (spec.stats ?? []).map((s) => ({ value: s.value, label: s.label })),
    isLandscape,
    order,
  };

  await itemsCol.doc(id).set(doc);
  console.log(`\nFirestore 저장 완료: portfolio/projects/items/${id}`);
  console.log(`https://melkk-dev.web.app 에서 확인하세요 (배포된 도메인이 다르면 그쪽으로 확인).\n`);
}

main().catch((e) => fail(e.stack ?? e.message));
