import { redirect } from "@tanstack/react-router"
import { authClient } from "./auth-client"

export async function redirectIfAuthenticated() {
  const { data: session } = await authClient.getSession()

  if (session) {
    throw redirect({
      to: '/',
    })
  }
}