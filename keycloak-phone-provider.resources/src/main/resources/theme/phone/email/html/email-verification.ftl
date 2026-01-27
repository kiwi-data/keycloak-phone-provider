<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${msg("emailVerificationSubject")} - ${realmName}</title>
</head>
<body style="margin:0;padding:0;background-color:#f4f4f4;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="background-color:#f4f4f4;">
        <tr>
            <td style="padding:40px 20px;">
                <table role="presentation" cellpadding="0" cellspacing="0" width="600" style="margin:0 auto;background-color:#ffffff;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="padding:40px 40px 20px;text-align:center;background-color:#0066cc;border-radius:8px 8px 0 0;">
                            <h1 style="margin:0;color:#ffffff;font-size:24px;font-weight:600;">${realmName}</h1>
                        </td>
                    </tr>
                    <!-- Content -->
                    <tr>
                        <td style="padding:40px;">
                            <h2 style="margin:0 0 20px;color:#333333;font-size:20px;font-weight:600;">
                                ${kcSanitize(msg("emailVerificationSubject"))?no_esc} - ${realmName}
                            </h2>
                            <p style="margin:0 0 20px;color:#666666;font-size:16px;line-height:1.6;">
                                ${msg("emailGreeting")}
                            </p>
                            <p style="margin:0 0 20px;color:#666666;font-size:16px;line-height:1.6;">
                                ${kcSanitize(msg("emailVerificationIntro", "<strong>" + realmName + "</strong>"))?no_esc}
                            </p>
                            <p style="margin:0 0 30px;color:#666666;font-size:16px;line-height:1.6;">
                                ${msg("emailVerificationAction")}
                            </p>
                            <!-- Button -->
                            <table role="presentation" cellpadding="0" cellspacing="0" width="100%">
                                <tr>
                                    <td style="text-align:center;padding:20px 0;">
                                        <a href="${link}" style="display:inline-block;padding:14px 32px;background-color:#0066cc;color:#ffffff;text-decoration:none;border-radius:6px;font-size:16px;font-weight:600;box-shadow:0 2px 4px rgba(0,102,204,0.3);">
                                            ${msg("emailVerificationButton")}
                                        </a>
                                    </td>
                                </tr>
                            </table>
                            <p style="margin:30px 0 10px;color:#999999;font-size:14px;line-height:1.6;">
                                ${msg("emailCopyLink")}
                            </p>
                            <p style="margin:0 0 20px;word-break:break-all;">
                                <a href="${link}" style="color:#0066cc;font-size:14px;">${link}</a>
                            </p>
                            <p style="margin:20px 0 0;padding:20px;background-color:#fff8e1;border-radius:4px;color:#856404;font-size:14px;line-height:1.6;">
                                ⏰ ${kcSanitize(msg("emailExpiration", "<strong>" + linkExpiration + "</strong>", msg("linkExpirationFormatter.timePeriodUnit.minutes")))?no_esc}
                            </p>
                            <p style="margin:20px 0 0;color:#999999;font-size:14px;line-height:1.6;">
                                ${msg("emailVerificationIgnore")}
                            </p>
                        </td>
                    </tr>
                    <!-- Footer -->
                    <tr>
                        <td style="padding:30px 40px;background-color:#f8f9fa;border-radius:0 0 8px 8px;text-align:center;">
                            <p style="margin:0;color:#999999;font-size:12px;">
                                ${msg("emailAutoSent")}
                            </p>
                            <p style="margin:10px 0 0;color:#999999;font-size:12px;">
                                © ${.now?string('yyyy')} ${realmName}. ${msg("emailAllRights")}
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
