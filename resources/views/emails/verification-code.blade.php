<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verification Code</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f5f5f5;">
    <table role="presentation" style="width: 100%; border-collapse: collapse;">
        <tr>
            <td align="center" style="padding: 40px 0;">
                <table role="presentation" style="width: 100%; max-width: 400px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 32px 32px 24px; text-align: center;">
                            <div style="width: 60px; height: 60px; margin: 0 auto 16px; background: linear-gradient(135deg, #22C55E 0%, #16A34A 100%); border-radius: 16px; display: flex; align-items: center; justify-content: center;">
                                <span style="font-size: 28px; color: white; line-height: 60px;">P</span>
                            </div>
                            <h1 style="margin: 0; font-size: 24px; font-weight: 700; color: #1a1a1a;">Preuvely</h1>
                        </td>
                    </tr>

                    <!-- Content -->
                    <tr>
                        <td style="padding: 0 32px;">
                            <p style="margin: 0 0 8px; font-size: 16px; color: #666666;">Hello {{ $userName }},</p>
                            <p style="margin: 0 0 24px; font-size: 16px; color: #666666;">Here is your verification code:</p>
                        </td>
                    </tr>

                    <!-- Code -->
                    <tr>
                        <td style="padding: 0 32px;">
                            <div style="background-color: #f8f9fa; border-radius: 12px; padding: 24px; text-align: center; border: 2px dashed #22C55E;">
                                <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #22C55E; font-family: monospace;">{{ $code }}</span>
                            </div>
                        </td>
                    </tr>

                    <!-- Info -->
                    <tr>
                        <td style="padding: 24px 32px 32px;">
                            <p style="margin: 0 0 8px; font-size: 14px; color: #999999; text-align: center;">
                                This code expires in <strong>15 minutes</strong>.
                            </p>
                            <p style="margin: 0; font-size: 14px; color: #999999; text-align: center;">
                                If you didn't request this code, please ignore this email.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding: 24px 32px; background-color: #f8f9fa; border-radius: 0 0 16px 16px; text-align: center;">
                            <p style="margin: 0; font-size: 12px; color: #999999;">
                                &copy; {{ date('Y') }} Preuvely. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
