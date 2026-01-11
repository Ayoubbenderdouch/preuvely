<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Verification Code - Preuvely</title>
    <!--[if mso]>
    <noscript>
        <xml>
            <o:OfficeDocumentSettings>
                <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
        </xml>
    </noscript>
    <![endif]-->
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #0f0f0f; -webkit-font-smoothing: antialiased;">
    <!-- Wrapper -->
    <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%; border-collapse: collapse; background-color: #0f0f0f;">
        <tr>
            <td align="center" style="padding: 48px 16px;">
                <!-- Main Container -->
                <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%; max-width: 480px; border-collapse: collapse;">

                    <!-- Logo Section -->
                    <tr>
                        <td align="center" style="padding-bottom: 32px;">
                            <table role="presentation" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td style="vertical-align: middle;">
                                        <!-- Logo Icon -->
                                        <div style="width: 48px; height: 48px; background: linear-gradient(135deg, #22C55E 0%, #16A34A 100%); border-radius: 12px; display: inline-block; text-align: center; line-height: 48px;">
                                            <span style="font-size: 24px; font-weight: 700; color: #ffffff;">P</span>
                                        </div>
                                    </td>
                                    <td style="vertical-align: middle; padding-left: 12px;">
                                        <span style="font-size: 28px; font-weight: 700; color: #ffffff; letter-spacing: -0.5px;">Preuvely</span>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <!-- Card -->
                    <tr>
                        <td>
                            <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%; border-collapse: collapse; background-color: #1a1a1a; border-radius: 24px; overflow: hidden;">

                                <!-- Green Accent Bar -->
                                <tr>
                                    <td style="height: 4px; background: linear-gradient(90deg, #22C55E 0%, #16A34A 50%, #22C55E 100%);"></td>
                                </tr>

                                <!-- Header -->
                                <tr>
                                    <td style="padding: 40px 40px 24px; text-align: center;">
                                        <div style="width: 80px; height: 80px; margin: 0 auto 20px; background: rgba(34, 197, 94, 0.15); border-radius: 50%; line-height: 80px;">
                                            <span style="font-size: 40px;">&#128274;</span>
                                        </div>
                                        <h1 style="margin: 0 0 8px; font-size: 24px; font-weight: 700; color: #ffffff;">Verify Your Email</h1>
                                        <p style="margin: 0; font-size: 15px; color: #888888;">Enter this code to complete verification</p>
                                    </td>
                                </tr>

                                <!-- Greeting -->
                                <tr>
                                    <td style="padding: 0 40px 24px;">
                                        <p style="margin: 0; font-size: 16px; color: #cccccc; line-height: 1.6;">
                                            Hello <strong style="color: #ffffff;">{{ $userName }}</strong>,
                                        </p>
                                        <p style="margin: 12px 0 0; font-size: 16px; color: #888888; line-height: 1.6;">
                                            Use the verification code below to complete your sign-in:
                                        </p>
                                    </td>
                                </tr>

                                <!-- Code Box -->
                                <tr>
                                    <td style="padding: 0 40px 32px;">
                                        <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%; border-collapse: collapse;">
                                            <tr>
                                                <td style="background: linear-gradient(135deg, rgba(34, 197, 94, 0.1) 0%, rgba(22, 163, 74, 0.05) 100%); border: 2px solid #22C55E; border-radius: 16px; padding: 28px 20px; text-align: center;">
                                                    <span style="font-size: 42px; font-weight: 800; letter-spacing: 12px; color: #22C55E; font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Fira Mono', 'Droid Sans Mono', monospace;">{{ $code }}</span>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <!-- Timer Info -->
                                <tr>
                                    <td style="padding: 0 40px 32px;">
                                        <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%; border-collapse: collapse; background-color: #252525; border-radius: 12px;">
                                            <tr>
                                                <td style="padding: 16px 20px;">
                                                    <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%;">
                                                        <tr>
                                                            <td style="width: 40px; vertical-align: middle;">
                                                                <span style="font-size: 24px;">&#9200;</span>
                                                            </td>
                                                            <td style="vertical-align: middle;">
                                                                <p style="margin: 0; font-size: 14px; color: #888888;">
                                                                    This code expires in <strong style="color: #22C55E;">15 minutes</strong>
                                                                </p>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <!-- Security Notice -->
                                <tr>
                                    <td style="padding: 0 40px 40px;">
                                        <p style="margin: 0; font-size: 13px; color: #666666; line-height: 1.6; text-align: center;">
                                            &#128274; If you didn't request this code, you can safely ignore this email. Someone may have entered your email by mistake.
                                        </p>
                                    </td>
                                </tr>

                            </table>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding: 32px 20px;">
                            <table role="presentation" cellpadding="0" cellspacing="0" style="width: 100%;">
                                <tr>
                                    <td align="center">
                                        <p style="margin: 0 0 12px; font-size: 13px; color: #666666;">
                                            Need help? Contact us at <a href="mailto:support@preuvely.com" style="color: #22C55E; text-decoration: none;">support@preuvely.com</a>
                                        </p>
                                        <p style="margin: 0; font-size: 12px; color: #444444;">
                                            &copy; {{ date('Y') }} Preuvely. All rights reserved.
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                </table>
            </td>
        </tr>
    </table>
</body>
</html>
