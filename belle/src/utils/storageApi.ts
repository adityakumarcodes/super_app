import { NOTES_API_BASE } from "./notesApi";

export type UploadResult = {
  path: string;
  url: string;
};

async function readError(response: Response, fallback: string) {
  const body = await response.json().catch(() => undefined);

  if (!body || typeof body !== "object" || !("message" in body)) {
    return fallback;
  }

  const { message } = body as { message?: unknown };
  return Array.isArray(message)
    ? message.join(" ")
    : typeof message === "string"
      ? message
      : fallback;
}

export async function uploadImage(file: File): Promise<UploadResult> {
  const formData = new FormData();
  formData.append("file", file);

  const response = await fetch(`${NOTES_API_BASE}/storage/upload`, {
    method: "POST",
    credentials: "include",
    body: formData,
  });

  if (!response.ok) {
    throw new Error(
      await readError(response, `Image upload failed (${response.status})`),
    );
  }

  const result = (await response.json()) as UploadResult;
  if (!result.path) {
    throw new Error("The upload response did not include a storage path.");
  }

  return result;
}
