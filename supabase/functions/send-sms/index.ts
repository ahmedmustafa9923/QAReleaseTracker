import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { to, message } = await req.json()

  const accountSid = Deno.env.get("TWILIO_ACCOUNT_SID")
  const authToken = Deno.env.get("TWILIO_AUTH_TOKEN")
  const fromNumber = Deno.env.get("TWILIO_PHONE_NUMBER")

  const url = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`

  const body = new URLSearchParams({
    To: to,
    From: fromNumber!,
    Body: message,
  })

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": "Basic " + btoa(`${accountSid}:${authToken}`),
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body.toString(),
  })

  const data = await response.json()
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" },
  })
})
